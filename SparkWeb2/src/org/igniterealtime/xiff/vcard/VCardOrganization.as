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
package org.igniterealtime.xiff.vcard
{
	/**
	 * Organizational name and unit.
	 */
	public class VCardOrganization
	{
		private var _name:String;

		private var _unit:String;

		/**
		 *
		 * @param	name
		 * @param	unit
		 */
		public function VCardOrganization( name:String=null, unit:String=null )
		{
			this.name = name;
			this.unit = unit;
		}

		/**
		 *
		 */
		public function get name():String
		{
			return _name;
		}
		public function set name( value:String ):void
		{
			_name = value;
		}

		/**
		 *
		 */
		public function get unit():String
		{
			return _unit;
		}
		public function set unit( value:String ):void
		{
			_unit = value;
		}
	}
}
