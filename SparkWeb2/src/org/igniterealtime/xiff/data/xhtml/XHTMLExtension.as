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
package org.igniterealtime.xiff.data.xhtml
{



	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;

	import org.igniterealtime.xiff.data.Extension;
	import org.igniterealtime.xiff.data.ExtensionClassRegistry;
	import org.igniterealtime.xiff.data.IExtension;
	import org.igniterealtime.xiff.data.ISerializable;

	/**
	 * This class provides an extension for XHTML body text in messages.
	 * <p>html --> http://jabber.org/protocol/xhtml-im</p>
	 * <p>body --> http://www.w3.org/1999/xhtml</p>

	 * @see http://xmpp.org/extensions/xep-0071.html
	 */
	public class XHTMLExtension extends Extension implements IExtension, ISerializable
	{
		public static const NS:String = "http://jabber.org/protocol/xhtml-im";
		public static const ELEMENT_NAME:String = "html";

	    private static var staticDepends:Class = ExtensionClassRegistry;

		/**
		 *
		 * @param	parent The parent node for this extension
		 */
		public function XHTMLExtension(parent:XMLNode = null)
		{
			super(parent);
		}

		/**
		 *
		 * @param	parent The parent node for this extension
		 */
		public function serialize( parent:XMLNode ):Boolean
        {
            return true;
        }

		/**
		 *
		 * @param	parent The parent node for this extension
		 * @see http://www.igniterealtime.org/community/message/179673
		 */
        public function deserialize( node:XMLNode ):Boolean
        {
			getNode().appendChild(node.cloneNode(true));
        	return true;
        }

		/**
		 * Gets the namespace associated with this extension.
		 * The namespace for the XHTMLExtension is "http://www.w3.org/1999/xhtml".
		 *
		 * @return The namespace
		 */
		public function getNS():String
		{
			return XHTMLExtension.NS;
		}

		/**
		 * Gets the element name associated with this extension.
		 * The element for this extension is "html".
		 *
		 * @return The element name
		 */
		public function getElementName():String
		{
			return XHTMLExtension.ELEMENT_NAME;
		}

	    /**
	     * Performs the registration of this extension into the extension registry.
	     *
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(XHTMLExtension);
	    }

		/**
		 * The XHTML body text. Valid XHTML is REQUIRED. Because XMPP operates using
		 * valid XML, standard HTML, which is not necessarily XML-parser compliant, will
		 * not work.
		 *
		 */
		public function get body():String
		{
			var html:Array = [];
			for each(var child:XMLNode in getNode().childNodes)
			{
				html.unshift(child.toString());
			}
			return html.join();
		}
		public function set body(value:String):void
		{
			for each(var child:XMLNode in getNode().childNodes)
			{
				child.removeNode();
			}
			getNode().appendChild(new XMLDocument(value));
		}
	}
}
