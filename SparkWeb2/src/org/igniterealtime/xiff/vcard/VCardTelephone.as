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
	 * Telephone number.
	 */
	public class VCardTelephone
	{
		private var _cell:String;

		private var _fax:String;

		private var _msg:String;

		private var _pager:String;

		private var _video:String;

		private var _voice:String;

		/**
		 *
		 * @param	voice
		 * @param	fax
		 * @param	pager
		 * @param	msg
		 * @param	cell
		 * @param	video
		 */
		public function VCardTelephone( voice:String=null, fax:String=null, pager:String=null, msg:String=null, cell:String=null, video:String=null )
		{
			this.voice = voice;
			this.fax = fax;
			this.pager = pager;
			this.msg = msg;
			this.cell = cell;
			this.video = video;
		}

		/**
		 *
		 */
		public function get cell():String
		{
			return _cell;
		}
		public function set cell( value:String ):void
		{
			_cell = value;
		}

		/**
		 *
		 */
		public function get fax():String
		{
			return _fax;
		}
		public function set fax( value:String ):void
		{
			_fax = value;
		}

		/**
		 *
		 */
		public function get msg():String
		{
			return _msg;
		}
		public function set msg( value:String ):void
		{
			_msg = value;
		}

		/**
		 *
		 */
		public function get pager():String
		{
			return _pager;
		}
		public function set pager( value:String ):void
		{
			_pager = value;
		}

		/**
		 *
		 */
		public function get video():String
		{
			return _video;
		}
		public function set video( value:String ):void
		{
			_video = value;
		}

		/**
		 *
		 */
		public function get voice():String
		{
			return _voice;
		}
		public function set voice( value:String ):void
		{
			_voice = value;
		}
	}
}
