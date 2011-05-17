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

	public class ModelChangedEvent extends Event
	{
		public static const MODEL_CHANGED:String = "modelChanged";

		private var _fieldName:String;

		private var _firstItem:String;

		private var _lastItem:String;

		private var _removedIDs:String;

		public function ModelChangedEvent()
		{
			super( ModelChangedEvent.MODEL_CHANGED, false, false );
		}

		override public function clone():Event
		{
			var event:ModelChangedEvent = new ModelChangedEvent();
			event.firstItem = _firstItem;
			event.lastItem = _lastItem;
			event.removedIDs = _removedIDs;
			event.fieldName = _fieldName;
			return event;
		}

		public function get fieldName():String
		{
			return _fieldName;
		}

		public function set fieldName( value:String ):void
		{
			_fieldName = value;
		}

		public function get firstItem():String
		{
			return _firstItem;
		}

		public function set firstItem( value:String ):void
		{
			_firstItem = value;
		}

		public function get lastItem():String
		{
			return _lastItem;
		}

		public function set lastItem( value:String ):void
		{
			_lastItem = value;
		}

		public function get removedIDs():String
		{
			return _removedIDs;
		}

		public function set removedIDs( value:String ):void
		{
			_removedIDs = value;
		}

		override public function toString():String
		{
			return '[ModelChangedEvent type="' + type + '" bubbles=' + bubbles +
				' cancelable=' + cancelable + ' eventPhase=' + eventPhase + ']';
		}
	}
}

