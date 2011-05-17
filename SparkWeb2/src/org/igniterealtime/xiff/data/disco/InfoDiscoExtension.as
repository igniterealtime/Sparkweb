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
	
	import org.igniterealtime.xiff.data.ExtensionClassRegistry;
	import org.igniterealtime.xiff.data.IExtension;
	
	/**
	 * Implements <a href="http://xmpp.org/extensions/xep-0030.html">XEP-0030<a> for service info discovery.
	 * Also, take a look at <a href="http://xmpp.org/extensions/xep-0020.html">XEP-0020</a> and
	 * <a href="http://xmpp.org/extensions/xep-0060.html">XEP-0060</a>.
	 * @see http://xmpp.org/extensions/xep-0030.html
	 */
	public class InfoDiscoExtension extends DiscoExtension implements IExtension
	{
		public static const NS:String = "http://jabber.org/protocol/disco#info";
	
		private var _identities:Array;
		private var _features:Array;
		
		/**
		 *
		 * @param	xmlNode (Optional) The XMLNode that contains this extension
		 * @see http://xmpp.org/extensions/xep-0030.html
		 */
		public function InfoDiscoExtension(xmlNode:XMLNode = null)
		{
			super(xmlNode);
		}
		
		public function getElementName():String
		{
			return DiscoExtension.ELEMENT_NAME;
		}
	
		public function getNS():String
		{
			return InfoDiscoExtension.NS;
		}
	
	    /**
	     * Performs the registration of this extension into the extension registry.
	     *
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(InfoDiscoExtension);
	    }
	
		/**
		 * An array of objects that represent the identities of a resource discovered. For more information on
		 * categories, see <a href="http://www.jabber.org/registrar/disco-categories.html">
		 * http://www.jabber.org/registrar/disco-categories.html</a>
		 *
		 * The objects in the array have the following possible attributes:
		 * <ul>
		 * <li><code>category</code> - a category of the kind of identity</li>
		 * <li><code>type</code> - a path to a resource that can be discovered without a JID</li>
		 * <li><code>name</code> - the friendly name of the identity</li>
		 * </ul>
		 *
		 */
		public function get identities():Array
		{
			return _identities;
		}
	
		/**
		 * An array of namespaces this service supports for feature negotiation.
		 *
		 */
		public function get features():Array
		{
			return _features;
		}
	
		override public function deserialize(node:XMLNode):Boolean
		{
			if (!super.deserialize(node))
				return false;
			
			_identities = [];
			_features = [];
			
			for each(var child:XMLNode in getNode().childNodes)
			{
				switch (child.nodeName)
				{
					case "identity":
						_identities.push(child.attributes);
						break;

					case "feature":
						_features.push(child.attributes["var"]);
						break;
				}
			}
			return true;
		}
	}
}
