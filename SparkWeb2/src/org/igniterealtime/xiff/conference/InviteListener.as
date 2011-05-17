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
	import flash.events.EventDispatcher;

	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.muc.MUCUserExtension;
	import org.igniterealtime.xiff.events.InviteEvent;
	import org.igniterealtime.xiff.events.MessageEvent;

	/**
	 * Dispatched when an invitations has been received.
	 *
	 * @eventType org.igniterealtime.xiff.InviteEvent.INVITED
	 * @see	org.igniterealtime.xiff.conference.Room
	 * @see	org.igniterealtime.xiff.conference.Room.#invite
	 */
	[Event( name="invited",type="org.igniterealtime.xiff.events.InviteEvent" )]


	/**
	 * Manages the dispatching of events during invitations.  Add event
	 * listeners to an instance of this class to monitor invite and decline
	 * events.
	 *
	 * <p>You only need a single instance of this class to listen for all invite
	 * or decline events.</p>
	 */
	public class InviteListener extends EventDispatcher
	{
		private var _connection:XMPPConnection;

		/**
		 *
		 * @param	aConnection	An XMPPConnection instance that is providing the primary server
		 * connection.
		 */
		public function InviteListener( aConnection:XMPPConnection = null )
		{
			if ( aConnection != null )
			{
				connection = aConnection;
			}
		}
		
		/**
		 *
		 * @param	event
		 */
		private function handleEvent( event:Object ):void
		{
			switch ( event.type )
			{
				case MessageEvent.MESSAGE:

					try
					{
						var message:Message = event.data as Message;
						var exts:Array = message.getAllExtensionsByNS( MUCUserExtension.NS );
						if ( !exts || exts.length < 0 )
						{
							return;
						}
						var muc:MUCUserExtension = exts[ 0 ];
						if ( muc.type == MUCUserExtension.TYPE_INVITE )
						{
							var room:Room = new Room( _connection );
							room.roomJID = message.from.unescaped;
							room.password = muc.password;

							var inviteEvent:InviteEvent = new InviteEvent();
							inviteEvent.from = muc.from.unescaped;
							inviteEvent.reason = muc.reason;
							inviteEvent.room = room;
							inviteEvent.data = message;
							dispatchEvent( inviteEvent );
						}
					}
					catch ( error:Error )
					{
						trace( error.getStackTrace());
					}

					break;
			}
		}

		/**
		 * A reference to the XMPPConnection being used for incoming/outgoing XMPP data.
		 *
		 * @return	The XMPPConnection used
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
			}
			_connection = value;
			_connection.addEventListener( MessageEvent.MESSAGE, handleEvent );
		}
	}
}
