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
package org.igniterealtime.xiff.data.im{

	
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.Extension;
	import org.igniterealtime.xiff.data.ExtensionClassRegistry;
	import org.igniterealtime.xiff.data.IExtension;
	import org.igniterealtime.xiff.data.ISerializable;
	 
	/**
	 * An IQ extension for roster data. Roster data is typically any data
	 * that is sent or received with the "jabber:iq:roster" namespace.
	 *
	 * @param	theRoot The extension root
	 * @param	theNode The extension node
	 */
	public class RosterExtension extends Extension implements IExtension, ISerializable
	{
		public static const NS:String = "jabber:iq:roster";
		public static const ELEMENT_NAME:String = "query";
		
		public static const SUBSCRIBE_TYPE_NONE:String = "none";
		public static const SUBSCRIBE_TYPE_TO:String = "to";
		public static const SUBSCRIBE_TYPE_FROM:String = "from";
		public static const SUBSCRIBE_TYPE_BOTH:String = "both";
		public static const SUBSCRIBE_TYPE_REMOVE:String = "remove";
		public static const ASK_TYPE_NONE:String = "none";
		public static const ASK_TYPE_SUBSCRIBE:String = "subscribe";
		public static const ASK_TYPE_UNSUBSCRIBE:String = "unsubscribe";
		public static const SHOW_UNAVAILABLE:String = "unavailable";
		public static const SHOW_PENDING:String = "Pending";
		
	    private static var staticDepends:Array = [ExtensionClassRegistry];
	
		private var _items:Array = [];
		
		public function RosterExtension( parent:XMLNode = null )
		{
			super( parent );
		}
	
		/**
		 * Gets the namespace associated with this extension.
		 * The namespace for the RosterExtension is "jabber:iq:roster".
		 *
		 * @return The namespace
		 */
		public function getNS():String
		{
			return RosterExtension.NS;
		}
	
		/**
		 * Gets the element name associated with this extension.
		 * The element for this extension is "query".
		 *
		 * @return The element name
		 */
		public function getElementName():String
		{
			return RosterExtension.ELEMENT_NAME;
		}
		
	    /**
	     * Performs the registration of this extension into the extension registry.  
	     * 
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(RosterExtension);
	    }
	
		/**
		 * Serializes the RosterExtension data to XML for sending.
		 *
		 * @param	parent The parent node that this extension should be serialized into
		 * @return An indicator as to whether serialization was successful
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
			var node:XMLNode = getNode();
			
			// Serialize each roster item
			for( var i:String in _items ) {
				if( !_items[i].serialize( node ) ){
					return false;
				}
			}
			
			if( !exists( getNode().parentNode ) ) {
				parent.appendChild( getNode().cloneNode( true ) );
			}
			
			return true;
		}
		
		/**
		 * Deserializes the RosterExtension data.
		 *
		 * @param	node The XML node associated this data
		 * @return An indicator as to whether deserialization was successful
		 */
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode( node );
			removeAllItems();
			
			var children:Array = node.childNodes;
			for( var i:String in children ){
				switch( children[i].nodeName ) {
					case "item":
						var item:RosterItem = new RosterItem( getNode() );
						if( !item.deserialize( children[i] ) ) {
							return false;
						}
						_items.push( item );
						break;
				}
			}
			
			return true;
		}
		
		/**
		 * Get all the items from this roster query.
		 *
		 * @return An array of roster items.
		 */
		public function getAllItems():Array
		{
			return _items;
		}
		
		/**
		 * Gets one item from the roster query, returning the first item found with the JID specified. If none is found, then it returns null.
		 *
		 * @return A roster item object with the following attributes: "jid", "subscription", "displayName", and "groups".
		 */
		public function getItemByJID( jid:EscapedJID ):RosterItem
		{
			for( var i:String in _items ) {
				if( _items[i].jid == jid.toString() ) {
					return _items[i];
				}
			}
			
			return null;
		}
		
		/**
		 * Adds a single roster item to the extension payload.
		 *
		 * @param	jid The JID of the contact to add
		 * @param	subscription The subscription type of the roster item contact. There are pre-defined static variables for these string options in this class definition.
		 * @param	displayName The display name or nickname of the contact.
		 * @param	groups An array of strings of the group names that this contact should be placed in.
		 */
		public function addItem( jid:EscapedJID=null, subscription:String="", displayName:String="", groups:Array=null ):void
		{
			var item:RosterItem = new RosterItem( getNode() );
			
			if( exists( jid ) ) { item.jid = jid }
			if( exists( subscription ) ) { item.subscription = subscription; }
			if( exists( displayName ) ) { item.name = displayName; }
			if( exists( groups ) ) {
				for each( var group:String in groups ) {
					if(group)
						item.addGroupNamed( group );
				}
			}
		}
		
		/**
		 * Removes all items from the roster data.
		 *
		 */
		public function removeAllItems():void
		{
			for( var i:String in _items ) {
				_items[i].setNode( null );
			}
			
			_items = [];
		}
	}
}