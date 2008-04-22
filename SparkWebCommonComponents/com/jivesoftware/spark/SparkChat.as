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
	import com.jivesoftware.spark.displayfilters.EmoticonFilter;
	import com.jivesoftware.spark.displayfilters.HTMLEscapingFilter;
	import com.jivesoftware.spark.displayfilters.URLFilter;
	import com.jivesoftware.spark.events.EditorEvent;
	import com.jivesoftware.spark.managers.*;
	import com.jivesoftware.spark.SparkMessage;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.controls.*;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	
	import org.jivesoftware.xiff.core.JID;
	import org.jivesoftware.xiff.core.XMPPConnection;
	import org.jivesoftware.xiff.data.Message;
	import org.jivesoftware.xiff.data.Presence;
	import org.jivesoftware.xiff.data.im.RosterItemVO;
	import org.jivesoftware.xiff.util.*;
	
	[Bindable]
	public class SparkChat extends EventDispatcher
	{
		private var _ui:ChatRoom;
		protected var _jid:JID;
		protected var _nickname:String;
		protected var windowID:String;
		
		protected var _presence:String;
		protected var _activated:Boolean;
		protected var _isReady:Boolean = false;
		
		protected var lastMessage:SparkMessage = null;
		
		//fire an event at midnight each day so we can post a divider message to chats
 		protected static var dayTimer:Timer = new Timer(0,1);
		
		protected static var filters:Array = [HTMLEscapingFilter, URLFilter, EmoticonFilter];
		
		public function SparkChat(j:JID)
		{
			dayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(evt:TimerEvent):void {
				insertNotification(new Date().toLocaleDateString());
				setupDateChangeEvent();
			});
			setupDateChangeEvent();
			_jid = j;
		}
		
		protected function setupDateChangeEvent():void
	    {
	        var now:Date = new Date();
	        var alarmTime:Date = new Date(now.fullYear, now.month, now.date, 23, 59);
	        alarmTime.time += 60000; //add 1 minute

	        dayTimer.reset();
	        dayTimer.delay = alarmTime.time - now.time;
	        dayTimer.start();
	    }
		
		public function get ui():ChatRoom
		{
			return _ui;
		}
		
		public function set ui(view:ChatRoom):void
		{
			_ui = view;
			ui.addEventListener(FlexEvent.CREATION_COMPLETE, function(evt:FlexEvent):void { ui.editor.addEventListener(EditorEvent.MESSAGE_CREATED, sendMessage); });
			setup(_jid);
		}
		
		public function setup(j:JID):void
		{
			var rosterItem:RosterItemVO = RosterItemVO.get(j, true);
			
			_jid = rosterItem.jid;
			displayName = rosterItem.displayName;
			presence = rosterItem.show;
			rosterItem.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, function(evt:PropertyChangeEvent):void {
				if(evt.property == "show")
					presence = evt.newValue as String;
			});
		}
		
		//return value indicates whether the message did anything the user needs to be notified about, basically. probably less than ideal.
		public function handleMessage(msg:Message):Boolean
		{
			if(!msg.body)
			{
			    var childNode:XMLNode = msg.getNode().firstChild;
				if(!childNode || childNode.namespaceURI != 'jabber:x:event')
					return false;

				ui.isTyping = childNode.childNodes.some(
					function(node:XMLNode, index:int, arr:Array):Boolean { return node.nodeName == 'composing'; }
				);
				
				return false;			    
			}
			
			insertMessage(SparkMessage.fromMessage(msg, this));
			return true;
		}
		
		[Bindable(event="occupantsChanged")]
		public function get occupants():ArrayCollection {
			return new ArrayCollection([{nick : myNickName}, {nick : displayName}]);
		}
		
		public function get jid():JID {
			return _jid;
		}
		
		public function set displayName(nickname:String):void {
			_nickname = nickname;
		}
		
		public function get displayName():String {
			return _nickname;
		}
		
		//the user's nickname; this is because it may vary in groupchats
		public function get myNickName():String {
			return SparkManager.me.displayName;
		}

		public function insertMessage(message:SparkMessage):void 
		{		
			for each(var filter:* in filters)
			{
				message.body = filter.apply(message.body);
			}
			var id:String = message.nick;
			ui.isTyping = false;
			if(!message.time)
				message.time = new Date();
			else
			{
				if(!lastMessage || message.time.date != lastMessage.time.date)
					insertNotification(message.time.toLocaleDateString());
			}
			ui.history.addUserMessage(id, id, message.body, message.time, message.local ? "user" : null);
			if(!message.local)
				ui.increaseMessageCount();
			lastMessage = message;
		}
		
		protected function runCommand(message:String):Boolean
		{
			var segments:Array = message.split(" ");
			if(!message.charAt(0) == '/')
				return false;
			switch((segments.shift() as String).substring(1))
			{
				case "away":
				case "brb":
					SparkManager.presenceManager.changePresence(Presence.SHOW_AWAY, segments.length > 0 ? segments.join(" ") : "Away");
					return true;
				case "back":
				case "available":
					SparkManager.presenceManager.changePresence(null, segments.length > 0 ? segments.join(" ") : "Available");
					return true;
				
			}
			return false;
		}
			
		public function set presence(presence:String):void {
			_presence = presence;
			ui.updateIcon();
		}
		
		public function get presence():String {
			return _presence;
		}
		
		public function insertNotification(body:String, time:Date = null):void {
			ui.history.addSystemMessage(body, time, null);
		}
	
		public function sendMessage(evt:EditorEvent):void 
		{
			var text:String = evt.message;
			if(text.length == 0)
				return;
				
			//run commands like /away, /clear
			if(runCommand(text))
				return;
			
			var message:SparkMessage = new SparkMessage(SparkManager.connectionManager.connection.jid, text);
			message.local = true;
			message.chat = this;
			
			// Send Message
			transmitMessage(message);
			insertMessage(message);
		}
		
		//actually does the sending to the connection
		public function transmitMessage(message:SparkMessage):void {
			SparkManager.connectionManager.sendMessage(jid, message.body);
		}
		
		public function init():void 
		{
		}
		
		public function close():void {
		}
	}
}