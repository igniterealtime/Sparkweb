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
package org.igniterealtime.xiff.data.auth
{
	import flash.xml.XMLNode;
	import flash.utils.ByteArray;
	import org.igniterealtime.xiff.data.*;
	
	import org.igniterealtime.xiff.util.SHA1;
	//import com.hurlant.crypto.hash.SHA1;
	
	/**
	 * Implements <a href="http://xmpp.org/extensions/xep-0078.html">XEP-0078<a>
	 * for non SASL authentication.
	 * @see	http://xmpp.org/extensions/xep-0078.html
	 */
	public class AuthExtension extends Extension implements IExtension, ISerializable
	{
		public static const NS:String = "jabber:iq:auth";
		public static const ELEMENT_NAME:String = "query";
	
		private var myUsernameNode:XMLNode;
		private var myPasswordNode:XMLNode;
		private var myDigestNode:XMLNode;
		private var myResourceNode:XMLNode;
		
		public function AuthExtension( parent:XMLNode = null)
		{
			super(parent);
		}
	
		/**
		 * Gets the namespace associated with this extension.
		 * The namespace for the AuthExtension is "jabber:iq:auth".
		 *
		 * @return The namespace
		 */
		public function getNS():String
		{
			return AuthExtension.NS;
		}
	
		/**
		 * Gets the element name associated with this extension.
		 * The element for this extension is "query".
		 *
		 * @return The element name
		 */
		public function getElementName():String
		{
			return AuthExtension.ELEMENT_NAME;
		}
	
	    /**
	     * Registers this extension with the extension registry.
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(AuthExtension);
	    }
		
		public function serialize( parent:XMLNode ):Boolean
		{
			if (!exists(getNode().parentNode))
			{
				parent.appendChild(getNode().cloneNode(true));
			}
			return true;
		}
	
		public function deserialize( node:XMLNode ):Boolean
		{
			
			setNode(node);
			var children:Array = node.childNodes;
			for ( var i:String in children )
			{
				switch( children[i].nodeName )
				{
					case "username":
						myUsernameNode = children[i];
						break;
						
					case "password":
						myPasswordNode = children[i];
						break;
						
					case "digest":
						myDigestNode = children[i];
						break;
	
					case "resource":
						myResourceNode = children[i];
						break;
				}
			}
			return true;
		}
	
		/**
		 * Computes the SHA1 digest of the password and session ID for use when
		 * authenticating with the server.
		 *
		 * @param	sessionID The session ID provided by the server
		 * @param	password The user's password
		 */
		public static function computeDigest( sessionID:String, password:String ):String
		{
			/*
			var bytesIn:ByteArray = new ByteArray();
			bytesIn.writeUTFBytes( sessionID + password );
			var sha:SHA1 = new SHA1();
			var bytesOut:ByteArray =  sha.hash( bytesIn );
			return bytesOut.readUTFBytes( bytesOut.length );
			*/
			
			return SHA1.calcSHA1( sessionID + password ).toLowerCase();
		}
	
		/**
		 * Determines whether this is a digest (SHA1) authentication.
		 *
		 * @return It is a digest (true); it is not a digest (false)
		 */
		public function isDigest():Boolean
		{
			return exists(myDigestNode);
		}
	
		/**
		 * Determines whether this is a plain-text password authentication.
		 *
		 * @return It is plain-text password (true); it is not plain-text
		 * password (false)
		 */
		public function isPassword():Boolean
		{
			return exists(myPasswordNode);
		}
	
		/**
		 * The username to use for authentication.
		 */
		public function get username():String
		{
			if(myUsernameNode && myUsernameNode.firstChild)
				return myUsernameNode.firstChild.nodeValue;
			
			return null;
		}
	
		/**
		 * @private
		 */
		public function set username(value:String):void
		{
			myUsernameNode = replaceTextNode(getNode(), myUsernameNode, "username", value);
		}
	
		/**
		 * The password to use for authentication.
		 */
		public function get password():String
		{
			if (myPasswordNode && myPasswordNode.firstChild)
			{
				return myPasswordNode.firstChild.nodeValue;
			}
			
			return null;
		}
	
		/**
		 * @private
		 */
		public function set password(value:String):void
		{
			// Either or for digest or password
			myDigestNode = (myDigestNode==null)?(XMLStanza.XMLFactory.createElement('')):(myDigestNode);
			myDigestNode.removeNode();
			myDigestNode = null;
			//delete myDigestNode;
	
			myPasswordNode = replaceTextNode(getNode(), myPasswordNode, "password", value);
		}
	
		/**
		 * The SHA1 digest to use for authentication.
		 */
		public function get digest():String
		{
			if (myDigestNode && myDigestNode.firstChild)
			{
				return myDigestNode.firstChild.nodeValue;
			}
			
			return null;
		}
	
		/**
		 * @private
		 */
		public function set digest(value:String):void
		{
			// Either or for digest or password
			myPasswordNode.removeNode();
			myPasswordNode = null;
			//delete myPasswordNode;
	
			myDigestNode = replaceTextNode(getNode(), myDigestNode, "digest", value);
		}
	
		/**
		 * The resource to use for authentication.
		 *
		 * @see	org.igniterealtime.xiff.core.XMPPConnection#resource
		 */
		public function get resource():String
		{
			if (myResourceNode && myResourceNode.firstChild)
			{
				return myResourceNode.firstChild.nodeValue;
			}
			
			return null;
		}
	
		/**
		 * @private
		 */
		public function set resource(value:String):void
		{
			myResourceNode = replaceTextNode(getNode(), myResourceNode, "resource", value);
		}
	
	}
}
