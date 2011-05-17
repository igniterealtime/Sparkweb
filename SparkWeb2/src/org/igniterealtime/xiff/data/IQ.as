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

	/**
	 * A class for abstraction and encapsulation of IQ (info-query) data.
	 */
	public class IQ extends XMPPStanza implements ISerializable
	{
		private var myCallback:Function;
		
		private var myErrorCallback:Function;

		private var myQueryName:String;

		private var myQueryFields:Array;

		/**
		 * The stanza reports an error that has occurred
		 * regarding processing or delivery of a previously-sent get or
		 * set request.
		 * @see http://tools.ietf.org/html/draft-ietf-xmpp-3920bis-00#section-9.3
		 */
		public static const TYPE_ERROR:String = "error";

		/**
		 * The stanza requests information, inquires about what
		 * data is needed in order to complete further operations, etc.
		 */
		public static const TYPE_GET:String = "get";

		/**
		 * The stanza is a response to a successful get or set request.
		 */
		public static const TYPE_RESULT:String = "result";

		/**
		 * The stanza provides data that is needed for an
		 * operation to be completed, sets new values, replaces existing
		 * values, etc.
		 */
		public static const TYPE_SET:String = "set";

		/**
		 * A class for abstraction and encapsulation of IQ (info-query) data.
		 *
		 * @param	recipient The JID of the IQ recipient
		 * @param	iqType The type of the IQ - there are static variables declared for each type
		 * @param	iqID The unique ID of the IQ
		 * @param	iqCallback The function to be called when the server responds to the IQ
		 * @param	iqCallbackScope The object instance containing the callback method
		 */
		public function IQ( recipient:EscapedJID = null, iqType:String = null, iqID:String = null, iqCallback:Function = null, iqErrorCallback:Function = null )
		{
			var id:String = exists( iqID ) ? iqID : generateID( "iq_" );

			super( recipient, null, iqType, id, "iq" );

			callback = iqCallback;
			errorCallback = iqErrorCallback;
		}

		/**
		 * Serializes the IQ into XML form for sending to a server.
		 *
		 * @return An indication as to whether serialization was successful
		 */
		override public function serialize( parentNode:XMLNode ):Boolean
		{
			return super.serialize( parentNode );
		}

		/**
		 * Deserializes an XML object and populates the IQ instance with its data.
		 *
		 * @param	xmlNode The XML to deserialize
		 * @return An indication as to whether deserialization was sucessful
		 */
		override public function deserialize( xmlNode:XMLNode ):Boolean
		{
			return super.deserialize( xmlNode );
		}

		/**
		 * The function that will be called when an IQ result
		 * is received with the same ID as one you send.
		 *
		 * <p>Callback functions take one parameter which will be the IQ instance
		 * received from the server.</p>
		 *
		 * <p>This isn't a required property, but is useful if you
		 * need to respond to server responses to an IQ.</p>
		 */
		public function get callback():Function
		{
			return myCallback;
		}
		public function set callback( value:Function ):void
		{
			myCallback = value;
		}
		
		/**
		 * The function that will be called when an IQ error
		 * is received with the same ID as one you send.
		 *
		 * <p>Callback functions take one parameter which will be the IQ instance
		 * received from the server.</p>
		 *
		 * <p>This isn't a required property, but is useful if you
		 * need to respond to server responses to an IQ.</p>
		 */
		public function get errorCallback():Function
		{
			return myErrorCallback;
		}
		public function set errorCallback( value:Function ):void
		{
			myErrorCallback = value;
		}
	}
}
