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
package org.igniterealtime.xiff.filter
{
	import org.igniterealtime.xiff.data.XMPPStanza;
	import org.igniterealtime.xiff.util.Callback;

	/**
	 *
	 */
	public class CallbackPacketFilter implements IPacketFilter
	{

		/**
		 *
		 * @default
		 */
		private var _callback:Callback;

		/**
		 *
		 * @default
		 */
		private var _filterFunction:Function;

		/**
		 *
		 * @default
		 */
		private var _processFunction:Function;

		/**
		 *
		 * @param	callback
		 * @param	filterFunction
		 * @param	processFunction
		 */
		public function CallbackPacketFilter( callback:Callback, filterFunction:Function = null,
											  processFunction:Function = null )
		{
			_callback = callback;
			_filterFunction = filterFunction;
			_processFunction = processFunction;
		}

		/**
		 *
		 * @param packet
		 */
		public function accept( packet:XMPPStanza ):void
		{
			if ( _filterFunction == null || _filterFunction( packet ))
			{
				var processed:Object = packet;
				if ( _processFunction != null )
				{
					processed = _processFunction( packet );
				}
				_callback.call( processed );
			}
		}
	}
}