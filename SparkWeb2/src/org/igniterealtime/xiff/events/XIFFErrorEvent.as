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

	import org.igniterealtime.xiff.data.Extension;

	/**
	 *
	 */
	public class XIFFErrorEvent extends Event
	{
		/**
		 *
		 * @default
		 */
		public static const XIFF_ERROR:String = "error";

		/**
		 *
		 * @default
		 */
		private var _errorCode:int;

		/**
		 *
		 * @default
		 */
		private var _errorCondition:String;

		/**
		 *
		 * @default
		 */
		private var _errorExt:Extension;

		/**
		 *
		 * @default
		 */
		private var _errorMessage:String;

		/**
		 *
		 * @default
		 */
		private var _errorType:String;

		/**
		 *
		 */
		public function XIFFErrorEvent()
		{
			super( XIFFErrorEvent.XIFF_ERROR, false, false );
		}

		override public function clone():Event
		{
			var event:XIFFErrorEvent = new XIFFErrorEvent();
			event.errorCondition = _errorCondition;
			event.errorMessage = _errorMessage;
			event.errorType = _errorType;
			event.errorCode = _errorCode;
			event.errorExt = _errorExt;
			return event;
		}

		/**
		 * Legacy error code
		 * @see http://xmpp.org/extensions/xep-0086.html
		 */
		public function get errorCode():int
		{
			return _errorCode;
		}
		public function set errorCode( value:int ):void
		{
			_errorCode = value;
		}

		/**
		 *
		 */
		public function get errorCondition():String
		{
			return _errorCondition;
		}
		public function set errorCondition( value:String ):void
		{
			_errorCondition = value;
		}

		/**
		 *
		 */
		public function get errorExt():Extension
		{
			return _errorExt;
		}
		public function set errorExt( value:Extension ):void
		{
			_errorExt = value;
		}

		/**
		 *
		 */
		public function get errorMessage():String
		{
			return _errorMessage;
		}
		public function set errorMessage( value:String ):void
		{
			_errorMessage = value;
		}

		/**
		 *
		 */
		public function get errorType():String
		{
			return _errorType;
		}
		public function set errorType( value:String ):void
		{
			_errorType = value;
		}

		override public function toString():String
		{
			return '[XIFFErrorEvent type="' + type + '" bubbles=' + bubbles + ' cancelable=' +
				cancelable + ' eventPhase=' + eventPhase + ']';
		}
	}
}
