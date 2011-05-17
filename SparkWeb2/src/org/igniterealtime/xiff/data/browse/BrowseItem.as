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
package org.igniterealtime.xiff.data.browse
{
	
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.data.ISerializable;
	import org.igniterealtime.xiff.data.XMLStanza;
	
	/**
	 * Class that representes a child resource of a browsed resource.
	 */
	public class BrowseItem extends XMLStanza implements ISerializable
	{
		public function BrowseItem(parent:XMLNode)
		{
			super();
			getNode().nodeName = "item";
	
			if (exists(parent))
			{
				parent.appendChild(getNode());
			}
	
		}
	
		public function serialize(parentNode:XMLNode):Boolean
		{
			var node:XMLNode = getNode();
			if (!exists(node.parentNode))
			{
				parentNode.appendChild(node.cloneNode(true));
			}
	
			return true;
		}
	
		public function deserialize(node:XMLNode):Boolean
		{
			setNode(node);
			return true;
		}
	
		/**
		 * Add new features that are supported if you are responding to a
		 * browse request
		 */
		public function addNamespace(value:String):XMLNode
		{
			return addTextNode(getNode(), "ns", value);
		}
	
		/**
		 * The full JabberID of the entity described
		 */
		public function get jid():String
		{
			return getNode().attributes.jid;
		}
		public function set jid(value:String):void
		{
			getNode().attributes.jid = value;
		}
	
		/**
		 * One of the categories from the list above, or a
		 * non-standard category prefixed with the string "x-".
		 *
		 * @see	http://xmpp.org/extensions/xep-0011.html#sect-id2594870
		 */
		public function get category():String
		{
			return getNode().attributes.category;
		}
		public function set category(value:String):void
		{
			getNode().attributes.category = value;
		}
	
		/**
		 * A friendly name that may be used in a user interface
		 */
		public function get name():String
		{
			return getNode().attributes.name;
		}
		public function set name(value:String):void
		{
			getNode().attributes.name = value;
		}
	
		/**
		 * One of the official types from the specified category,
		 * or a non-standard type prefixed with the string "x-".

		 * @see	http://xmpp.org/extensions/xep-0011.html#sect-id2594870
		 */
		public function get type():String
		{
			return getNode().attributes.type;
		}
		public function set type(value:String):void
		{
			getNode().attributes.type = value;
		}
	
		/**
		 * A string containing the version of the node, equivalent
		 * to the response provided to a query in the 'jabber:iq:version'
		 * namespace. This is useful for servers, especially for lists of
		 * services (see the 'service/serverlist' category/type above).
		 */
		public function get version():String
		{
			return getNode().attributes.version;
		}
		public function set version(value:String):void
		{
			getNode().attributes.version = value;
		}
	
	 	/**
		 * On top of the browsing framework, a simple form of "feature
		 * advertisement" can be built. This enables any entity to advertise
		 * whichfeatures it supports, based on the namespaces associated with
		 * those features. The <ns/> element is allowed as a subelement of the
		 * item. This element contains a single namespace that the entity
		 * supports, and multiple <ns/> elements can be included in any item.
		 * For a connectedclient this might be <ns>jabber:iq:oob</ns>, or for a
		 * service<ns>jabber:iq:search</ns>. This list of namespaces should be
		 * used to present available options for a user or to automatically
		 * locate functionality for an application.
		 *
		 * <p>The children of a browse result may proactively contain a few
		 * <ns/> elements (such as the result of the service request to the home
		 * server), which advertises the features that the particular service
		 * supports. Thislist may not be complete (it is only for first-pass
		 * filtering by simpler clients), and the JID should be browsed if a
		 * complete list is required.</p>
		 */
		public function get namespaces():Array
		{
			var res:Array = [];
	
			for each (var child:XMLNode in getNode().childNodes)
			{
				if (child.nodeName == "ns")
				{
					res.push(child.firstChild.nodeValue);
				}
			}
			return res;
		}
	}
}
