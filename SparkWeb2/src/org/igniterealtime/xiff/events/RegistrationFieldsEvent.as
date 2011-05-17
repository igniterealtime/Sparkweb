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

	import org.igniterealtime.xiff.data.register.RegisterExtension;

	public class RegistrationFieldsEvent extends Event
	{
		public static const REG_FIELDS:String = "registrationFields";

		private var _data:RegisterExtension;

		private var _fields:Array;

		public function RegistrationFieldsEvent()
		{
			super( RegistrationFieldsEvent.REG_FIELDS, false, false );
		}

		override public function clone():Event
		{
			var event:RegistrationFieldsEvent = new RegistrationFieldsEvent();
			event.data = _data;
			event.fields = _fields;
			return event;
		}

		public function get data():RegisterExtension
		{
			return _data;
		}

		public function set data( value:RegisterExtension ):void
		{
			_data = value;
		}

		public function get fields():Array
		{
			return _fields;
		}

		public function set fields( value:Array ):void
		{
			_fields = value;
		}

		override public function toString():String
		{
			return '[RegistrationFieldsEvent type="' + type + '" bubbles=' + bubbles +
				' cancelable=' + cancelable + ' eventPhase=' + eventPhase + ']';
		}
	}
}
