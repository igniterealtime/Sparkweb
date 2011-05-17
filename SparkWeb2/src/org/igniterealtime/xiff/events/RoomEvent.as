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
package org.igniterealtime.xiff.events
{
	import flash.events.Event;

	public class RoomEvent extends Event
	{
		public static const ADMIN_ERROR:String = "adminError";

		public static const AFFILIATION_CHANGE_COMPLETE:String = "affiliationChangeComplete";

		public static const AFFILIATIONS:String = "affiliations";

		public static const BANNED_ERROR:String = "bannedError";

		public static const CONFIGURE_ROOM:String = "configureRoom";
		
		public static const CONFIGURE_ROOM_COMPLETE:String = "configureRoomComplete";

		public static const DECLINED:String = "declined";

		public static const GROUP_MESSAGE:String = "groupMessage";

		public static const LOCKED_ERROR:String = "lockedError";

		public static const MAX_USERS_ERROR:String = "maxUsersError";

		public static const NICK_CONFLICT:String = "nickConflict";

		public static const PASSWORD_ERROR:String = "passwordError";

		public static const PRIVATE_MESSAGE:String = "privateMessage";

		public static const REGISTRATION_REQ_ERROR:String = "registrationReqError";

		public static const ROOM_DESTROYED:String = "roomDestroyed";

		public static const ROOM_JOIN:String = "roomJoin";

		public static const ROOM_LEAVE:String = "roomLeave";

		public static const SUBJECT_CHANGE:String = "subjectChange";

		public static const USER_BANNED:String = "userBanned";

		public static const USER_DEPARTURE:String = "userDeparture";

		public static const USER_JOIN:String = "userJoin";

		public static const USER_KICKED:String = "userKicked";
		
		public static const USER_PRESENCE_CHANGE:String = "userPresenceChange";

		private var _data:*;

		private var _errorCode:uint;

		private var _errorCondition:String;

		private var _errorMessage:String;

		private var _errorType:String;

		private var _from:String;

		private var _nickname:String;

		private var _reason:String;

		private var _subject:String;

		public function RoomEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone():Event
		{
			var event:RoomEvent = new RoomEvent( type, bubbles, cancelable );
			event.subject = _subject;
			event.data = _data;
			event.errorCondition = _errorCondition;
			event.errorMessage = _errorMessage;
			event.errorType = _errorType;
			event.errorCode = _errorCode;
			event.nickname = _nickname;
			event.from = _from;
			event.reason = _reason;
			return event;
		}

		/**
		 * Data type can be <code>Message</code>, <code>Array</code>, or <code>Presence</code>
		 * depending of the context.
		 * @see org.igniterealtime.xiff.data.Message
		 * @see org.igniterealtime.xiff.data.Presence
		 */
		public function get data():*
		{
			return _data;
		}
		public function set data( value:* ):void
		{
			_data = value;
		}

		public function get errorCode():uint
		{
			return _errorCode;
		}

		public function set errorCode( value:uint ):void
		{
			_errorCode = value;
		}

		public function get errorCondition():String
		{
			return _errorCondition;
		}

		public function set errorCondition( value:String ):void
		{
			_errorCondition = value;
		}

		public function get errorMessage():String
		{
			return _errorMessage;
		}

		public function set errorMessage( value:String ):void
		{
			_errorMessage = value;
		}

		public function get errorType():String
		{
			return _errorType;
		}

		public function set errorType( value:String ):void
		{
			_errorType = value;
		}

		public function get from():String
		{
			return _from;
		}

		public function set from( value:String ):void
		{
			_from = value;
		}

		public function get nickname():String
		{
			return _nickname;
		}

		public function set nickname( value:String ):void
		{
			_nickname = value;
		}

		public function get reason():String
		{
			return _reason;
		}

		public function set reason( value:String ):void
		{
			_reason = value;
		}

		public function get subject():String
		{
			return _subject;
		}

		public function set subject( value:String ):void
		{
			_subject = value;
		}

		override public function toString():String
		{
			return '[RoomEvent type="' + type + '" bubbles=' + bubbles + ' cancelable=' +
				cancelable + ' eventPhase=' + eventPhase + ']';
		}
	}
}
