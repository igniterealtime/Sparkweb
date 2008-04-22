/*
 *This file is part of SparkWeb.
 *
 *SparkWeb is free software: you can redistribute it and/or modify
 *it under the terms of the GNU Lesser General Public License as published by
 *the Free Software Foundation, either version 3 of the License, or
 *(at your option) any later version.
 *
 *SparkWeb is distributed in the hope that it will be useful,
 *but WITHOUT ANY WARRANTY; without even the implied warranty of
 *MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *GNU Lesser General Public License for more details.
 *
 *You should have received a copy of the GNU Lesser General Public License
 *along with SparkWeb.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.jivesoftware.spark
{
	import com.jivesoftware.spark.managers.Localizator;
	import com.jivesoftware.spark.managers.MUCManager;
	import com.jivesoftware.spark.managers.SparkManager;
	
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
	import org.jivesoftware.xiff.conference.Room;
	import org.jivesoftware.xiff.core.JID;
	import org.jivesoftware.xiff.data.muc.MUCItem;
	import org.jivesoftware.xiff.data.muc.MUCUserExtension;
	import org.jivesoftware.xiff.events.RoomEvent;
	
	public class SparkGroupChat extends SparkChat
	{
  	    protected var _room:Room;
  	    private var roomPassword:String = null;
  	    private var recentlyChangedNicks:Object = null;
  	    
  	    public function SparkGroupChat(j:JID)
  	    {
  	    	super(j);
  	    }
  	    
  	    public override function setup(j:JID):void
  	    {
  	    	room = MUCManager.manager.getRoom(j);
  	    	displayName = room.roomJID.toString();
  	    	if (roomPassword != null)
  	    		room.password = roomPassword;

  	    	// Handle possible errors on joining the room
  	    	room.addEventListener(RoomEvent.PASSWORD_ERROR, handlePasswordError);
  	    	room.addEventListener(RoomEvent.REGISTRATION_REQ_ERROR, handleRegistrationReqError);
  	    	room.addEventListener(RoomEvent.BANNED_ERROR, handleBannedError);
  	    	room.addEventListener(RoomEvent.NICK_CONFLICT, handleNickConflict);
  	    	room.addEventListener(RoomEvent.MAX_USERS_ERROR, handleMaxUsersError);
  	    	room.addEventListener(RoomEvent.LOCKED_ERROR, handleLockedError);
  	    	
  	    	if(!room.join())
  	    		throw new Error("Couldn't join the room");
  	    	
  	    	room.addEventListener(CollectionEvent.COLLECTION_CHANGE, function(evt:CollectionEvent):void {
  	    		dispatchEvent(new Event("occupantsChanged"));
  	    		removeErrorEventListeners();
  	    	});
  	    	
  	    	// Listen to common room events
  	    	room.addEventListener(RoomEvent.USER_JOIN, handleUserJoin);
  	    	room.addEventListener(RoomEvent.USER_DEPARTURE, handleUserDeparture);
  	    	room.addEventListener(RoomEvent.USER_KICKED, handleUserKicked);
  	    	room.addEventListener(RoomEvent.USER_BANNED, handleUserBanned);

			room.addEventListener(RoomEvent.ROOM_JOIN, setupContextMenu);
  	    }
  	    
  	    /**
		 * Used to setup the room's context menu after the user has joined the room.
		 * This is done asynchronously since we do not have access to occupant role
		 * data until this point and we can determine whether to show/hide menu items
		 * based on the user's role.
		 */
  	    public function setupContextMenu(event:RoomEvent):void
  	    {
			// Setup the custom context menu
  	    	var inviteMenuItem:ContextMenuItem = new ContextMenuItem(Localizator.getText('menu.groupchat.invite.users'));
			inviteMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(evt:ContextMenuEvent):void { MUCInviteSendWindow.show(room.roomJID); });
			
			if (ui.contextMenu == null)
				ui.contextMenu = new ContextMenu();
				
			var contextMenu:ContextMenu = ContextMenu(ui.contextMenu);

			contextMenu.hideBuiltInItems();
			contextMenu.customItems.push(inviteMenuItem);
			
			if (room.affiliation == Room.OWNER_AFFILIATION) {
				var configureRoomMenuItem:ContextMenuItem = new ContextMenuItem(Localizator.getText('menu.groupchat.configure.room')); 
				configureRoomMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,
					function(evt:ContextMenuEvent):void
					{
						MUCConfigurationWindow.showMUCConfigureWindow(room);
					});
				
				contextMenu.customItems.push(configureRoomMenuItem);
			}
			
			room.removeEventListener(RoomEvent.ROOM_JOIN, setupContextMenu);
		}
  	    
  	    public override function get jid():JID
  	    {
  	    	return room.roomJID;
  	    }
  	    
  	    [Bindable]
  	    public function get room():Room
  	    {
  	    	return _room;
  	    }
  	    
  	    public override function close():void
  	    {
  	    	removeCommonEventListeners();

  	    	super.close();
  	    	room.leave();
  	    }
  	    
  	    //the user's nickname; this is because it may vary in groupchats
		public override function get myNickName():String {
			return room.nickname;
		}
  	    
  	    public override function insertMessage(message:SparkMessage):void
  	    {
  	    	if(room.isThisUser(message.from) && message.time == null)
				return;
			super.insertMessage(message);
  	    }
  	    
  	    public override function transmitMessage(message:SparkMessage):void {
  	    	room.sendMessage(message.body);
		}
  	    
  	    public function set room(r:Room):void
  	    {
  	    	_room = r;
  	    }
  	    
  	    public function set password(pw:String):void
  	    {
  	    	roomPassword = pw;
  	    }
  	    
  	    public override function set displayName(name:String):void
  	    {
  	    	if(name.indexOf('@') > -1)
				name = name.split('@')[0];
			super.displayName = name;
  	    }
  	    
  	    public override function get occupants():ArrayCollection
  	    {
  	    	return room;
  	    }
  	    
  	    private function error(message:String, name:String):void
  	    {
  	    	ChatContainer.window.closeGroupChatByJID(room.roomJID);
  	    	SparkManager.displayError(name, message, false);
  	    	removeErrorEventListeners();
  	    }
  	    
  	    public function handlePasswordError(event:RoomEvent):void
  	    {
  	    	ChatContainer.window.closeGroupChatByJID(room.roomJID);
  	    	MUCPasswordRequiredWindow.show(room);
  	    	removeErrorEventListeners();
  	    }
  	    
  	    public function handleRegistrationReqError(event:RoomEvent):void
  	    {
  	    	error(Localizator.getText('muc.error.auth'), Localizator.getText('muc.error'));
  	    }
  	    
  	    public function handleBannedError(event:RoomEvent):void
  	    {
  	    	error(Localizator.getText('muc.error.forbidden'), Localizator.getText('muc.error'));
  	    }
  	    
  	    public function handleNickConflict(event:RoomEvent):void
  	    {
  	    	error(Localizator.getText('muc.error.conflict'), Localizator.getText('muc.error'));
  	    }
  	    
  	    public function handleMaxUsersError(event:RoomEvent):void
  	    {
  	    	error(Localizator.getText('muc.error'), Localizator.getText('muc.error.service.unavailable'));
  	    }
  	    
  	    public function handleLockedError(event:RoomEvent):void
  	    {
  	    	error(Localizator.getText('muc.error'), Localizator.getText('muc.error.item.not.found'));
  	    }
  	    
  	    private function removeErrorEventListeners():void
  	    {
      		room.removeEventListener(RoomEvent.PASSWORD_ERROR, handlePasswordError);
      		room.removeEventListener(RoomEvent.REGISTRATION_REQ_ERROR, handleRegistrationReqError);
      		room.removeEventListener(RoomEvent.BANNED_ERROR, handleBannedError);
      		room.removeEventListener(RoomEvent.NICK_CONFLICT, handleNickConflict);
      		room.removeEventListener(RoomEvent.MAX_USERS_ERROR, handleMaxUsersError);
      		room.removeEventListener(RoomEvent.LOCKED_ERROR, handleLockedError);
  	    }
  	    
  	    public function handleUserJoin(event:RoomEvent):void
  	    {
  	    	// Is this join a result of a recent nick change?
  	    	if (recentlyChangedNicks != null) {
  	    		var nickChange:Array = recentlyChangedNicks[event.nickname];
  	    		if (nickChange != null) {
  	    			insertNotification(Localizator.getTextWithParams('muc.notification.nick.change', nickChange));
  	    			delete recentlyChangedNicks[event.nickname];
  	    			return;
  	    		}
  	    	}
  	    	
  	    	if (event.nickname != myNickName)
  	    		insertNotification(Localizator.getTextWithParams('muc.notification.join', [event.nickname]));
  	    }
  	    
  	    public function handleUserDeparture(event:RoomEvent):void
  	    {
  	    	// Was this a nick change?
  			var userExt:MUCUserExtension = event.data.getAllExtensionsByNS(MUCUserExtension.NS)[0];
			if (userExt && userExt.hasStatusCode(303)) {
				if (recentlyChangedNicks == null)
					recentlyChangedNicks = new Object();
				var userExtItem:MUCItem = userExt.getAllItems()[0];
				recentlyChangedNicks[userExtItem.nick] = [event.nickname, userExtItem.nick];
				return;
			}

  	    	insertNotification(Localizator.getTextWithParams('muc.notification.departure', [event.nickname]));
  	    }
  	    
  	    public function handleUserKicked(event:RoomEvent):void
  	    {
  	    	insertNotification(Localizator.getTextWithParams('muc.notification.kicked', [event.nickname]));
  	    }
  	    
  	    public function handleUserBanned(event:RoomEvent):void
  	    {
  	    	insertNotification(Localizator.getTextWithParams('muc.notification.banned', [event.nickname]));
  	    }
  	    
  	    private function removeCommonEventListeners():void
  	    {
  	    	room.removeEventListener(RoomEvent.USER_JOIN, handleUserJoin);
  	    	room.removeEventListener(RoomEvent.USER_DEPARTURE, handleUserDeparture);
  	    	room.removeEventListener(RoomEvent.USER_KICKED, handleUserKicked);
  	    	room.removeEventListener(RoomEvent.USER_BANNED, handleUserBanned);
  	    }
	}
}