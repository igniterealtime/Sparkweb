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

	/**
	 * When a property is changed somewhere, someone might be interested to listen its
	 * current and previous values. Currently this is only used in RosterItemVO
	 * in order to replace the Flex counterpart.
	 */
	public class PropertyChangeEvent extends Event
	{
		public static const CHANGE:String = "change";
		
		private var _name:String;
		
		private var _oldValue:*;

		private var _newValue:*;

		public function PropertyChangeEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone():Event
		{
			var event:PropertyChangeEvent = new PropertyChangeEvent( type, bubbles, cancelable );
			event.name = _name;
			event.newValue = _newValue;
			event.oldValue = _oldValue;
			return event;
		}

		public function get name():*
		{
			return _name;
		}

		public function set name( value:* ):void
		{
			_name = value;
		}

		public function get newValue():*
		{
			return _newValue;
		}

		public function set newValue( value:* ):void
		{
			_newValue = value;
		}

		public function get oldValue():*
		{
			return _oldValue;
		}

		public function set oldValue( value:* ):void
		{
			_oldValue = value;
		}

		override public function toString():String
		{
			return '[PropertyChangeEvent type="' + type + '" bubbles=' + bubbles + ' cancelable=' +
				cancelable + ' eventPhase=' + eventPhase + ']';
		}
	}
}
