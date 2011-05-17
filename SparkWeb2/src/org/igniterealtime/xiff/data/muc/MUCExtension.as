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
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.data.Extension;
	import org.igniterealtime.xiff.data.IExtension;
	import org.igniterealtime.xiff.data.ISerializable;
	
	/**
	 * Implements the base MUC protocol schema from <a href="http://www.xmpp.org/extensions/xep-0045.html">XEP-0045<a> for multi-user chat.
	 *
	 * This extension is typically used to test for the presence of MUC enabled conferencing
	 * service, or a MUC related error condition.
	 *
	 * @param	parent (Optional) The containing XMLNode for this extension
	 */
	public class MUCExtension extends Extension implements IExtension, ISerializable
	{
		public static const NS:String = "http://jabber.org/protocol/muc";
		public static const ELEMENT_NAME:String = "x";
	
		private var myHistoryNode:XMLNode;
		private var myPasswordNode:XMLNode;
	
		public function MUCExtension( parent:XMLNode = null )
		{
			super(parent);
		}
	
		public function getNS():String
		{
			return MUCExtension.NS;
		}
	
		public function getElementName():String
		{
			return MUCExtension.ELEMENT_NAME;
		}
	
		public function serialize( parent:XMLNode ):Boolean
		{
			if (exists(getNode().parentNode)) {
				return false;
			}
			var node:XMLNode = getNode().cloneNode(true);
			for each(var ext:IExtension in getAllExtensions()) {
				if (ext is ISerializable) {
					ISerializable(ext).serialize(node);
				}
			}
			parent.appendChild(node);
			return true;
		}
	
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode(node);
	
			for each( var child:XMLNode in node.childNodes ) {
				switch( child.nodeName )
				{
					case "history":
						myHistoryNode = child;
						break;
						
					case "password":
						myPasswordNode = child;
						break;
				}
			}
			return true;
		}
		
		public function addChildNode(childNode:XMLNode):void
		{
			getNode().appendChild(childNode);
		}
	
		/**
		 * If a room is password protected, add this extension and set the password
		 */
		public function get password():String
		{
			if(myPasswordNode && myPasswordNode.firstChild)
				return myPasswordNode.firstChild.nodeValue;
			
			return null;
		}
	
		public function set password(value:String):void
		{
			myPasswordNode = replaceTextNode(getNode(), myPasswordNode, "password", value);
		}
	
		/**
		 * This is property allows a user to retrieve a server defined collection of previous messages.
		 * Set this property to "true" to retrieve a history of the dicussions.
		 */
		public function get history():Boolean
		{
			return exists(myHistoryNode);
		}
	
		public function set history(value:Boolean):void
		{
			if (value)
			{
				myHistoryNode = ensureNode(myHistoryNode, "history");
			}
			else
			{
				myHistoryNode.removeNode();
				myHistoryNode = null;
				//delete myHistoryNode;
			}
		}
	
		/**
		 * Size based condition to evaluate by the server for the maximum
		 * characters to return during history retrieval
		 */
		public function get maxchars():int
		{
			return parseInt(myHistoryNode.attributes.maxchars);
		}
	
		public function set maxchars(value:int):void
		{
			myHistoryNode = ensureNode(myHistoryNode, "history");
			myHistoryNode.attributes.maxchars = value.toString();
		}
	
		/**
		 * Protocol based condition for the number of stanzas to return during history retrieval
		 */
		public function get maxstanzas():int
		{
			return parseInt(myHistoryNode.attributes.maxstanzas);
		}
	
		public function set maxstanzas(value:int):void
		{
			myHistoryNode = ensureNode(myHistoryNode, "history");
			myHistoryNode.attributes.maxstanzas = value.toString();
		}
	
		/**
		 * Time based condition to retrive all messages for the last N seconds.
		 */
		public function get seconds():Number
		{
			return Number(myHistoryNode.attributes.seconds);
		}
	
		public function set seconds(value:Number):void
		{
			myHistoryNode = ensureNode(myHistoryNode, "history");
			myHistoryNode.attributes.seconds = value.toString();
		}
	
		/**
		 * Time base condition to retrieve all messages from a given time formatted in the format described in
		 * <a href="http://xmpp.org/extensions/xep-0082.html">XEP-0082</a>.
		 *
		 */
		public function get since():String
		{
			return myHistoryNode.attributes.since;
		}
	
		public function set since(value:String):void
		{
			myHistoryNode = ensureNode(myHistoryNode, "history");
			myHistoryNode.attributes.since = value;
		}
	}
}
