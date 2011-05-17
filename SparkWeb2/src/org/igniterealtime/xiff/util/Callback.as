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
package org.igniterealtime.xiff.util
{

	/**
	 * Sets an callback function
	 */
	public class Callback
	{
		/**
		 *
		 * @default
		 */
		private var _args:Array;

		/**
		 *
		 * @default
		 */
		private var _callback:Function;

		/**
		 *
		 * @default
		 */
		private var _scope:Object;

		/**
		 *
		 * @param	scope
		 * @param	callback
		 * @param	... args
		 */
		public function Callback( scope:Object, callback:Function, ... args )
		{
			_scope = scope;
			_callback = callback;
			_args = args.slice();
		}

		/**
		 *
		 * @param	... args
		 * @return
		 */
		public function call( ... args ):Object
		{
			var callbackArgs:Array = _args.slice();
			for each ( var arg:Object in args )
			{
				callbackArgs.push( arg );
			}

			return _callback.apply( _scope, callbackArgs );
		}
	}
}