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
	 * Structured name.
	 */
	public class VCardName
	{
		private var _family:String;

		private var _given:String;

		private var _middle:String;

		private var _prefix:String;

		private var _suffix:String;

		/**
		 *
		 * @param	given
		 * @param	middle
		 * @param	family
		 * @param	prefix
		 * @param	suffix
		 */
		public function VCardName( given:String=null, middle:String=null, family:String=null, prefix:String=null, suffix:String=null )
		{
			this.given = given;
			this.middle = middle;
			this.family = family;
			this.prefix = prefix;
			this.suffix = suffix;
		}

		/**
		 *
		 */
		public function get family():String
		{
			return _family;
		}
		public function set family( value:String ):void
		{
			_family = value;
		}

		/**
		 *
		 */
		public function get given():String
		{
			return _given;
		}
		public function set given( value:String ):void
		{
			_given = value;
		}

		/**
		 *
		 */
		public function get middle():String
		{
			return _middle;
		}
		public function set middle( value:String ):void
		{
			_middle = value;
		}

		/**
		 *
		 */
		public function get prefix():String
		{
			return _prefix;
		}
		public function set prefix( value:String ):void
		{
			_prefix = value;
		}

		/**
		 *
		 */
		public function get suffix():String
		{
			return _suffix;
		}
		public function set suffix( value:String ):void
		{
			_suffix = value;
		}
	}
}
