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
	 * Structured address.
	 */
	public class VCardAddress
	{
		private var _country:String;

		private var _extendedAddress:String;

		private var _locality:String;

		private var _poBox:String;

		private var _postalCode:String;

		private var _region:String;

		private var _street:String;

		/**
		 *
		 * @param	street
		 * @param	locality
		 * @param	region
		 * @param	postalCode
		 * @param	country
		 * @param	extendedAddress
		 * @param	poBox
		 */
		public function VCardAddress( street:String=null, locality:String=null, region:String=null, postalCode:String=null, country:String=null, extendedAddress:String=null, poBox:String=null )
		{
			this.street = street;
			this.locality = locality;
			this.region = region;
			this.postalCode = postalCode;
			this.country = country;
			this.extendedAddress = extendedAddress;
			this.poBox = poBox;
		}

		/**
		 *
		 */
		public function get country():String
		{
			return _country;
		}
		public function set country( value:String ):void
		{
			_country = value;
		}

		/**
		 *
		 */
		public function get extendedAddress():String
		{
			return _extendedAddress;
		}
		public function set extendedAddress( value:String ):void
		{
			_extendedAddress = value;
		}

		/**
		 *
		 */
		public function get locality():String
		{
			return _locality;
		}
		public function set locality( value:String ):void
		{
			_locality = value;
		}

		/**
		 *
		 */
		public function get poBox():String
		{
			return _poBox;
		}
		public function set poBox( value:String ):void
		{
			_poBox = value;
		}

		/**
		 *
		 */
		public function get postalCode():String
		{
			return _postalCode;
		}
		public function set postalCode( value:String ):void
		{
			_postalCode = value;
		}

		/**
		 *
		 */
		public function get region():String
		{
			return _region;
		}
		public function set region( value:String ):void
		{
			_region = value;
		}

		/**
		 *
		 */
		public function get street():String
		{
			return _street;
		}
		public function set street( value:String ):void
		{
			_street = value;
		}
	}
}
