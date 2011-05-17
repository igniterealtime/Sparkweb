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
package org.igniterealtime.xiff.data.disco
{

	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.Extension;
	import org.igniterealtime.xiff.data.ISerializable;
	
	/**
	 * Base class for service discovery extensions.
	 * @see http://xmpp.org/protocols/disco/
	 */
	public class DiscoExtension extends Extension implements ISerializable
	{
		public static const NS:String = "http://jabber.org/protocol/disco";
		public static const ELEMENT_NAME:String = "query";
		
		public var _service:EscapedJID;
	
		/**
		 * The name of the resource of the service queried if the resource
		 * doesn't have a JID. For more information, see
		 * <a href="http://www.jabber.org/registrar/disco-nodes.html">
		 * http://www.jabber.org/registrar/disco-nodes.html</a>.
		 */
		public function DiscoExtension(xmlNode:XMLNode)
		{
			super(xmlNode);
		}
		
		public function get serviceNode():String
		{
			return getNode().parentNode.attributes.node;
		}
		public function set serviceNode(value:String):void
		{
			getNode().parentNode.attributes.node = value;
		}
	
		/**
		 * The service name of the discovery procedure
		 */
		public function get service():EscapedJID
		{
			var parent:XMLNode = getNode().parentNode;
	
			if (parent.attributes.type == "result") {
				return new EscapedJID(parent.attributes.from);
			} else {
				return new EscapedJID(parent.attributes.to);
			}
		}
		
		/**
		 * @private
		 */
		public function set service(value:EscapedJID):void
		{
			var parent:XMLNode = getNode().parentNode;
	
			if (parent.attributes.type == "result")
			{
				parent.attributes.from = value.toString();
			}
			else
			{
				parent.attributes.to = value.toString();
			}
		}
	
		public function serialize(parentNode:XMLNode):Boolean
		{
			if (parentNode != getNode().parentNode) {
				parentNode.appendChild(getNode().cloneNode(true));
			}
			return true;
		}
	
		public function deserialize(node:XMLNode):Boolean
		{
			setNode(node);
			return true;
		}
	}
}
