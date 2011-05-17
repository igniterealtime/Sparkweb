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

	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.im.Contact;
	import org.igniterealtime.xiff.data.im.RosterItemVO;

	/**
	 * A person in a room
	 */
	public class RoomOccupant extends EventDispatcher implements Contact
	{
		private var _affiliation:String;

		private var _jid:UnescapedJID;

		private var _nickname:String;

		private var _role:String;

		private var _room:Room;

		private var _show:String;

		private var _uid:String;

		/**
		 *
		 * @param	nickname
		 * @param	show
		 * @param	affiliation
		 * @param	role
		 * @param	jid
		 * @param	room
		 */
		public function RoomOccupant( nickname:String, show:String, affiliation:String,
										role:String, jid:UnescapedJID, room:Room )
		{
			this.displayName = nickname;
			this.show = show;
			this.affiliation = affiliation;
			this.role = role;
			this.jid = jid;
			_room = room;
		}

		/**
		 *
		 */
		public function get affiliation():String
		{
			return _affiliation;
		}
		public function set affiliation( value:String ):void
		{
			_affiliation = value;
		}

		/**
		 * TODO: rename as nickname
		 */
		public function get displayName():String
		{
			return _nickname;
		}
		public function set displayName( value:String ):void
		{
			_nickname = value;
		}

		/**
		 *
		 */
		public function get jid():UnescapedJID
		{
			return _jid;
		}
		public function set jid( value:UnescapedJID ):void
		{
			_jid = value;
		}

		/**
		 *
		 */
		public function get online():Boolean
		{
			return true;
		}
		public function set online( value:Boolean ):void
		{
			//RoomOccupants can't exist unless they're online
		}

		
		/**
		 *
		 */
		public function get role():String
		{
			return _role;
		}
		public function set role( value:String ):void
		{
			_role = value;
		}

		/**
		 *
		 */
		public function get room():Room
		{
			return _room;
		}
		public function set room( value:Room ):void
		{
			_room = value;
		}

		/**
		 * If there isn't a roster item associated with this room occupant
		 * (for example, if the room is anonymous), this will return null
		 */
		public function get rosterItem():RosterItemVO
		{
			if ( !_jid )
			{
				return null;
			}
			return RosterItemVO.get( _jid, true );
		}

		/**
		 *
		 */
		public function get show():String
		{
			return _show;
		}
		public function set show( value:String ):void
		{
			_show = value;
		}

		/**
		 *
		 */
		public function get uid():String
		{
			return _uid;
		}
		public function set uid( value:String ):void
		{
			_uid = value;
		}
	}
}
