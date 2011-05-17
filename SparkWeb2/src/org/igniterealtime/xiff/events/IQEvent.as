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

	import org.igniterealtime.xiff.data.IExtension;
	import org.igniterealtime.xiff.data.IQ;

	public class IQEvent extends Event
	{
		private var _data:IExtension;

		private var _iq:IQ;

		public function IQEvent( type:String )
		{
			super( type, false, false );
		}

		override public function clone():Event
		{
			var event:IQEvent = new IQEvent( type );
			event.data = _data;
			event.iq = _iq;
			return event;
		}

		/**
		 * Extension related to this event
		 */
		public function get data():IExtension
		{
			return _data;
		}
		public function set data( value:IExtension ):void
		{
			_data = value;
		}

		public function get iq():IQ
		{
			return _iq;
		}

		public function set iq( value:IQ ):void
		{
			_iq = value;
		}

		override public function toString():String
		{
			return '[IQEvent type="' + type + '" bubbles=' + bubbles + ' cancelable=' +
				cancelable + ' eventPhase=' + eventPhase + ']';
		}
	}
}
