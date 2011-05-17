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
	 * This class provides encapsulation for manipulation of presence data for sending and receiving.
	 */
	public class Presence extends XMPPStanza implements ISerializable
	{
		/**
		 * An error has occurred regarding processing of a
		 * previously-sent presence stanza; if the presence stanza is of type
		 * "error", it MUST include an error child element.
		 */
		public static const TYPE_ERROR:String = "error";

		/**
		 * A request for an entity's current presence; SHOULD be
		 * generated only by a server on behalf of a user.
		 */
		public static const TYPE_PROBE:String = "probe";

		/**
		 * The sender wishes to subscribe to the recipient's
		 * presence.
		 */
		public static const TYPE_SUBSCRIBE:String = "subscribe";

		/**
		 * The sender has allowed the recipient to receive their presence.
		 */
		public static const TYPE_SUBSCRIBED:String = "subscribed";

		/**
		 * Signals that the entity is no longer available for communication.
		 */
		public static const TYPE_UNAVAILABLE:String = "unavailable";

		/**
		 *  The sender is unsubscribing from the receiver's presence.
		 */
		public static const TYPE_UNSUBSCRIBE:String = "unsubscribe";

		/**
		 * The subscription request has been denied or a
		 * previously-granted subscription has been cancelled.
		 */
		public static const TYPE_UNSUBSCRIBED:String = "unsubscribed";

		/**
		 * The entity or resource is temporarily away.
		 */
		public static const SHOW_AWAY:String = "away";

		/**
		 * The entity or resource is actively interested in chatting.
		 */
		public static const SHOW_CHAT:String = "chat";

		/**
		 * The entity or resource is busy (dnd = "Do Not Disturb").
		 */
		public static const SHOW_DND:String = "dnd";

		/**
		 * The entity or resource is away for an extended period (xa = "eXtended Away").
		 */
		public static const SHOW_XA:String = "xa";
	
		// Private node references for property lookups
		private var myShowNode:XMLNode;
		private var myStatusNode:XMLNode;
		private var myPriorityNode:XMLNode;
	
		/**
		 *
		 * @param	recipient The recipient of the presence, usually in the form of a JID.
		 * @param	sender The sender of the presence, usually in the form of a JID.
		 * @param	presenceType The type of presence as a string. There are predefined static variables for
		 * @param	showVal What to show for this presence (away, online, etc.) There are predefined static variables for
		 * @param	statusVal The status; usually used for the "away message."
		 * @param	priorityVal The priority of this presence; usually on a scale of 1-5.
		 */
		public function Presence( recipient:EscapedJID = null, sender:EscapedJID = null, presenceType:String = null, showVal:String = null, statusVal:String = null, priorityVal:int = 0 )
		{
			super( recipient, sender, presenceType, null, "presence" );
			
			show = showVal;
			status = statusVal;
			priority = priorityVal;
		}
		
		/**
		 * Serializes the Presence into XML form for sending to a server.
		 *
		 * @return An indication as to whether serialization was successful
		 */
		override public function serialize( parentNode:XMLNode ):Boolean
		{
			return super.serialize( parentNode );
		}
		
		/**
		 * Deserializes an XML object and populates the Presence instance with its data.
		 *
		 * @param	xmlNode The XML to deserialize
		 * @return An indication as to whether deserialization was sucessful
		 */
		override public function deserialize( xmlNode:XMLNode ):Boolean
		{
			var isDeserialized:Boolean = super.deserialize( xmlNode );
			
			if (isDeserialized)
			{
				var children:Array = xmlNode.childNodes;
				for( var i:String in children )
				{
					switch( children[i].nodeName )
					{
						case "show":
							myShowNode = children[i];
							break;
							
						case "status":
							myStatusNode = children[i];
							break;
							
						case "priority":
							myPriorityNode = children[i];
							break;
					}
				}
			}
			return isDeserialized;
		}
		
		/**
		 * The show value; away, online, etc. There are predefined static variables in the Presence
		 * class for this:
		 * <ul>
		 * <li>Presence.SHOW_AWAY</li>
		 * <li>Presence.SHOW_CHAT</li>
		 * <li>Presence.SHOW_DND</li>
		 * <li>Presence.SHOW_XA</li>
		 * </ul>
		 *
		 */
		public function get show():String
		{
			if (!myShowNode || !exists(myShowNode.firstChild)) return null;
			
			return myShowNode.firstChild.nodeValue;
		}
		public function set show( value:String ):void
		{
			if (value != SHOW_AWAY
			&& value != SHOW_CHAT
			&& value != SHOW_DND
			&& value != SHOW_XA
			&& value != null
			&& value != "")
				throw new Error("Invalid show value: " + value + " for presence");
			
			if (myShowNode && (value == null || value == ""))
			{
				myShowNode.removeNode();
				myShowNode = null;
			}
			myShowNode = replaceTextNode(getNode(), myShowNode, "show", value);
		}
		
		/**
		 * The status; usually used for "away messages."
		 *
		 */
		public function get status():String
		{
			if (myStatusNode == null || myStatusNode.firstChild == null) return null;
			return myStatusNode.firstChild.nodeValue;
		}
		public function set status( value:String ):void
		{
			myStatusNode = replaceTextNode(getNode(), myStatusNode, "status", value);
		}
		
		/**
		 * The priority of the presence, usually on a scale of 1-5.
		 * RFC: "The value MUST be an integer between -128 and +127"
		 */
		public function get priority():int
		{
			if (myPriorityNode == null)
			{
				return NaN;
			}
			var p:int = int(myPriorityNode.firstChild.nodeValue);
			if ( isNaN( p ) )
			{
				return NaN;
			}
			else
			{
				return p;
			}
		}
		public function set priority( value:int ):void
		{
			// TODO: Check limits.
			myPriorityNode = replaceTextNode(getNode(), myPriorityNode, "priority", value.toString());
		}
	}
}
