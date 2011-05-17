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

	import org.igniterealtime.xiff.vcard.VCard;

	public class VCardEvent extends Event
	{
		public static const LOADED:String = "loaded";

		public static const SAVED:String = "saved";

		public static const SAVE_ERROR:String = "saveError";

		private var _vcard:VCard;

		public function VCardEvent( type:String, vcard:VCard, bubbles:Boolean, cancelable:Boolean )
		{
			super( type, bubbles, cancelable )
			_vcard = vcard;
		}

		override public function clone():Event
		{
			return new VCardEvent( type, _vcard, bubbles, cancelable );
		}

		override public function toString():String
		{
			return '[VCardEvent type="' + type + '" bubbles=' + bubbles + ' cancelable=' +
				cancelable + ' eventPhase=' + eventPhase + ']';
		}

		public function get vcard():VCard
		{
			return _vcard;
		}
	}
}
