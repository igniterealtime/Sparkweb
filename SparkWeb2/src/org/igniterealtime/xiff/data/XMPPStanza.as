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
package org.igniterealtime.xiff.data
{
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.id.IIDGenerator;
	import org.igniterealtime.xiff.data.id.IncrementalGenerator;
	
	/**
	 * The base class for all XMPP stanza data classes.
	 *
	 * @see http://xmpp.org/rfcs/rfc3920.html#stanzas
	 */
	public dynamic class XMPPStanza extends XMLStanza implements ISerializable, IExtendable
	{
		public static const CLIENT_NAMESPACE:String = "jabber:client";
		
		/**
		 * The version of XMPP specified in RFC 3920 is "1.0"; in particular, this
		 * encapsulates the stream-related protocols (Use of TLS (Section 5),
		 * Use of SASL (Section 6), and Stream Errors (Section 4.7)), as well as
		 * the semantics of the three defined XML stanza types (<message/>,
		 * <presence/>, and <iq/>).
		 */
		public static const CLIENT_VERSION:String = "1.0";
		
		public static const NAMESPACE_FLASH:String = "http://www.jabber.com/streams/flash";
		public static const NAMESPACE_STREAM:String = "http://etherx.jabber.org/streams";
		public static const XML_LANG:String = "en";
	
		private var myErrorNode:XMLNode;
		private var myErrorConditionNode:XMLNode;
	
		//private static var theIDGenerator:IIDGenerator = new IncrementalGenerator();
		private static var staticDependencies:Array = [ IncrementalGenerator, ExtensionContainer ];
		private static var isStaticConstructed:* = XMPPStanzaStaticConstructor();
		
		/**
		 * The following four first attributes are common to message, presence, and IQ stanzas.
		 * The fifth, xml:lang, is not included here.
		 * @param	recipient	to
		 * @param	sender		from
		 * @param	theType		type
		 * @param	theID		id
		 * @param	nName
		 */
		public function XMPPStanza( recipient:EscapedJID, sender:EscapedJID, theType:String, theID:String, nName:String )
		{
			super();
			
			getNode().nodeName = nName;
			to = recipient;
			from = sender;
			type = theType;
			id = theID;
		}
	
		private static function XMPPStanzaStaticConstructor():void
		{
			//ExtensionContainer.decorate(XMPPStanza.prototype);
		}
	
		/**
		 * (Static method) Generates a unique ID for the stanza. ID generation is handled using
		 * a variety of mechanisms, but the default for the library uses the IncrementalGenerator.
		 *
		 * @see	org.igniterealtime.xiff.data.id.IncrementalGenerator
		 * @param	prefix The prefix for the ID to be generated
		 * @return The generated ID
		 */
		public static function generateID( prefix:String ):String
		{
			var id:String = IncrementalGenerator.getInstance().getID( prefix );
			return id;
		}
	
		/**
	 	 * (Static method) Sets the ID generator for this stanza type. ID generators must implement
		 * the IIDGenerator interface. The XIFF library comes with a few default
		 * ID generators that have already been implemented (see org.igniterealtime.xiff.data.id.*).
		 *
		 * Setting the ID generator by stanza type is useful if you'd like to use
		 * different ID generation schemes for each type. For instance, messages could
		 * use the incremental ID generation scheme provided by the IncrementalGenerator class, while
		 * IQs could use the shared object ID generation scheme provided by the SharedObjectGenerator class.
		 *
		 * @param	generator The ID generator class
		 * @example	The following sets the ID generator for the Message stanza type to the IncrementalGenerator
		 * class found in org.igniterealtime.xiff.data.id.IncrementalGenerator:
		 * <pre>Message.setIDGenerator( org.igniterealtime.xiff.data.id.IncrementalGenerator );</pre>
		 */
		public static function setIDGenerator( generator:IIDGenerator ):void
		{
			//XMPPStanza.theIDGenerator = generator;
		}
	
		/**
		 * Prepares the XML version of the stanza for transmission to the server.
		 *
		 * @param	parentNode (Optional) The parent node that the stanza should be appended to during serialization
		 * @return An indication as to whether serialization was successful
		 */
		public function serialize( parentNode:XMLNode ):Boolean
		{
			var node:XMLNode = getNode();
			var exts:Array = getAllExtensions();
	
			for each(var ext:ISerializable in exts) {
				ext.serialize(node);
			}
	
			if (!exists(node.parentNode)) {
				node = node.cloneNode(true)
				parentNode.appendChild(node);
			}
	
			return true;
		}
		
		public function deserialize( xmlNode:XMLNode ):Boolean
		{
			setNode(xmlNode);
			
			var children:Array = xmlNode.childNodes;
			for( var i:String in children )
			{
				
				var nName:String = children[i].nodeName;
				var nNamespace:String = children[i].attributes.xmlns;
				
				nNamespace = exists( nNamespace ) ? nNamespace : CLIENT_NAMESPACE;
				
				if( nName == "error" ) {
					myErrorNode = children[i];
					// If there is an error condition node, then we need that saved as well
					if( exists( myErrorNode.firstChild.nodeName ) ) {
						myErrorConditionNode = myErrorNode.firstChild;
					}
				}
				else {
					var extClass:Class = ExtensionClassRegistry.lookup(nNamespace);
					if (extClass != null) {
						var ext:IExtension = new extClass();
						ISerializable(ext).deserialize(children[i]);
						addExtension(ext);
					}
				}
			}
			return true;
		}
		
		/**
		 * The JID of the recipient.
		 *
		 */
		public function get to():EscapedJID
		{
			return new EscapedJID(getNode().attributes.to);
		}
		public function set to( value:EscapedJID ):void
		{
			delete getNode().attributes.to;
			if (exists(value))
			{
				getNode().attributes.to = value.toString();
			}
		}
		
		/**
		 * The JID of the sender. Most, if not all, server implementations follow the specifications
		 * that prevent this from being falsified. Thus, under normal circumstances, you don't
		 * need to supply this information because the server will fill it in automatically.
		 *
		 */
		public function get from():EscapedJID
		{
			// .@from.toString();
			var jid:String = getNode().attributes.from;
			return jid ? new EscapedJID(jid) : null;
		}
		
		public function set from( value:EscapedJID ):void
		{
			// .@from = sender.toString();
			delete getNode().attributes.from;
			if (exists(value)) { getNode().attributes.from = value.toString(); }
		}
		
		/**
		 * The stanza type. There are MANY types available, depending on what kind of stanza this is.
		 * The XIFF Library defines the types for IQ, Presence, and Message in each respective class
		 * as static string variables. Below is a listing of each:
		 *
		 * <b>IQ</b>
		 * <ul>
		 * <li>IQ.TYPE_ERROR</li>
		 * <li>IQ.TYPE_GET</li>
		 * <li>IQ.TYPE_RESULT</li>
		 * <li>IQ.TYPE_SET</li>
		 * </ul>
		 *
		 * <b>Presence</b>
		 * <ul>
		 * <li>Presence.TYPE_ERROR</li>
		 * <li>Presence.TYPE_PROBE</li>
		 * <li>Presence.TYPE_SUBSCRIBE</li>
		 * <li>Presence.TYPE_SUBSCRIBED</li>
		 * <li>Presence.TYPE_UNAVAILABLE</li>
		 * <li>Presence.TYPE_UNSUBSCRIBE</li>
		 * <li>Presence.TYPE_UNSUBSCRIBED</li>
		 * </ul>
		 *
		 * <b>Message</b>
		 * <ul>
		 * <li>Message.TYPE_CHAT</li>
		 * <li>Message.TYPE_ERROR</li>
		 * <li>Message.TYPE_GROUPCHAT</li>
		 * <li>Message.TYPE_HEADLINE</li>
		 * <li>Message.TYPE_NORMAL</li>
		 * </ul>
		 *
		 */
		public function get type():String
		{
			return getNode().attributes.type;
		}
		
		public function set type( value:String ):void
		{
			delete getNode().attributes.type;
			if (exists(value))
			{
				getNode().attributes.type = value;
			}
		}
		
		/**
		 * The unique identifier of this stanza. ID generation is accomplished using
		 * the static <code>generateID</code> method.
		 *
		 * @see	#generateID
		 */
		public function get id():String
		{
			return getNode().attributes.id;
		}
		
		public function set id( value:String ):void
		{
			delete getNode().attributes.id;
			if (exists(value))
			{
				getNode().attributes.id = value;
			}
		}
		
		/**
		 * The error message, assuming this stanza contains error information.
		 *
		 */
		public function get errorMessage():String
		{
			
			if ( exists( errorCondition ) )
			{
				//return myErrorConditionNode.firstChild.nodeValue;
				//return myErrorConditionNode.nextSibling.firstChild.nodeValue;  // fix recommended by bram 7/12/05
				return errorCondition.toString();
			}
			else if (myErrorNode && myErrorNode.firstChild)
			{
				return myErrorNode.firstChild.nodeValue;
			}
			return null;
		}
		
		public function set errorMessage( value:String ):void
		{
			myErrorNode = ensureNode( myErrorNode, "error" );
			
			value = exists( value ) ? value : "";
			
			if ( exists( errorCondition ) )
			{
				myErrorConditionNode = replaceTextNode( myErrorNode, myErrorConditionNode, errorCondition, value );
			}
			else
			{
				var attributes:Object = myErrorNode.attributes;
				myErrorNode = replaceTextNode( getNode(), myErrorNode, "error", value );
				myErrorNode.attributes = attributes;
			}
		}
		
		/**
		 * The error condition, assuming this stanza contains error information. For more information
		 * on error conditions, see <a href="http://xmpp.org/extensions/xep-0086.html">http://xmpp.org/extensions/xep-0086.html</a>.
		 *
		 */
		public function get errorCondition():String
		{
			if ( exists( myErrorConditionNode ) )
			{
				return myErrorConditionNode.nodeName;
			}
			
			return null;
		}
		
		public function set errorCondition( value:String ):void
		{
			myErrorNode = ensureNode( myErrorNode, "error" );
			
			// A message might exist, so remove it first
			var attributes:Object = myErrorNode.attributes;
			var msg:String = errorMessage;
			
			if ( exists( value ) )
			{
				myErrorNode = replaceTextNode( getNode(), myErrorNode, "error", "" );
				myErrorConditionNode = addTextNode( myErrorNode, value, msg );
			}
			else
			{
				myErrorNode = replaceTextNode( getNode(), myErrorNode, "error", msg );
			}
			
			myErrorNode.attributes = attributes;
		}
		
		/**
		 * The error type, assuming this stanza contains error information. For more information
		 * on error types, see <a href="http://xmpp.org/extensions/xep-0086.html">http://xmpp.org/extensions/xep-0086.html</a>.
		 *
		 */
		public function get errorType():String
		{
			return myErrorNode.attributes.type;
		}
		
		public function set errorType( value:String ):void
		{
			myErrorNode = ensureNode( myErrorNode, "error" );
			
			delete myErrorNode.attributes.type;
			if ( exists( value ) )
			{
				myErrorNode.attributes.type = value;
			}
		}
		
		/**
		 * The error code, assuming this stanza contains error information. Error codes are
		 * deprecated in standard XMPP, but they are commonly used by older Jabber servers
		 * like Jabberd 1.4. For more information on error codes, and corresponding error
		 * conditions, see <a href="http://xmpp.org/extensions/xep-0086.html">http://xmpp.org/extensions/xep-0086.html</a>.
		 *
		 */
		public function get errorCode():int
		{
			return parseInt( myErrorNode.attributes.code );
		}
		
		public function set errorCode( value:int ):void
		{
			myErrorNode = ensureNode( myErrorNode, "error" );
			
			delete myErrorNode.attributes.code;
			if ( exists( value ) )
			{
				myErrorNode.attributes.code = value;
			}
		}
	}
}
