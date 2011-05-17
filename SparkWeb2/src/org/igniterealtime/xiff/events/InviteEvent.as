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

	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.Message;

	public class InviteEvent extends Event
	{
		public static const INVITED:String = "invited";

		private var _data:Message;

		private var _from:UnescapedJID;

		private var _reason:String;

		private var _room:Room;

		public function InviteEvent()
		{
			super( INVITED );
		}

		override public function clone():Event
		{
			var event:InviteEvent = new InviteEvent();
			event.from = _from;
			event.reason = _reason;
			event.room = _room;
			event.data = _data;
			return event;
		}

		/**
		 * Message that is possibly included in the invitation.
		 */
		public function get data():Message
		{
			return _data;
		}
		public function set data( value:Message ):void
		{
			_data = value;
		}

		public function get from():UnescapedJID
		{
			return _from;
		}
		public function set from( value:UnescapedJID ):void
		{
			_from = value;
		}

		/**
		 * A possible reason given by the inviting party
		 */
		public function get reason():String
		{
			return _reason;
		}
		public function set reason( value:String ):void
		{
			_reason = value;
		}

		/**
		 * The room in which the invitation is targeted.
		 */
		public function get room():Room
		{
			return _room;
		}
		public function set room( value:Room ):void
		{
			_room = value;
		}

		override public function toString():String
		{
			return '[InviteEvent type="' + type + '" bubbles=' + bubbles + ' cancelable=' +
				cancelable + ' eventPhase=' + eventPhase + ']';
		}
	}
}
