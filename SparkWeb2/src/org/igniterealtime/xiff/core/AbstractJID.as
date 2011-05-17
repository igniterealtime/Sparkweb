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
package org.igniterealtime.xiff.core
{
	/**
	 * This is a base class for the JID (Jabber ID) classes.
	 * This class should not be instantiated directly, but should be subclassed
	 * instead.
	 *
	 * It provides functionality to determine if a JID is valid, as well as extract the
	 * node, domain and resource from the JID.
	 *
	 * The structure of JID is defined in RFC3920.
	 * <code>jid = [ node "@" ] domain [ "/" resource ]</code>
	 * <code>domain = fqdn / address-literal</code>
	 * <code>fqdn = (sub-domain 1*("." sub-domain))</code>
	 * <code>sub-domain = (internationalized domain label)</code>
	 * <code>address-literal = IPv4address / IPv6address</code>
	 *
	 * @exampleText user@host/resource
	 * @exampleText room@service/nick
	 */
	public class AbstractJID
	{
		private const BYTE_LIMIT_ITEM:uint = 1023;
		private const BYTE_LIMIT_TOTAL:uint = 3071;
		
		//TODO: this doesn't actually validate properly in some cases; need separate nodePrep, etc...
		protected static var jidNodeValidator:RegExp = /^([\x29\x23-\x25\x28-\x2E\x30-\x39\x3B\x3D\x3F\x41-\x7E\xA0 \u1680\u202F\u205F\u3000\u2000-\u2009\u200A-\u200B\u06DD \u070F\u180E\u200C-\u200D\u2028-\u2029\u0080-\u009F \u2060-\u2063\u206A-\u206F\uFFF9-\uFFFC\uE000-\uF8FF\uFDD0-\uFDEF \uFFFE-\uFFFF\uD800-\uDFFF\uFFF9-\uFFFD\u2FF0-\u2FFB]{1,1023})/;
		protected var _node:String = "";
		protected var _domain:String = "";
		protected var _resource:String = "";

		//if we use the literal regexp notation, flex gets confused and thinks the quote starts a string
		private static var quoteregex:RegExp = new RegExp('"', "g");
		private static var quoteregex2:RegExp = new RegExp("'", "g");

		/**
		 * Creates a new AbstractJID object. Used via EscapedJID or UnescapedJID.
		 *
		 * <p>Each allowable portion of a JID (node identifier, domain identifier, and resource identifier)
		 * MUST NOT be more than 1023 bytes in length, resulting in a maximum total size
		 * (including the ’@’ and ’/’ separators) of 3071 bytes.</p>
		 *
		 * @param	inJID The JID as a String.
		 * @param	validate True if the JID should be validated.
		 */
		public function AbstractJID( inJID:String, validate:Boolean = false )
		{
			if (validate)
			{
				if (!jidNodeValidator.test(inJID) || inJID.indexOf(" ") > -1 || inJID.length > BYTE_LIMIT_TOTAL)
				{
					trace("Invalid JID: %s", inJID);
					throw "Invalid JID";
				}
			}
			var separatorIndex:int = inJID.lastIndexOf("@");
			var slashIndex:int = inJID.lastIndexOf("/");

			if (slashIndex >= 0)
			{
				_resource = inJID.substring(slashIndex + 1);
			}

			_domain = inJID.substring(separatorIndex + 1, slashIndex >= 0 ? slashIndex : inJID.length);

			if (separatorIndex >= 1)
			{
				_node = inJID.substring(0, separatorIndex);
			}
		}
		
		/**
		 * Provides functionality to convert a JID to an escaped format.
		 *
		 * @param	n The string to escape.
		 *
		 * @return The escaped string.
		 */
		public static function escapedNode( n:String ):String
		{
			if( n && (
				n.indexOf("@") >= 0 ||
				n.indexOf(" ") >= 0 ||
				n.indexOf("\\")>= 0 ||
				n.indexOf("/") >= 0 ||
				n.indexOf("&") >= 0 ||
				n.indexOf("'") >= 0 ||
				n.indexOf('"') >= 0 ||
				n.indexOf(":") >= 0 ||
				n.indexOf("<") >= 0 ||
				n.indexOf(">") >= 0))
			{
				n = n.replace(/\\/g, "\\5c");
				n = n.replace(/@/g, "\\40");
				n = n.replace(/ /g, "\\20");
				n = n.replace(/&/g, "\\26");
				n = n.replace(/>/g, "\\3e");
				n = n.replace(/</g, "\\3c");
				n = n.replace(/:/g, "\\3a");
				n = n.replace(/\//g, "\\2f");
				n = n.replace(quoteregex, "\\22");
				n = n.replace(quoteregex2, "\\27");
			}
			return n;
		}

		/**
		 * Provides functionality to return an escaped JID into a normal String.
		 *
		 * @param	n The string to unescape.
		 *
		 * @return The unescaped string.
		 */
		public static function unescapedNode( n:String ):String
		{
			if( n && (
				n.indexOf("\\40") >= 0 ||
				n.indexOf("\\20") >= 0 ||
				n.indexOf("\\26")>= 0 ||
				n.indexOf("\\3e") >= 0 ||
				n.indexOf("\\3c") >= 0 ||
				n.indexOf("\\5c") >= 0 ||
				n.indexOf('\\3a') >= 0 ||
				n.indexOf("\\2f") >= 0 ||
				n.indexOf("\\22") >= 0 ||
				n.indexOf("\\27") >= 0) )
			{
				n = n.replace(/\40/g, "@");
				n = n.replace(/\20/g, " ");
				n = n.replace(/\26/g, "&");
				n = n.replace(/\3e/g, ">");
				n = n.replace(/\3c/g, "<");
				n = n.replace(/\3a/g, ":");
				n = n.replace(/\2f/g, "/");
				n = n.replace(quoteregex, '"');
				n = n.replace(quoteregex2, "'");
				n = n.replace(/\5c/g, "\\");
			}
			return n;
		}

		/**
		 * Converts JID represented by this class to a String.
		 *
		 * @return The JID as a String.
		 */
		public function toString():String
		{
			var j:String = "";
			if (node)
			{
				j += node + "@";
			}
			j += domain;
			if (resource)
			{
				j += "/" + resource;
			}

			return j;
		}

		/**
		 * The JID without the resource.
		 */
		public function get bareJID():String
		{
			var str:String = toString();
			var slashIndex:int = str.lastIndexOf("/");
			if (slashIndex > 0)
			{
				str = str.substring(0, slashIndex);
			}
			return str;
		}

		/**
		 * The resource portion of the JID.
		 */
		public function get resource():String
		{
			if (_resource.length > 0)
			{
				return _resource;
			}
			return null;
		}

		/**
		 * The node portion of the JID.
		 */
		public function get node():String
		{
			if (_node.length > 0)
			{
				return _node;
			}
			return null;
		}

		/**
		 * The domain portion of the JID.
		 */
		public function get domain():String
		{
			return _domain;
		}
	}
}
