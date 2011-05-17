/*
 * Copyright (C) 2003-2010 Igniterealtime Community Contributors
 *
 *     Daniel Henninger
 *     Derrick Grigg <dgrigg@rogers.com>
 *     Juga Paazmaya <olavic@gmail.com>
 *     Nick Velloff <nick.velloff@gmail.com>
 *     Sean Treadway <seant@oncotype.dk>
 *     Sean Voisen <sean@voisen.org>
 *     Mark Walters <mark@yourpalmark.com>
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.igniterealtime.xiff.conference
{
	import flash.events.Event;

	import org.igniterealtime.xiff.collections.ArrayCollection;
	import org.igniterealtime.xiff.core.*;
	import org.igniterealtime.xiff.data.*;
	import org.igniterealtime.xiff.data.forms.FormExtension;
	import org.igniterealtime.xiff.data.muc.*;
	import org.igniterealtime.xiff.events.*;

	/**
	 * Dispatched when the active, affiliation, or role property changes.
	 *
	 * @eventType org.igniterealtime.xiff.events.PropertyChangeEvent.CHANGE
	 */
	[Event( name="change", type="org.igniterealtime.xiff.events.PropertyChangeEvent" )]
	/**
	 * Dispatched when an administration action failed.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.ADMIN_ERROR
	 * @see	org.igniterealtime.xiff.core.XMPPConnection.error
	 */
	[Event( name="adminError", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when an affiliation change has completed.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.AFFILIATION_CHANGE_COMPLETE
	 */
	[Event( name="affiliationChangeComplete", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when an affiliation list has been requested. The event object contains an
	 * array of <code>MUCItems</code> containing the JID and affiliation properties.
	 *
	 * <p>To grant or revoke permissions based on this list, only send the changes you wish to
	 * make, calling grant/revoke with the new affiliation and existing JID.</p>
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.AFFILIATIONS
	 */
	[Event( name="affiliations", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched if the user attempted to join the room but was not allowed to do so because
	 * they are banned (i.e., has an affiliation of "outcast").
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.BANNED_ERROR
	 */
	[Event( name="bannedError", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when a room configuration form is required.	This can occur during the
	 * creation of a room, or if a room configuration is requested.	The <code>RoomEvent</code>
	 * instance will contain an attribute <code>data</code> that is an instance of an object
	 * with the following attributes:
	 *
	 * <p><code>instructions</code>: Instructions for the use of form<br />
	 * <code>title</code>: Title of the configuration form<br />
	 * <code>label</code>: A friendly name for the field<br />
	 * <code>name</code>: A computer readable identifier for the field used to identify
	 * this field in the result passed to <code>configure()</code><br />
	 * <code>type</code>: The type of the field to be displayed. Type will be a constant
	 * from the <code>FormField</code> class.</p>
	 *
	 * @see	org.igniterealtime.xiff.data.forms.FormExtension
	 * @see	org.igniterealtime.xiff.data.forms.FormField
	 * @see	#configure
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.CONFIGURE_ROOM
	 */
	[Event( name="configureRoom", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when a room configuration form is complete.
	 *
	 * @see #configure
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.CONFIGURE_ROOM_COMPLETE
	 */
	[Event(name="configureRoomComplete", type="org.igniterealtime.xiff.events.RoomEvent")]
	/**
	 * Dispatched when an invite to this room has been declined by the invitee. The <code>RoomEvent</code>
	 * <code>data</code> property that has the following attributes:
	 *
	 * <p><code>from</code>: The JID of the user initiating the invite<br />
	 * <code>reason</code>: A string containing the reason to join the room<br />
	 * <code>data</code>: The original message containing the decline</p>
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.DECLINED
	 */
	[Event( name="declined", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched whenever a new message intented for all room occupants is received. The
	 * <code>RoomEvent</code> class will contain an attribute <code>data</code> with the
	 * group message as an instance of the <code>Message</code> class.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.GROUP_MESSAGE
	 */
	[Event( name="groupMessage", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched if a user attempts to enter a room while it is "locked" (i.e., before the room
	 * creator provides an initial configuration and therefore before the room officially exists).
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.LOCKED_ERROR
	 */
	[Event( name="lockedError", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched if the room has reached its maximum number of occupants.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.MAX_USERS_ERROR
	 */
	[Event( name="maxUsersError", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when the user's preferred nickname already exists in the room.	The
	 * <code>RoomEvent</code> will contain an attribute <code>nickname</code> with the nickname
	 * already existing in the room.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.NICK_CONFLICT
	 */
	[Event( name="nickConflict", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when the room requires a password and the user did not supply one (or
	 * the password provided is incorrect).
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.PASSWORD_ERROR
	 */
	[Event( name="passwordError", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched whenever a new private message is received. The <code>RoomEvent</code> class
	 * contains an attribute <code>data</code> with the private message as an instance of the
	 * <code>Message</code> class.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.PRIVATE_MESSAGE
	 */
	[Event( name="privateMessage", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when the room is members-only and the user is not on the member list.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.REGISTRATION_REQ_ERROR
	 */
	[Event( name="registrationReqError", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when the room is removed.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.ROOM_DESTROYED
	 */
	[Event( name="roomDestroyed", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when you have entered the room and messages that are sent
	 * will be displayed to other users. The room's role and affiliation will
	 * be visible from this point forward.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.ROOM_JOIN
	 */
	[Event( name="roomJoin", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when the server acknoledges that you have the left the room.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.ROOM_LEAVE
	 */
	[Event( name="roomLeave", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when the room subject changes.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.SUBJECT_CHANGE
	 */
	[Event( name="subjectChange", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when a user is banned from the room.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.USER_BANNED
	 */
	[Event( name="userBanned", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched whenever an occpant leaves the room. The <code>RoomEvent</code> instance will
	 * contain an attribute <code>nickname</code> with the nickname of the occupant who left.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.USER_DEPARTURE
	 */
	[Event( name="userDeparture", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched whenever an occupant joins the room. The <code>RoomEvent</code> instance will
	 * contain an attribute <code>nickname</code> with the nickname of the occupant who joined.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.USER_JOIN
	 */
	[Event( name="userJoin", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when a user is kicked from the room.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.USER_KICKED
	 */
	[Event( name="userKicked", type="org.igniterealtime.xiff.events.RoomEvent" )]
	/**
	 * Dispatched when a user's presence changes.
	 *
	 * @eventType org.igniterealtime.xiff.events.RoomEvent.USER_PRESENCE_CHANGE
	 */
	[Event( name="userPresenceChange", type="org.igniterealtime.xiff.events.RoomEvent" )]

	/**
	 * Manages incoming and outgoing data from a conference room as part of multi-user conferencing (XEP-0045).
	 * You will need an instance of this class for each room that the user joins.
	 */
	public class Room extends ArrayCollection
	{
		public static const AFFILIATION_ADMIN:String = MUC.AFFILIATION_ADMIN;
		public static const AFFILIATION_MEMBER:String = MUC.AFFILIATION_MEMBER;
		public static const AFFILIATION_NONE:String = MUC.AFFILIATION_NONE;
		public static const AFFILIATION_OUTCAST:String = MUC.AFFILIATION_OUTCAST;
		public static const AFFILIATION_OWNER:String = MUC.AFFILIATION_OWNER;
		public static const ROLE_MODERATOR:String = MUC.ROLE_MODERATOR;
		public static const ROLE_NONE:String = MUC.ROLE_NONE;
		public static const ROLE_PARTICIPANT:String = MUC.ROLE_PARTICIPANT;
		public static const ROLE_VISITOR:String = MUC.ROLE_VISITOR;

		private static var roomStaticConstructed:Boolean = RoomStaticConstructor();

		private static var staticConstructorDependencies:Array = [ FormExtension, MUC ]

		private var _active:Boolean;

		private var _affiliation:String;

		private var _anonymous:Boolean = true;

		private var _connection:XMPPConnection;

		//private var _fileRepo:RoomFileRepository;

		private var _nickname:String;

		private var _password:String;

		private var _role:String;

		private var _roomJID:UnescapedJID;

		private var _subject:String;

		private var myIsReserved:Boolean;

		// Used to store nicknames in pending status, awaiting change approval from server
		private var pendingNickname:String;

		private var affiliationExtension:MUCBaseExtension;
		private var affiliationArgs:Array = [];

		/**
		 *
		 * @param	aConnection  A XMPPConnection instance that is providing the primary server connection
		 */
		public function Room( aConnection:XMPPConnection = null )
		{
			setActive( false );
			if ( aConnection != null )
			{
				connection = aConnection;
			}
			affiliationExtension = new MUCAdminExtension();
		}

		private static function RoomStaticConstructor():Boolean
		{
			MUC.enable();
			FormExtension.enable();

			return true;
		}

		/**
		 * Allow a previously banned JIDs to enter this room.	This is the same as:
		 * <code>Room.grant(AFFILIATION_NONE, jid)</code>
		 *
		 * <p>If the process could not be completed, the room will dispatch the event
		 * <code>RoomEvent.ADMIN_ERROR</code></p>
		 *
		 * @param	jids An array of unescaped JIDs to allow
		 * @see	#grant
		 * @see	#revoke
		 */
		public function allow( jids:Array ):void
		{
			grant( Room.AFFILIATION_NONE, jids );
		}

		/**
		 * Bans an array of JIDs from entering the room.
		 *
		 * <p>If the process could not be completed, the room will dispatch the event
		 * <code>RoomEvent.ADMIN_ERROR</code>.</p>
		 *
		 * @param	jids An arry of unescaped JIDs to ban
		 */
		public function ban( jids:Array ):void
		{
			var iq:IQ = new IQ( roomJID.escaped, IQ.TYPE_SET, null, ban_response, ban_error );
			var adminExt:MUCAdminExtension = new MUCAdminExtension();

			for each ( var banJID:UnescapedJID in jids )
			{
				adminExt.addItem( Room.AFFILIATION_OUTCAST, null, null, banJID.escaped, null, null );
			}

			iq.addExtension( adminExt );
			_connection.send( iq );
		}

		/**
		 * Cancels the configuration process.	The room may still be locked if
		 * you cancel the configuration process when attempting to join a
		 * reserved room.
		 *
		 * <p>You must have joined the room and have the owner affiliation to
		 * configure the room.</p>
		 *
		 * @see	#configureRoom
		 * @see	#configure
		 * @see	#join
		 */
		public function cancelConfiguration():void
		{
			var iq:IQ = new IQ( roomJID.escaped, IQ.TYPE_SET );
			var ownerExt:MUCOwnerExtension = new MUCOwnerExtension();
			var form:FormExtension = new FormExtension();

			form.type = FormExtension.TYPE_CANCEL;

			ownerExt.addExtension( form );
			iq.addExtension( ownerExt );
			_connection.send( iq );
		}

		/**
		 * Changes the subject in the conference room. You must have already joined the
		 * room before you can change the subject.
		 *
		 * @param	newSubject The new subject
		 */
		public function changeSubject( newSubject:String ):void
		{
			if ( isActive )
			{
				var message:Message = new Message( roomJID.escaped, null, null,
													   null, Message.TYPE_GROUPCHAT,
													   newSubject );
				_connection.send( message );
			}
		}

		/**
		 * Sends a configuration form to the room.
		 *
		 * You must be joined and have owner affiliation to configure the room
		 *
		 * @param	fieldmap FormExtension, or a hash that is an object with keys being the room configuration
		 * form variables and the values being arrays. For single value fields, use a single
		 * element array.
		 * @see	#configureRoom
		 * @see http://xmpp.org/extensions/xep-0045.html#registrar-formtype-owner
		 */
		public function configure( fieldmap:Object ):void
		{
			var iq:IQ = new IQ( roomJID.escaped, IQ.TYPE_SET, null, configure_response, configure_error );
			var ownerExt:MUCOwnerExtension = new MUCOwnerExtension();
			var form:FormExtension;

			if ( fieldmap is FormExtension )
			{
				form = FormExtension( fieldmap );
			}
			else
			{
				form = new FormExtension();
				fieldmap[ "FORM_TYPE" ] = [ "http://jabber.org/protocol/muc#roomconfig" ];
				form.setFields( fieldmap );
			}
			form.type = FormExtension.TYPE_SUBMIT;
			ownerExt.addExtension( form );

			iq.addExtension( ownerExt );

			_connection.send( iq );
		}

		/**
		 * Actively decline an invitation.	You can optionally ignore invitations
		 * but if you choose to decline an invitation, you call this method on
		 * a room instance that represents the room the invite originated from.
		 *
		 * <p>You do not need to have joined this room to decline an invitation</p>
		 *
		 * <p>Note: mu-conference-0.6 does not allow users to send decline
		 * messages without joining first.	If using this version of conferencing
		 * software, it is best to ignore invites.</p>
		 *
		 * @param	jid	An unescaped JID of the user to invite.
		 * @param	reason A string describing why the invitiation was declined
		 */
		public function decline( jid:UnescapedJID, reason:String ):void
		{
			var message:Message = new Message( roomJID.escaped )
			var userExt:MUCUserExtension = new MUCUserExtension();

			userExt.decline( jid.escaped, undefined, reason );

			message.addExtension( userExt );
			_connection.send( message );
		}

		/**
		 * Destroys a reserved room.	If the room has been configured to be persistent,
		 * then it is optional that the server will permanently remove the room.
		 *
		 * @param	reason A short description of why the room is being destroyed
		 * @param	alternateJID A JID for current members to use as an alternate room to join
		 * after the room has been destroyed. Like a postal forwarding address.
		 */
		public function destroy( reason:String, alternateJID:UnescapedJID = null, callback:Function = null ):void
		{
			var iq:IQ = new IQ( roomJID.escaped, IQ.TYPE_SET );
			var ownerExt:MUCOwnerExtension = new MUCOwnerExtension();
			var jid:EscapedJID;
			if (alternateJID != null)
			{
				jid = alternateJID.escaped;
			}

			iq.callback = callback;
			ownerExt.destroy( reason, jid );

			iq.addExtension( ownerExt );
			_connection.send( iq );
		}

		/**
		 * Gets an instance of the <code>Message</code> class that has been pre-configured to be
		 * sent from this room. Use this method to get a <code>Message</code> in order to add extensions
		 * to outgoing room messages.
		 *
		 * @param	body The message body
		 * @param	htmlBody The message body with HTML formatting
		 * @return A <code>Message</code> class instance
		 */
		public function getMessage( body:String = null, htmlBody:String = null ):Message
		{
			var message:Message = new Message( roomJID.escaped, null, body, htmlBody,
												   Message.TYPE_GROUPCHAT );
			return message;
		}

		/**
		 * Gets the <code>RoomOccupant</code> whose displayName matches the name passed in.
		 *
		 * @param	name
		 * @return
		 */
		public function getOccupantNamed( name:String ):RoomOccupant
		{
			for each ( var occ:RoomOccupant in this )
			{
				if ( occ.displayName == name )
				{
					return occ;
				}
			}
			return null;
		}

		/**
		 * Grants permissions on a room to one or more JIDs by setting the
		 * affiliation of a user based on their JID.
		 *
		 * <p>If the JID currently has an existing affiliation, then the existing
		 * affiliation will be replaced with the one passed. If the process could not be
		 * completed, the room will dispatch the event <code>RoomEvent.ADMIN_ERROR</code>.</p>
		 *
		 * <p>XMPP spec states that the #admin schema should be used for affiliation changes.
		 * Unfortunately to this date, Openfire does not match spec and requires the #owner schema.
		 * Because of this, if granting privileges fails on the first attempt using the #admin schema,
		 * we try again using the #owner schema.</p>
		 *
		 * @param	affiliation Use one of the
		 * following affiliations: <code>Room.AFFILIATION_MEMBER</code>,
		 * <code>Room.AFFILIATION_ADMIN</code>,
		 * <code>Room.AFFILIATION_OWNER</code>
		 * @param	jids An array of UnescapedJIDs to grant these permissions to
		 * @see	#revoke
		 * @see	#allow
		 * @see http://xmpp.org/extensions/xep-0045.html#schemas-admin
		 */
		public function grant( affiliation:String, jids:Array ):void
		{
			affiliationArgs = arguments;

			var iq:IQ = new IQ( roomJID.escaped, IQ.TYPE_SET, null, grant_response, grant_error );

			for each ( var jid:UnescapedJID in jids )
			{
				affiliationExtension.addItem( affiliation, null, null, jid.escaped, null, null );
			}

			iq.addExtension( affiliationExtension as IExtension );
			_connection.send( iq );
		}

		/**
		 * Invites a user that is not currently a member of this room to this room.
		 *
		 * <p>You must have joined the room and have appropriate permissions to invite
		 * other memebers, because the server will format and send the invite message to
		 * as if it came from the room rather that you sending the invite directly from you.</p>
		 *
		 * <p>To listen to invite events, add an event listener on your XMPPConnection to the
		 * <code>InviteEvent.INVITED</code> event.</p>
		 *
		 * @param	jid	An unescaped JID of the user to invite.
		 * @param	reason A string describing why you would like to invite the user.
		 */
		public function invite( jid:UnescapedJID, reason:String ):void
		{
			var message:Message = new Message( roomJID.escaped );
			var userExt:MUCUserExtension = new MUCUserExtension();

			userExt.invite( jid.escaped, undefined, reason );

			message.addExtension( userExt );
			_connection.send( message );
		}

		/**
		 * Determines if the <code>sender</code> parameter is the same
		 * as the room's JID.
		 *
		 * @param	the room JID to test
		 * @return true if the passed JID matches the getRoomJID
		 */
		public function isThisRoom( sender:UnescapedJID ):Boolean
		{
			var value:Boolean = false;
			if (_roomJID != null)
			{
				value = sender.bareJID.toLowerCase() == roomJID.bareJID.toLowerCase();
			}
			return value;
		}

		/**
		 * Determines if the <code>sender</code> param is the
		 * same as the user's JID.
		 *
		 * @param	sender	the room JID to test
		 * @return true if the passed JID matches the userJID
		 */
		public function isThisUser( sender:UnescapedJID ):Boolean
		{
			var value:Boolean = false;
			if (userJID != null)
			{
				value = sender.toString().toLowerCase() == userJID.toString().toLowerCase();
			}
			return value;
		}

		/**
		 * Joins a conference room based on the parameters specified by the room
		 * properties.	This call will create an instant room based on a default
		 * server configuration if the room doesn't exist.
		 *
		 * <p>To create and begin the configuration process of a reserved room, pass
		 * <code>true</code> to this method to begin the configuration process.	When
		 * The configuration is complete, the room will be unlocked for others to join.
		 * Listen for the <code>RoomEvent.CONFIGURE_ROOM</code> event to handle and
		 * either return or cancel the configuration of the room.
		 *
		 * @param	createReserved Set to true if you wish to create and configure a reserved room
		 * @param	joinPresenceExtensions An array of additional extensions to send with the initial presence to the room.
		 * @return A boolean indicating whether the join attempt was successfully sent.
		 */
		public function join( createReserved:Boolean = false, joinPresenceExtensions:Array = null ):Boolean
		{
			var muc:MUCExtension = new MUCExtension();

			if ( password != null )
			{
				muc.password = password;
			}

			return joinWithExplicitMUCExtension(createReserved, muc, joinPresenceExtensions);
		}

		/**
		 * Joins a conference room based on the parameters specified by the room
		 * properties.	This call will create an instant room based on a default
		 * server configuration if the room doesn't exist.
		 *
		 * <p>To create and begin the configuration process of a reserved room, pass
		 * <code>true</code> to this method to begin the configuration process.	When
		 * The configuration is complete, the room will be unlocked for others to join.
		 * Listen for the <code>RoomEvent.CONFIGURE_ROOM</code> event to handle and
		 * either return or cancel the configuration of the room.
		 *
		 * This function adds an additional parameter to allow the caller to completely customize the MUC extension that
		 * gets sent to the room.  For example, you can add a history element that specifies how much discussion
		 * history you want sent when you join the room (http://xmpp.org/extensions/xep-0045.html#enter-managehistory):
		 * <code>
		 * var muc:MUCExtension = new MUCExtension();
		 * muc.history = true;
		 * muc.maxchars = 0;
		 * _room.joinWithExplicitMUCExtension(false, mucExt);
		 * </code>
		 *
		 * @param	createReserved Set to true if you wish to create and configure a reserved room
		 * @param	mucExtension The customized MUC extension to send with initial presence to the room.
		 * @param	joinPresenceExtensions An array of additional extensions to send with the initial presence to the room.
		 * @return A boolean indicating whether the join attempt was successfully sent.
		 */
		public function joinWithExplicitMUCExtension( createReserved:Boolean, mucExtension:MUCExtension, joinPresenceExtensions:Array = null ):Boolean
		{
			if ( !_connection.isActive() || isActive )
			{
				return false;
			}

			myIsReserved = createReserved;

			var joinPresence:Presence = new Presence( userJID.escaped );
			joinPresence.addExtension( mucExtension );

			if ( joinPresenceExtensions != null )
			{
				for each ( var joinExt:*in joinPresenceExtensions )
				{
					joinPresence.addExtension( joinExt );
				}
			}

			_connection.send( joinPresence );
			return true;
		}

		/**
		 * Kicks an occupant out of the room, assuming that the user has necessary
		 * permissions in order to do so. If the user does not, the server will return an error.
		 *
		 * @param	occupantNick The nickname of the room occupant to kick
		 * @param	reason The reason for the kick
		 */
		public function kickOccupant( occupantNick:String, reason:String ):void
		{
			if ( isActive )
			{
				var iq:IQ = new IQ( roomJID.escaped, IQ.TYPE_SET, XMPPStanza.generateID( "kick_occupant_" ) );
				var adminExt:MUCAdminExtension = new MUCAdminExtension( iq.getNode() );
				adminExt.addItem( null, MUC.ROLE_NONE, occupantNick, null, null, reason );
				iq.addExtension( adminExt );
				_connection.send( iq );
			}
		}

		/**
		 * Leaves the current conference room, assuming that the user has joined one.
		 * If the user is not currently in a room, this method does nothing.
		 */
		public function leave():void
		{
			if ( isActive )
			{
				var leavePresence:Presence = new Presence( userJID.escaped, null, Presence.TYPE_UNAVAILABLE );
				_connection.send( leavePresence );

				// Clear out the roster items
				removeAll();
				_connection.removeEventListener( MessageEvent.MESSAGE, handleEvent );
				_connection.removeEventListener( DisconnectionEvent.DISCONNECT, handleEvent );
			}
		}

		/**
		 * Requests an affiliation list for a given affiliation with with room.
		 * This will either dispatch the event <code>RoomEvent.AFFILIATIONS</code> or
		 * <code>RoomEvent.ADMIN_ERROR</code> depending on the result of the request.
		 *
		 * @param	affiliation Use one of the following affiliations: <code>Room.AFFILIATION_NONE</code>,
		 * <code>Room.AFFILIATION_OUTCAST</code>,
		 * <code>Room.AFFILIATION_MEMBER</code>,
		 * <code>Room.AFFILIATION_ADMIN</code>,
		 * <code>Room.AFFILIATION_OWNER</code>
		 * @see	#revoke
		 * @see	#grant
		 * @see	#affiliations
		 */
		public function requestAffiliations( affiliation:String ):void
		{
			var iq:IQ = new IQ( roomJID.escaped, IQ.TYPE_GET, null, requestAffiliations_response, requestAffiliations_error );
			var adminExt:MUCAdminExtension = new MUCAdminExtension();

			adminExt.addItem( affiliation );

			iq.addExtension( adminExt );
			_connection.send( iq );
		}

		/**
		 * Requests a configuration form from the room.	Listen to <code>configureRoom</code>
		 * event to fill out the form then call either <code>configure</code> or
		 * <code>cancelConfiguration</code> to complete the configuration process
		 *
		 * You must be joined to the room and have the owner affiliation to request
		 * a configuration form
		 *
		 * @see	#configureRoom
		 * @see	#configure
		 * @see	#cancelConfiguration
		 */
		public function requestConfiguration():void
		{
			var iq:IQ = new IQ( roomJID.escaped, IQ.TYPE_GET, null, requestConfiguration_response, requestConfiguration_error );
			var ownerExt:MUCOwnerExtension = new MUCOwnerExtension();

			iq.addExtension( ownerExt );

			_connection.send( iq );
		}

		/**
		 * Revokes all affiliations from the JIDs. This is the same as:
		 * <code>grant( Room.AFFILIATION_NONE, jids )</code>
		 *
		 * <p>If the process could not be completed, the room will dispatch the event
		 * <code>RoomEvent.ADMIN_ERROR</code>. Note: if the JID is banned from this room,
		 * then this will also revoke the banned status.</p>
		 *
		 * @param	jids An array of UnescapedJIDs to revoke affiliations from
		 * @see	#grant
		 * @see	#allow
		 */
		public function revoke( jids:Array ):void
		{
			grant( Room.AFFILIATION_NONE, jids );
		}

		/**
		 * Sends a message to the conference room.
		 *
		 * @param	body The message body
		 * @param	htmlBody The message body with HTML formatting
		 */
		public function sendMessage( body:String = null, htmlBody:String = null ):void
		{
			if ( isActive )
			{
				var message:Message = new Message( roomJID.escaped, null, body, htmlBody, Message.TYPE_GROUPCHAT );
				_connection.send( message );
			}
		}

		/**
		 * Sends a message to the conference room with an extension attached.
		 * Use this method in conjunction with the <code>getMessage</code> method.
		 *
		 * @param	message The message to send
		 */
		public function sendMessageWithExtension( message:Message ):void
		{
			if ( isActive )
			{
				_connection.send( message );
			}
		}

		/**
		 * Sends a private message to a specific participant in the conference room.
		 *
		 * @param	recipientNickname The conference room nickname of the recipient who should
		 * receive the private message
		 * @param	body The message body
		 * @param	htmlBody The message body with HTML formatting
		 */
		public function sendPrivateMessage( recipientNickname:String, body:String = null, htmlBody:String = null ):void
		{
			if ( isActive )
			{
				var message:Message = new Message( new EscapedJID( roomJID + "/" + recipientNickname ), null, body, htmlBody, Message.TYPE_CHAT );
				_connection.send( message );
			}
		}

		/**
		 * In a moderated room, sets voice status to a particular occupant, assuming the user
		 * has the necessary permissions to do so.
		 *
		 * @param	occupantNick The nickname of the occupant to give voice
		 * @param	voice Whether to add voice (true) or remove voice (false). Having voice means
		 * that the user is actually able to talk. Without voice the user is effectively muted.
		 */
		public function setOccupantVoice( occupantNick:String, voice:Boolean ):void
		{
			if ( isActive )
			{
				var iq:IQ = new IQ( roomJID.escaped, IQ.TYPE_SET, XMPPStanza.generateID( "voice_" ) );
				var adminExt:MUCAdminExtension = new MUCAdminExtension( iq.getNode() );
				adminExt.addItem( null, voice ? MUC.ROLE_PARTICIPANT : MUC.ROLE_VISITOR, occupantNick );
				iq.addExtension( adminExt );
				_connection.send( iq );
			}
		}

		/**
		 * @private
		 */
		override public function toString():String
		{
			return '[object Room]';
		}

		/**
		 * @private
		 *
		 * The default error handler for admin IQ messages.
		 * Dispatches the adminError event.
		 */
		private function admin_error( iq:IQ ):void
		{
			var event:RoomEvent = new RoomEvent( RoomEvent.ADMIN_ERROR );
			event.errorCondition = iq.errorCondition;
			event.errorMessage = iq.errorMessage;
			event.errorType = iq.errorType;
			event.errorCode = iq.errorCode;
			dispatchEvent( event );
		}

		/**
		 * @private
		 *
		 * The default response handler for admin IQ messages.
		 */
		private function admin_response( iq:IQ ):void
		{
		}

		/**
		 * @private
		 */
		private function ban_error( iq:IQ ):void
		{
			admin_error( iq );
		}

		/**
		 * @private
		 */
		private function ban_response( iq:IQ ):void
		{
		}

		/**
		 * @private
		 */
		private function configure_error( iq:IQ ):void
		{
			admin_error( iq );
		}

		/**
		 * @private
		 */
		private function configure_response( iq:IQ ):void
		{
			var event:RoomEvent = new RoomEvent( RoomEvent.CONFIGURE_ROOM_COMPLETE );
			dispatchEvent( event );
		}

		/**
		 * Helper to dispatch a property change event.
		 * @param	name
		 * @param	newValue
		 * @param	oldValue
		 */
		private function dispatchChangeEvent( name:String, newValue:*, oldValue:* ):void
		{
			var event:PropertyChangeEvent = new PropertyChangeEvent( PropertyChangeEvent.CHANGE );
			event.name = name;
			event.newValue = newValue;
			event.oldValue = oldValue;
			dispatchEvent( event );
		}

		/**
		 * @private
		 */
		private function grant_error( iq:IQ ):void
		{
			if( affiliationExtension is MUCAdminExtension && affiliationArgs.length > 0 )
			{
				affiliationExtension = new MUCOwnerExtension();
				grant.apply( null, affiliationArgs );
			}
			else
			{
				affiliationArgs = [];

				admin_error( iq );
			}
		}

		/**
		 * @private
		 */
		private function grant_response( iq:IQ ):void
		{
			affiliationArgs = [];
			
			var event:RoomEvent = new RoomEvent( RoomEvent.AFFILIATION_CHANGE_COMPLETE );
			dispatchEvent( event );
		}

		/**
		 * @private
		 *
		 * @param	eventObj
		 */
		private function handleEvent( eventObj:Object ):void
		{
			var userExt:MUCUserExtension;

			switch ( eventObj.type )
			{
				case "message":
					var message:Message = eventObj.data;
					var userExts:Array = message.getAllExtensionsByNS( MUCUserExtension.NS );
					var roomEvent:RoomEvent;

					// Check to see that the message is from this room
					if ( isThisRoom( message.from.unescaped ))
					{
						if ( message.type == Message.TYPE_GROUPCHAT )
						{
							// Check for a subject change
							if ( message.subject != null )
							{
								_subject = message.subject;
								roomEvent = new RoomEvent( RoomEvent.SUBJECT_CHANGE );
								roomEvent.subject = message.subject;
								dispatchEvent( roomEvent );
							}
							else
							{
								//silently ignore "room is not anonymous" message, identified by status code 100
								//Clients should display that information in their UI based on the appropriate room property
								if ( !userExts || userExts.length == 0 || !( userExts[ 0 ].hasStatusCode( 100 )))
								{
									roomEvent = new RoomEvent( RoomEvent.GROUP_MESSAGE );
									roomEvent.nickname = message.from.resource;
									roomEvent.data = message;
									dispatchEvent( roomEvent );
								}
							}
						}
						else if ( message.type == Message.TYPE_NORMAL )
						{
							var form:Array = message.getAllExtensionsByNS( FormExtension.NS )[ 0 ];
							if ( form )
							{
								roomEvent = new RoomEvent( RoomEvent.CONFIGURE_ROOM );
								roomEvent.data = form;
								dispatchEvent( roomEvent );
							}
						}
						else if ( message.type == Message.TYPE_CHAT )
						{
							roomEvent = new RoomEvent( RoomEvent.PRIVATE_MESSAGE );
							roomEvent.data = message;
							dispatchEvent( roomEvent );
						}
					}
					else if ( isThisUser( message.to.unescaped ) && message.type == Message.TYPE_CHAT )
					{
						// It could be a private message via the conference
						roomEvent = new RoomEvent( RoomEvent.PRIVATE_MESSAGE );
						roomEvent.data = message;
						dispatchEvent( roomEvent );
					}
					else
					{
						// Could be a decline to a previous invite
						if ( userExts != null && userExts.length > 0 )
						{
							userExt = userExts[ 0 ];
							if ( userExt && userExt.type == MUCUserExtension.TYPE_DECLINE )
							{
								roomEvent = new RoomEvent( RoomEvent.DECLINED );
								roomEvent.from = userExt.reason;
								roomEvent.reason = userExt.reason;
								roomEvent.data = message;
								dispatchEvent( roomEvent );
							}
						}
					}
					break;

				case "presence":
					//trace("ROOM presence: " + presence.from + " : " + nickname);
					for each ( var presence:Presence in eventObj.data )
					{
						if ( presence.type == Presence.TYPE_ERROR )
						{
							switch ( presence.errorCode )
							{
								case 401:
									roomEvent = new RoomEvent( RoomEvent.PASSWORD_ERROR );
									break;

								case 403:
									roomEvent = new RoomEvent( RoomEvent.BANNED_ERROR );
									break;

								case 404:
									roomEvent = new RoomEvent( RoomEvent.LOCKED_ERROR );
									break;

								case 407:
									roomEvent = new RoomEvent( RoomEvent.REGISTRATION_REQ_ERROR );
									break;

								case 409:
									roomEvent = new RoomEvent( RoomEvent.NICK_CONFLICT );
									roomEvent.nickname = nickname;
									break;

								case 503:
									roomEvent = new RoomEvent( RoomEvent.MAX_USERS_ERROR );
									break;

								default:
									roomEvent = new RoomEvent( "MUC Error of type: " + presence.errorCode );
									break;
							}
							roomEvent.errorCode = presence.errorCode;
							roomEvent.errorMessage = presence.errorMessage;
							dispatchEvent( roomEvent );
						}
						else if ( isThisRoom( presence.from.unescaped ))
						{
							// If the presence has our pending nickname, nickname change went through
							if ( presence.from.resource == pendingNickname )
							{
								_nickname = pendingNickname;
								pendingNickname = null;
							}

							userExt = presence.getAllExtensionsByNS( MUCUserExtension.NS )[ 0 ];
							for each ( var status:MUCStatus in userExt.statuses )
							{
								switch ( status.code )
								{
									case 100:
									case 172:
										_anonymous = false;
										break;
										
									case 174:
										_anonymous = true;
										break;
										
									case 201:
										unlockRoom( myIsReserved );
										break;
								}
							}

							updateRoomRoster( presence );

							if ( presence.type == Presence.TYPE_UNAVAILABLE && isActive &&
								isThisUser( presence.from.unescaped ))
							{
								//trace("Room: becoming inactive: " + presence.getNode());
								setActive( false );
								if ( userExt.type == MUCUserExtension.TYPE_DESTROY )
								{
									roomEvent = new RoomEvent( RoomEvent.ROOM_DESTROYED );
								}
								else
								{
									roomEvent = new RoomEvent( RoomEvent.ROOM_LEAVE );
								}
								dispatchEvent( roomEvent );
								_connection.removeEventListener( PresenceEvent.PRESENCE,
																  handleEvent );
							}
						}
					}
					break;

				case "disconnection":
					// The server disconnected, so we are no longer active
					setActive( false );
					removeAll();
					roomEvent = new RoomEvent( RoomEvent.ROOM_LEAVE );
					dispatchEvent( roomEvent );
					break;
			}
		}

		/**
		 * @private
		 */
		private function requestAffiliations_error( iq:IQ ):void
		{
			admin_error( iq );
		}

		/**
		 * @private
		 */
		private function requestAffiliations_response( iq:IQ ):void
		{
			if ( iq.type == IQ.TYPE_RESULT )
			{
				var adminExt:MUCAdminExtension = iq.getAllExtensionsByNS( MUCAdminExtension.NS )[ 0 ];
				var items:Array = adminExt.getAllItems();
				// trace("Affiliates: " + items);
				var event:RoomEvent = new RoomEvent( RoomEvent.AFFILIATIONS );
				event.data = items;
				dispatchEvent( event );
			}
		}

		/**
		 * @private
		 */
		private function requestConfiguration_error( iq:IQ ):void
		{
			admin_error( iq );
		}

		/**
		 * @private
		 */
		private function requestConfiguration_response( iq:IQ ):void
		{
			var ownerExt:MUCOwnerExtension = iq.getAllExtensionsByNS( MUCOwnerExtension.NS )[ 0 ];
			var form:FormExtension = ownerExt.getAllExtensionsByNS( FormExtension.NS )[ 0 ];

			if ( form.type == FormExtension.TYPE_REQUEST )
			{
				var event:RoomEvent = new RoomEvent( RoomEvent.CONFIGURE_ROOM );
				event.data = form;
				dispatchEvent( event );
			}
		}

		/**
		 * @private
		 *
		 * @param	state
		 */
		private function setActive( state:Boolean ):void
		{
			var oldActive:Boolean = _active;
			_active = state;
			if( _active != oldActive ) dispatchChangeEvent( "active", _active, oldActive );
		}

		/**
		 * @private
		 *
		 * Room owner (creation/configuration/destruction) methods
		 * @see	http://xmpp.org/extensions/xep-0045.html#createroom
		 */
		private function unlockRoom( isReserved:Boolean ):void
		{
			if ( isReserved )
			{
				requestConfiguration();
			}
			else
			{
				// Send an empty configuration form to open the instant room

				// The IQ.result for this request will signify that the room is
				// unlocked.	Sometimes there are messages that are sent before
				// the request is returned.	It may be smart to either block those
				// messages, or provide 2 events "beginConfiguration" and "endConfiguration"
				// so the application can decide to block configuration messages

				var iq:IQ = new IQ( roomJID.escaped, IQ.TYPE_SET );
				var ownerExt:MUCOwnerExtension = new MUCOwnerExtension();
				var form:FormExtension = new FormExtension();

				form.type = FormExtension.TYPE_SUBMIT;

				ownerExt.addExtension( form );
				iq.addExtension( ownerExt );
				_connection.send( iq );
			}
		}

		/**
		 * @private
		 *
		 * If we receive a presence about ourselves, it means
		 * a) we've joined the room; tell everyone, then proceed as usual
		 * b) we're being told we left, which we handle in the caller
		 * @param	aPresence
		 */
		private function updateRoomRoster( aPresence:Presence ):void
		{
			var userNickname:String = aPresence.from.unescaped.resource;
			var userExts:Array = aPresence.getAllExtensionsByNS( MUCUserExtension.NS );
			var item:MUCItem = userExts[ 0 ].getAllItems()[ 0 ];
			var roomEvent:RoomEvent;

			if ( isThisUser( aPresence.from.unescaped ))
			{
				var oldAffiliation:String = _affiliation;
				_affiliation = item.affiliation;
				if( _affiliation != oldAffiliation ) dispatchChangeEvent( "affiliation", _affiliation, oldAffiliation );

				var oldRole:String = _role;
				_role = item.role;
				if( _role != oldRole ) dispatchChangeEvent( "role", _role, oldRole );

				if ( !isActive && aPresence.type != Presence.TYPE_UNAVAILABLE )
				{
					setActive( true );
					roomEvent = new RoomEvent( RoomEvent.ROOM_JOIN );
					dispatchEvent( roomEvent );
				}
			}

			var occupant:RoomOccupant = getOccupantNamed( userNickname );

			//if we already know about this occupant, we're either being told about them leaving, or about a presence update
			if ( occupant )
			{
				if ( aPresence.type == Presence.TYPE_UNAVAILABLE )
				{
					removeItemAt( getItemIndex( occupant ));

					var userExt:MUCUserExtension = aPresence.getAllExtensionsByNS( MUCUserExtension.NS )[ 0 ];
					for each ( var status:MUCStatus in userExt.statuses )
					{
						switch ( status.code )
						{
							// If the user left as a result of a ban or kick, we dispatch a USER_BANNED/USER_KICKED event instead of a USER_DEPARTURE event
							case 301:
								roomEvent = new RoomEvent( RoomEvent.USER_BANNED );
								roomEvent.nickname = userNickname;
								roomEvent.data = aPresence;
								dispatchEvent( roomEvent );
								return;

							case 307:
								roomEvent = new RoomEvent( RoomEvent.USER_KICKED );
								roomEvent.nickname = userNickname;
								roomEvent.data = aPresence;
								dispatchEvent( roomEvent );
								return;
						}
					}

					// Notify listeners that a user has left the room
					roomEvent = new RoomEvent( RoomEvent.USER_DEPARTURE );
					roomEvent.nickname = userNickname;
					roomEvent.data = aPresence;
					dispatchEvent( roomEvent );
				}
				else
				{
					occupant.affiliation = item.affiliation;
					occupant.role = item.role;
					occupant.show = aPresence.show;

					// Notify listeners that a user's presence has been updated
					roomEvent = new RoomEvent( RoomEvent.USER_PRESENCE_CHANGE );
					roomEvent.nickname = userNickname;
					roomEvent.data = aPresence;
					dispatchEvent( roomEvent );
				}
			}
			else if ( aPresence.type != Presence.TYPE_UNAVAILABLE )
			{
				// We didn't know about this occupant yet, so we add them, then let everyone know that we did.
				addItem( new RoomOccupant( userNickname, aPresence.show, item.affiliation,
										   item.role, item.jid ? item.jid.unescaped :
										   null, this ));

				roomEvent = new RoomEvent( RoomEvent.USER_JOIN );
				roomEvent.nickname = userNickname;
				roomEvent.data = aPresence;
				dispatchEvent( roomEvent );
			}
		}

		/**
		 * Gets the user's affiliation for this room.
		 * Possible affiliations are "owner", "admin", "member", and "outcast".
		 * It is also possible to have no defined affiliation.
		 */
		public function get affiliation():String
		{
			return _affiliation;
		}

		/**
		 * Whether the room shows full JIDs or not.
		 */
		public function get anonymous():Boolean
		{
			return _anonymous;
		}

		/**
		 * A reference to the XMPPConnection being used for incoming/outgoing XMPP data.
		 *
		 * @see	org.igniterealtime.xiff.core.XMPPConnection
		 */
		public function get connection():XMPPConnection
		{
			return _connection;
		}
		public function set connection( value:XMPPConnection ):void
		{
			if ( _connection != null )
			{
				_connection.removeEventListener( MessageEvent.MESSAGE, handleEvent );
				_connection.removeEventListener( PresenceEvent.PRESENCE, handleEvent );
				_connection.removeEventListener( DisconnectionEvent.DISCONNECT, handleEvent );
			}

			_connection = value;

			_connection.addEventListener( MessageEvent.MESSAGE, handleEvent, false, 0, true );
			_connection.addEventListener( PresenceEvent.PRESENCE, handleEvent, false, 0, true );
			_connection.addEventListener( DisconnectionEvent.DISCONNECT, handleEvent, false, 0, true );

			//String baserepo = "http://"+_connection.server+":9090/webdav/rooms/"+conferenceServer.replace("."+_connection.server,"")+"/"+roomName+"/";
			//_fileRepo = new RoomFileRepository( baserepo );
		}

		/**
		 * The conference server to use for this room. Usually, this is a subdomain of
		 * the primary XMPP server, like conference.myserver.com.
		 */
		public function get conferenceServer():String
		{
			return _roomJID.domain;
		}
		public function set conferenceServer( value:String ):void
		{
			roomJID = new UnescapedJID( roomName + "@" + value );
		}

		/**
		 * Determines whether the connection to the room is active - that is, the user
		 * is connected and has joined the room.
		 */
		public function get isActive():Boolean
		{
			return _active;
		}

		/**
		 * The nickname to use when joining.
		 */
		public function get nickname():String
		{
			return _nickname == null ? _connection.username : _nickname;
		}
		public function set nickname( value:String ):void
		{
			if ( isActive )
			{
				pendingNickname = value;
				var presence:Presence = new Presence( new EscapedJID( userJID + "/" + value ) );
				_connection.send( presence );
			}
			else
			{
				_nickname = value;
			}
		}

		/**
		 * The password.
		 */
		public function get password():String
		{
			return _password;
		}
		public function set password( value:String ):void
		{
			_password = value;
		}

		/**
		 * Gets the user's role in the conference room.
		 * Possible roles are "visitor", "participant", "moderator" or no defined role.
		 */
		public function get role():String
		{
			return _role;
		}

		/**
		 * The unescaped JID of the room. <code>room&at;conference.server</code>
		 * Set this after initiating a new Room.
		 */
		public function get roomJID():UnescapedJID
		{
			return _roomJID;
		}
		public function set roomJID( jid:UnescapedJID ):void
		{
			_roomJID = jid;
		}

		/**
		 * The room name that should be used when joining.
		 */
		public function get roomName():String
		{
			return _roomJID.node;
		}
		public function set roomName( value:String ):void
		{
			roomJID = new UnescapedJID( value + "@" + conferenceServer );
		}

		/**
		 * The subject.
		 */
		public function get subject():String
		{
			return _subject;
		}

		/**
		 * Get the JID of the conference room user.
		 */
		public function get userJID():UnescapedJID
		{
			if (_roomJID != null)
			{
				return new UnescapedJID( _roomJID.bareJID + "/" + nickname );
			}
			return null;
		}
	}
}
