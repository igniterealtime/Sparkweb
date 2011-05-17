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
package org.igniterealtime.xiff.data.bind
{
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.Extension;
	import org.igniterealtime.xiff.data.ExtensionClassRegistry;
	import org.igniterealtime.xiff.data.IExtension;
	import org.igniterealtime.xiff.data.ISerializable;
	import org.igniterealtime.xiff.data.XMLStanza;

	/**
	 * @see http://xmpp.org/extensions/xep-0193.html
	 */
	public class BindExtension extends Extension implements IExtension, ISerializable
	{
		public static const NS:String = "urn:ietf:params:xml:ns:xmpp-bind";
		public static const ELEMENT_NAME:String = "bind";
		
		private var _jid:EscapedJID;
		private var _resource:String;
		
		public function getNS():String
		{
			return BindExtension.NS;
		}
		
		public function getElementName():String
		{
			return BindExtension.ELEMENT_NAME;
		}
		
		public function get jid():EscapedJID
		{
			return _jid;
		}
		
		public function serialize(parent:XMLNode):Boolean
		{
			if (!exists(getNode().parentNode))
			{
				var child:XMLNode = getNode().cloneNode(true);
				var resourceNode:XMLNode = new XMLNode(1, "resource");
				resourceNode.appendChild(XMLStanza.XMLFactory.createTextNode(resource ? resource : "xiff"));
				child.appendChild(resourceNode);
				parent.appendChild(child);
			}
			return true;
		}
		
		public function BindExtension( parent:XMLNode = null)
		{
			super(parent);
		}
		
		/**
	     * Registers this extension with the extension registry.
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(BindExtension);
	    }
		
		public function deserialize(node:XMLNode):Boolean
		{
			setNode(node);
			var children:Array = node.childNodes;
			for ( var i:String in children )
			{
				switch( children[i].nodeName )
				{
					case "jid":
						_jid = new EscapedJID(children[i].firstChild.nodeValue);
						break;
					default:
						throw "Unknown element: " + children[i].nodeName;
				}
			}
			return true;
		}
		
		public function set resource(value:String):void
		{
			_resource = value;
		}
		
		public function get resource():String
		{
			return _resource;
		}
		
	}
}
