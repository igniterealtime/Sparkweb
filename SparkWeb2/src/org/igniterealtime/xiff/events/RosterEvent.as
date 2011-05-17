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

	import org.igniterealtime.xiff.core.UnescapedJID;

	public class RosterEvent extends Event
	{
		public static const ROSTER_LOADED:String = "rosterLoaded";

		public static const SUBSCRIPTION_DENIAL:String = "subscriptionDenial";

		public static const SUBSCRIPTION_REQUEST:String = "subscriptionRequest";

		public static const SUBSCRIPTION_REVOCATION:String = "subscriptionRevocation";

		public static const USER_ADDED:String = "userAdded";

		public static const USER_AVAILABLE:String = "userAvailable";

		public static const USER_PRESENCE_UPDATED:String = "userPresenceUpdated";

		public static const USER_REMOVED:String = "userRemoved";

		public static const USER_SUBSCRIPTION_UPDATED:String = "userSubscriptionUpdated";

		public static const USER_UNAVAILABLE:String = "userUnavailable";

		private var _data:*;

		private var _jid:UnescapedJID;

		public function RosterEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone():Event
		{
			var event:RosterEvent = new RosterEvent( type, bubbles, cancelable );
			event.data = _data;
			event.jid = _jid;
			return event;
		}

		/**
		 * Data can be of type:
		 * <ul>
		 * <li><code>Presence</code></li>
		 * <li><code>RosterItemVO</code></li>
		 * <li>...</li>
		 * </ul>
		 * @see org.igniterealtime.xiff.data.Presence
		 * @see org.igniterealtime.xiff.data.im.RosterItemVO
		 */
		public function get data():*
		{
			return _data;
		}
		public function set data( value:* ):void
		{
			_data = value;
		}

		public function get jid():UnescapedJID
		{
			return _jid;
		}

		public function set jid( value:UnescapedJID ):void
		{
			_jid = value;
		}

		override public function toString():String
		{
			return '[RosterEvent type="' + type + '" bubbles=' + bubbles + ' cancelable=' +
				cancelable + ' eventPhase=' + eventPhase + ']';
		}
	}
}
