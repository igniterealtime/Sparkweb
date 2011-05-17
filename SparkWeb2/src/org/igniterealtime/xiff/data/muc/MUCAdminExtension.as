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
package org.igniterealtime.xiff.data.muc
{
	
	import org.igniterealtime.xiff.data.IExtension;
	import org.igniterealtime.xiff.data.ISerializable;
	
	import org.igniterealtime.xiff.data.muc.MUCBaseExtension;
	import flash.xml.XMLNode;
	
	/**
	 * Implements the administration command data model in <a href="http://xmpp.org/extensions/xep-0045.html">XEP-0045<a> for multi-user chat.
	 * @see http://xmpp.org/extensions/xep-0045.html
	 *
	 * @param	parent (Optional) The containing XMLNode for this extension
	 */
	public class MUCAdminExtension extends MUCBaseExtension implements IExtension
	{
		public static const NS:String = "http://jabber.org/protocol/muc#admin";
		public static const ELEMENT_NAME:String = "query";
	
		private var _items:Array;
	
		public function MUCAdminExtension( parent:XMLNode = null )
		{
			super(parent);
		}
	
		public function getNS():String
		{
			return MUCAdminExtension.NS;
		}
	
		public function getElementName():String
		{
			return MUCAdminExtension.ELEMENT_NAME;
		}
	}
}
