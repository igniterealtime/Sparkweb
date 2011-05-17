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
package org.igniterealtime.xiff.data.session
{
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.data.Extension;
	import org.igniterealtime.xiff.data.ExtensionClassRegistry;
	import org.igniterealtime.xiff.data.IExtension;
	import org.igniterealtime.xiff.data.ISerializable;
	import org.igniterealtime.xiff.data.XMLStanza;

	/**
	 * @see http://tools.ietf.org/html/rfc3921#section-3
	 */
	public class SessionExtension extends Extension implements IExtension, ISerializable
	{
		public static const NS:String = "urn:ietf:params:xml:ns:xmpp-session";
		public static const ELEMENT_NAME:String = "session";
		private var jid:String;
		
		public function getNS():String
		{
			return SessionExtension.NS;
		}
		
		public function getElementName():String
		{
			return SessionExtension.ELEMENT_NAME;
		}
		
		public function getJID():String
		{
			return jid;
		}
		
		public function serialize(parent:XMLNode):Boolean
		{
			if (!exists(getNode().parentNode)) {
				var child:XMLNode = getNode().cloneNode(true);
				parent.appendChild(child);
			}
			return true;
		}
		
		public function SessionExtension( parent:XMLNode = null)
		{
			super(parent);
		}
		
		/**
	     * Registers this extension with the extension registry.
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(SessionExtension);
	    }
		
		public function deserialize(node:XMLNode):Boolean
		{
			setNode(node);
			return true;
		}
		
	}
}
