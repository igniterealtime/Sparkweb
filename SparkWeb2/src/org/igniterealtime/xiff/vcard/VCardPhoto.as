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
	import com.hurlant.util.Base64;

	import flash.utils.ByteArray;

	/**
	 * Photograph.
	 */
	public class VCardPhoto
	{
		private var _binaryValue:String;

		private var _bytes:ByteArray;

		private var _externalValue:String;

		private var _type:String;

		/**
		 * To save a photo, either binaryValue or externalValue are required, but not both.
		 * If binaryValue is passed in, type is required.
		 * If externalValue is passed in, type is not required.
		 * 
		 * @param	type The image type of the photo. Required if binaryValue is passed in.
		 * @param	binaryValue The BASE64 encoded binary value of the photo. Either binaryValue or externalValue are required, but not both.
		 * @param	externalValue The URI to an external photo. Either binaryValue or externalValue are required, but not both.
		 */
		public function VCardPhoto( type:String=null, binaryValue:String=null, externalValue:String=null )
		{
			this.type = type;
			this.binaryValue = binaryValue;
			this.externalValue = externalValue;
		}

		/**
		 *
		 */
		public function get binaryValue():String
		{
			return _binaryValue;
		}
		public function set binaryValue( value:String ):void
		{
			_binaryValue = value;
			if( value )
			{
				try
				{
					_bytes = Base64.decodeToByteArrayB( value );
				}
				catch( error:Error )
				{
					throw new Error( "VCardPhoto Error decoding binaryValue " + error.getStackTrace() );
				}
			}
			else
			{
				_bytes = null;
			}
		}

		/**
		 *
		 */
		public function get bytes():ByteArray
		{
			return _bytes;
		}
		public function set bytes( value:ByteArray ):void
		{
			_bytes = value;
			if( value )
			{
				try
				{
					_binaryValue =  Base64.encodeByteArray( value );
				}
				catch( error:Error )
				{
					throw new Error( "VCardPhoto Error encoding bytes " + error.getStackTrace() );
				}
			}
			else
			{
				_binaryValue = null;
			}
		}

		/**
		 *
		 */
		public function get externalValue():String
		{
			return _externalValue;
		}
		public function set externalValue( value:String ):void
		{
			_externalValue = value;
		}

		/**
		 *
		 */
		public function get type():String
		{
			return _type;
		}
		public function set type( value:String ):void
		{
			_type = value;
		}
	}
}
