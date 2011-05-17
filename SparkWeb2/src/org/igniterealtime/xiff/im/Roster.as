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
package org.igniterealtime.xiff.im
{
	import flash.utils.Dictionary;
	
	import org.igniterealtime.xiff.collections.ArrayCollection;
	import org.igniterealtime.xiff.core.*;
	import org.igniterealtime.xiff.data.*;
	import org.igniterealtime.xiff.data.im.*;
	import org.igniterealtime.xiff.events.*;

	/**
	 * Broadcast whenever someone revokes your presence subscription. This is not
	 * an event that is fired when you revoke a subscription, but rather when one of your
	 * contacts decides that he/she/it no longer wants you to know about their presence
	 * status.
	 *
	 * The event object contains an attribute <code>jid</code> with the JID of
	 * the user who revoked your subscription.
	 * @eventType org.igniterealtime.xiff.events.RosterEvent.SUBSCRIPTION_REVOCATION
	 */
	[Event(name="subscriptionRevocation", type="org.igniterealtime.xiff.events.RosterEvent")]
	
	/**
	 * Broadcast whenever someone requests to subscribe to your presence. The event object
	 * contains an attribute <code>jid</code> with the JID of the user who is requesting
	 * a presence subscription.
	 * @eventType org.igniterealtime.xiff.events.RosterEvent.SUBSCRIPTION_REQUEST
	 */
	[Event(name="subscriptionRequest", type="org.igniterealtime.xiff.events.RosterEvent")]
	
	/**
	 * Broadcast whenever a subscription request that you make (via the <code>addContact()</code>
	 * or <code>requestSubscription()</code> methods) is denied.
	 *
	 * The event object contains an attribute <code>jid</code> with the JID of the user who
	 * denied the request.
	 * @eventType org.igniterealtime.xiff.events.RosterEvent.SUBSCRIPTION_DENIAL
	 */
	[Event(name="subscriptionDenial", type="org.igniterealtime.xiff.events.RosterEvent")]
	
	/**
	 * Broadcast whenever a contact in the roster becomes unavailable. (Goes from online to offline.)
	 * The event object contains an attribute <code>jid</code> with the JID of the user who
	 * became unavailable.
	 * @eventType org.igniterealtime.xiff.events.RosterEvent.USER_UNAVAILABLE
	 */
	[Event(name="userAvailable", type="org.igniterealtime.xiff.events.RosterEvent")]
	
	/**
	 * Broadcast whenever a contact in the roster becomes available. (Goes from offline to online.)
	 * The event object contains an attribute <code>jid</code> with the JID of the user who
	 * became available.
	 * @eventType org.igniterealtime.xiff.events.RosterEvent.USER_AVAILABLE
	 */
	[Event(name="userAvailable", type="org.igniterealtime.xiff.events.RosterEvent")]
	
	/**
	 * @eventType org.igniterealtime.xiff.events.RosterEvent.ROSTER_LOADED
	 */
	[Event(name="rosterLoaded", type="org.igniterealtime.xiff.events.RosterEvent")]
	
	/**
	 * @eventType org.igniterealtime.xiff.events.RosterEvent.USER_REMOVED
	 */
	[Event(name="userRemoved", type="org.igniterealtime.xiff.events.RosterEvent")]
	
	/**
	 * @eventType org.igniterealtime.xiff.events.RosterEvent.USER_PRESENCE_UPDATED
	 */
	[Event(name="userPresenceUpdated", type="org.igniterealtime.xiff.events.RosterEvent")]
	
	/**
	 * @eventType org.igniterealtime.xiff.events.RosterEvent.USER_SUBSCRIPTION_UPDATED
	 */
	[Event(name="userSubscriptionUpdated", type="org.igniterealtime.xiff.events.RosterEvent")]
	
	/**
	 * Manages a user's server-side instant messaging roster (or "buddy list"). By default,
	 * this class uses an internal data provider to keep track of roster data locally and
	 * provides a "read-only" form of the Data Provider API for external use. Non-read operations
	 * are performed using alternative, roster-specific methods.
	 */
	public class Roster extends ArrayCollection
	{

		private static var rosterStaticConstructed:Boolean = RosterStaticConstructor();

		private static const staticConstructorDependencies:Array = [ ExtensionClassRegistry,
																	 RosterExtension ]

		private var _connection:XMPPConnection;

		/**
		 * Store groups as RosterGroup.
		 */
		private var _groups:Object = {};

		/**
		 * Store presences of the people in users roster.
		 */
		private var _presenceMap:Object = {};
		
		/**
		 * List of <code>UnescapedJID</code> which are pending for subscription.
		 */
		private var pendingSubscriptionRequests : Dictionary = new Dictionary();

		/**
		 *
		 * @param	aConnection A reference to an XMPPConnection class instance
		 */
		public function Roster( aConnection:XMPPConnection = null )
		{
			if ( aConnection != null )
			{
				connection = aConnection;
			}
		}

		/**
		 *
		 * @return
		 */
		private static function RosterStaticConstructor():Boolean
		{
			ExtensionClassRegistry.register( RosterExtension );
			return true;
		}

		/**
		 * Adds a contact to the roster. Remember: All roster data is managed on the server-side,
		 * so this contact is added to the server-side roster first, and upon successful addition,
		 * reflected in the local client-side copy of the roster.
		 *
		 * @param	id The JID of the contact to add
		 * @param	displayName A friendly name for use when displaying this contact in the roster
		 * @param	groupName (Optional) The name of the group that this contact should be added to. (Used for
		 * organization in the roster listing.
		 * @param	requestSubscription (Optional) Determines whether a subscription request should be sent
		 * to this user. Most of the time you will want this parameter to be true.
		 * You will be unable to view the contacts presence status until a subscription request is granted.
		 * @example	This example adds a contact to the roster and simultaneously requests a presence subscription
		 * with the new contact.
		 * <pre>myRoster.addContact( "homer@springfield.com", "Homer", "Drinking Buddies", true );</pre>
		 */
		public function addContact( id:UnescapedJID, displayName:String, groupName:String = null, requestSubscription:Boolean = true ):void
		{
			if ( displayName == null )
			{
				displayName = id.toString();
			}

			var callbackMethod:Function = null;
			var subscription:String = RosterExtension.SUBSCRIBE_TYPE_NONE;
			var askType:String = RosterExtension.ASK_TYPE_NONE;
			var iqID : String = XMPPStanza.generateID( "add_user_" );

			if ( requestSubscription == true )
			{
				callbackMethod = addContact_result;
				pendingSubscriptionRequests[ iqID.toString() ] = id;
				subscription = RosterExtension.SUBSCRIBE_TYPE_TO;
				askType = RosterExtension.ASK_TYPE_SUBSCRIBE
			}

			var iq:IQ = new IQ( null, IQ.TYPE_SET, iqID, callbackMethod );
			var ext:RosterExtension = new RosterExtension( iq.getNode() );
			ext.addItem( id.escaped, null, displayName, groupName ? [ groupName ] :
						 null );
			iq.addExtension( ext );
			_connection.send( iq );


			addRosterItem( id, displayName, RosterExtension.SHOW_PENDING, RosterExtension.SHOW_PENDING,
						   [ groupName ], subscription, askType );
		}

		/**
		 *
		 * @param	resultIQ
		 */
		public function addContact_result( resultIQ:IQ ):void
		{
			// Contact was added, request subscription

			var iqID : String = resultIQ.id.toString();

			if ( pendingSubscriptionRequests.hasOwnProperty( iqID ) )
			{
				var subscriptionId : UnescapedJID = pendingSubscriptionRequests[ iqID ] as UnescapedJID;
				requestSubscription( subscriptionId );
				delete( pendingSubscriptionRequests[ iqID ] );
			}
		}

		/**
		 * Revokes an existing presence subscription or denies a subscription request. If a user
		 * has sent you a subscription request you can use this method to deny that request. Otherwise,
		 * if a user already has a granted presence subscription, you can use this method to revoke that
		 * subscription.
		 *
		 * @param	tojid The JID of the user or service that you are denying subscription
		 */
		public function denySubscription( tojid:UnescapedJID ):void
		{
			var presence:Presence = new Presence( tojid.escaped, null, Presence.TYPE_UNSUBSCRIBED );
			_connection.send( presence );
		}

		/**
		 * Fetches the roster data from the server. Once the data has been fetched, the Roster's data
		 * provider is populated appropriately. If the Roster-XMPPConnection class dependency has been
		 * set up before logging in, then this method will be called automatically because the Roster
		 * listens for "login" events from the XMPPConnection.
		 */
		public function fetchRoster():void
		{
			var iq:IQ = new IQ( null, IQ.TYPE_GET, XMPPStanza.generateID( "roster_" ),
									fetchRoster_result );
			iq.addExtension( new RosterExtension( iq.getNode() ) );
			_connection.send( iq );
		}

		/**
		 *
		 * @param	resultIQ
		 */
		public function fetchRoster_result( resultIQ:IQ ):void
		{
			// Clear out the old roster
			removeAll();
			try
			{
				for each ( var ext:RosterExtension in resultIQ.getAllExtensionsByNS( RosterExtension.NS ) )
				{
					for each ( var item:*in ext.getAllItems() )
					{
						//var classInfo:XML = flash.utils.describeType(item);
						if ( !item is XMLStanza )
						{
							continue;
						}

						var askType:String = item.askType != null ? item.askType.toLowerCase() :
							RosterExtension.ASK_TYPE_NONE;
						addRosterItem( new UnescapedJID( item.jid ), item.name, RosterExtension.SHOW_UNAVAILABLE,
									   "Offline", item.groupNames, item.subscription.toLowerCase(),
									   askType );
					}
				}

				// Fire Roster Loaded Event
				var rosterEvent:RosterEvent = new RosterEvent( RosterEvent.ROSTER_LOADED,
															   false, false );
				dispatchEvent( rosterEvent );
			}
			catch ( error:Error )
			{
				trace( error.getStackTrace() );
			}
		}

		/**
		 *
		 * @param	item
		 * @return
		 */
		public function getContainingGroups( item:RosterItemVO ):Array
		{
			var result:Array = [];
			for ( var key:String in _groups )
			{
				var group:RosterGroup = _groups[ key ] as RosterGroup;
				if ( group.contains( item ) )
				{
					result.push( group );
				}
			}
			return result;
		}

		/**
		 * Get a group by given name
		 * @param	name
		 * @return
		 */
		public function getGroup( name:String ):RosterGroup
		{
			return _groups[ name ] as RosterGroup;
		}

		/**
		 * Get the Presence of the given user if any.
		 * @param	jid
		 * @return
		 */
		public function getPresence( jid:UnescapedJID ):Presence
		{
			return _presenceMap[ jid.toString() ] as Presence;
		}

		/**
		 * Grants a user or service authorization for subscribing to your presence. Once authorization
		 * is granted, the user can see whether you are offline, online, away, etc. Subscriptions can
		 * be revoked at any time using the <code>denySubscription()</code> method.
		 *
		 * @param	tojid The JID of the user or service to grant subscription to
		 * @param	requestAfterGrant Whether or not a reciprocal subscription request should be sent
		 * to the grantee, so that you may, in turn, subscribe to his/her/its presence.
		 */
		public function grantSubscription( tojid:UnescapedJID, requestAfterGrant:Boolean = true ):void
		{
			var presence:Presence = new Presence( tojid.escaped, null, Presence.TYPE_SUBSCRIBED );
			_connection.send( presence );

			// Request a return subscription
			if ( requestAfterGrant )
			{
				requestSubscription( tojid, true );
			}
		}

		/**
		 * Removes a contact from the roster and revokes all presence subscriptions for that contact.
		 * This method will only attempt action if the contact you are trying to remove is currently on the
		 * roster in the first place.
		 *
		 * @param	rosterItem The value object which is to be removed
		 */
		public function removeContact( rosterItem:RosterItemVO ):void
		{
			if ( contains( rosterItem ) )
			{
				var iq:IQ = new IQ( null, IQ.TYPE_SET, XMPPStanza.generateID( "remove_user_" ),
										unsubscribe_result );
				var ext:RosterExtension = new RosterExtension( iq.getNode() );
				ext.addItem( new EscapedJID( rosterItem.jid.bareJID ), RosterExtension.SUBSCRIBE_TYPE_REMOVE );
				iq.addExtension( ext );
				_connection.send( iq );

				//the roster item is not actually removed from the roster
				//until confirmation comes back from the XMPP server
			}
		}

		/**
		 * Requests subscription authorization with a user or service. In the XMPP-world, you cannot receive
		 * notifications on changes to a contact's presence until that contact has authorized you to subscribe
		 * to his/her/its presence.
		 *
		 * @param	id The JID of the user or service that you wish to subscribe to
		 * @param	isResponse
		 * @see	#subscriptionDenial
		 */
		public function requestSubscription( id:UnescapedJID, isResponse:Boolean = false ):void
		{
			// Roster length is 0 if it a response to a user request. we must handle this event.
			var presence:Presence;
			if ( isResponse )
			{
				presence = new Presence( id.escaped, null, Presence.TYPE_SUBSCRIBE );
				_connection.send( presence );
				return;
			}
			// Only request for items in the roster
			if ( contains( RosterItemVO.get( id, false ) ) )
			{
				presence = new Presence( id.escaped, null, Presence.TYPE_SUBSCRIBE );
				_connection.send( presence );
			}
		}

		/**
		 * Sets your current presence status. Calling this method notifies others who
		 * are subscribed to your presence of a presence change. You should use this to
		 * change your status to away, extended-away, etc. There are static variables that
		 * you can use defined in the presence class for the <code>show</code> parameter:
		 * <ul>
		 * <li><code>Presence.SHOW_AWAY</code></li>
		 * <li><code>Presence.SHOW_CHAT</code></li>
		 * <li><code>Presence.SHOW_DND</code></li>
		 * <li><code>Presence.SHOW_NORMAL</code></li>
		 * <li><code>Presence.SHOW_XA</code></li>
		 * </ul>
		 *
		 * @param	show The show type for your presence. This represents what others should see - whether
		 * you are offline, online, away, etc.
		 * @param	status The status message associated with the show value
		 * @param	priority (Optional) A priority integer for the presence
		 * @see	org.igniterealtime.xiff.data.Presence
		 */
		public function setPresence( show:String, status:String, priority:int ):void
		{
			var presence:Presence = new Presence( null, null, null, show, status, priority );
			_connection.send( presence );
		}

		/**
		 *
		 * @param	resultIQ
		 */
		public function unsubscribe_result( resultIQ:IQ ):void
		{
			// Does nothing for now
		}

		/**
		 * Updates the groups associated with an existing contact.
		 *
		 * @param	rosterItem The value object of the contact to update
		 * @param	newGroups The new groups to associate the contact with
		 */
		public function updateContactGroups( rosterItem:RosterItemVO, newGroupNames:Array ):void
		{
			updateContact( rosterItem, rosterItem.displayName, newGroupNames );
		}

		/**
		 * Updates the display name for an existing contact.
		 *
		 * @param	rosterItem The value object of the contact to update
		 * @param	newName The new display name for this contact
		 */
		public function updateContactName( rosterItem:RosterItemVO, newName:String ):void
		{
			var groupNames:Array = [];
			for each ( var group:RosterGroup in getContainingGroups( rosterItem ) )
			{
				groupNames.push( group.label );
			}
			updateContact( rosterItem, newName, groupNames );
		}

		/**
		 *
		 * @param	jid
		 * @param	displayName
		 * @param	show
		 * @param	status
		 * @param	groupNames
		 * @param	type
		 * @param	askType
		 * @return
		 */
		private function addRosterItem( jid:UnescapedJID, displayName:String, show:String, status:String, groupNames:Array, type:String, askType:String = "none" ):Boolean
		{
			if ( !jid )
			{
				return false;
			}

			var rosterItem:RosterItemVO = RosterItemVO.get( jid, true );
			if ( !contains( rosterItem ) )
			{
				addItem( rosterItem );
			}
			if ( displayName )
			{
				rosterItem.displayName = displayName;
			}
			rosterItem.subscribeType = type;
			rosterItem.askType = askType;
			rosterItem.status = status;
			rosterItem.show = show;
			setContactGroups( rosterItem, groupNames );

			var event:RosterEvent = new RosterEvent( RosterEvent.USER_ADDED );
			event.jid = jid;
			event.data = rosterItem;
			dispatchEvent( event );

			return true;
		}

		/**
		 *
		 * @param	eventObj PresenceEvent, LoginEvent or RosterExtension
		 */
		private function handleEvent( eventObj:* ):void
		{

			switch ( eventObj.type )
			{
				// Handle any incoming presence items
				case PresenceEvent.PRESENCE:
					handlePresences( eventObj.data );
					break;

				// Fetch the roster immediately after login
				case LoginEvent.LOGIN:
					fetchRoster();
					// Tell the server we are online and available
					//setPresence( Presence.SHOW_NORMAL, "Online", 5 );
					setPresence( null, "Online", 5 );
					break;

				case RosterExtension.NS:
					try
					{
						var ext:RosterExtension = ( eventObj.iq as IQ ).getAllExtensionsByNS( RosterExtension.NS )[ 0 ] as
							RosterExtension;
						var items:Array = ext.getAllItems();
						for each ( var item:*in items )
						{
							var jid:UnescapedJID = new UnescapedJID( item.jid );
							var rosterItemVO:RosterItemVO = RosterItemVO.get( jid,
																			  true );
							var rosterEvent:RosterEvent;

							if ( contains( rosterItemVO ) )
							{
								switch ( item.subscription.toLowerCase() )
								{
									case RosterExtension.SUBSCRIBE_TYPE_NONE:
										rosterEvent = new RosterEvent( RosterEvent.SUBSCRIPTION_REVOCATION );
										rosterEvent.jid = jid;
										dispatchEvent( rosterEvent );
										break;

									case RosterExtension.SUBSCRIBE_TYPE_REMOVE:
										rosterEvent = new RosterEvent( RosterEvent.USER_REMOVED );
										for each ( var group:RosterGroup in getContainingGroups( rosterItemVO ) )
										{
											group.removeItem( rosterItemVO );
										}
										//should be impossible for getItemIndex to return -1, since we just looked it up
										rosterEvent.data = removeItemAt( getItemIndex( rosterItemVO ) );;
										rosterEvent.jid = jid;
										dispatchEvent( rosterEvent );
										break;

									default:
										updateRosterItemSubscription( rosterItemVO,
																	  item.subscription.toLowerCase(),
																	  item.name,
																	  item.groupNames );
										break;
								}
							}
							else
							{
								var groupNames:Array = item.groupNames;
								var askType:String = item.askType != null ? item.askType.toLowerCase() :
									RosterExtension.ASK_TYPE_NONE;

								if ( item.subscription.toLowerCase() != RosterExtension.SUBSCRIBE_TYPE_REMOVE &&
									item.subscription.toLowerCase() != RosterExtension.SUBSCRIBE_TYPE_NONE )
								{
									// Add this item to the roster if it's not there and if the subscription type is not equal to 'remove' or 'none'
									addRosterItem( jid, item.name, RosterExtension.SHOW_UNAVAILABLE,
												   "Offline", groupNames, item.subscription.toLowerCase(),
												   askType );
								}
								else if ( ( item.subscription.toLowerCase() == RosterExtension.SUBSCRIBE_TYPE_NONE ||
									item.subscription.toLowerCase() == RosterExtension.SUBSCRIBE_TYPE_FROM ) &&
									item.askType == RosterExtension.ASK_TYPE_SUBSCRIBE )
								{
									// A contact was added to the roster, and its authorization is still pending.
									addRosterItem( jid, item.name, RosterExtension.SHOW_PENDING,
												   "Pending", groupNames, item.subscription.toLowerCase(),
												   askType );
								}
							}
						}
					}
					catch ( error:Error )
					{
						trace( error.getStackTrace() );
					}
					break;
			}
		}

		/**
		 * Dispathing <code>RosterEvent</code> based on the types of the <code>Presence</code>.
		 * @param	presenceArray	A pile of presences received at one time
		 */
		private function handlePresences( presenceArray:Array ):void
		{
			for each ( var aPresence:Presence in presenceArray )
			{
				var type:String = aPresence.type ? aPresence.type.toLowerCase() : null;
				var rosterEvent:RosterEvent = null;

				switch ( type )
				{
					case Presence.TYPE_SUBSCRIBE:
						rosterEvent = new RosterEvent( RosterEvent.SUBSCRIPTION_REQUEST );
						break;

					case Presence.TYPE_UNSUBSCRIBED:
						rosterEvent = new RosterEvent( RosterEvent.SUBSCRIPTION_DENIAL );
						break;

					case Presence.TYPE_UNAVAILABLE:
						rosterEvent = new RosterEvent( RosterEvent.USER_UNAVAILABLE );

						var unavailableItem:RosterItemVO = RosterItemVO.get( aPresence.from.unescaped, false );
						if ( !unavailableItem )
							break;
						updateRosterItemPresence( unavailableItem, aPresence );

						break;

					// null means available
					default:
						rosterEvent = new RosterEvent( RosterEvent.USER_AVAILABLE );
						rosterEvent.data = aPresence;

						// Change the item on the roster
						var availableItem:RosterItemVO;
						if ( aPresence.from )
							availableItem = RosterItemVO.get( aPresence.from.unescaped, false );

						if ( !availableItem )
							break;
						updateRosterItemPresence( availableItem, aPresence );

						break;
				}

				if ( rosterEvent != null )
				{
					// from can sometimes not be set
					if ( aPresence.from )
					{
						rosterEvent.jid = aPresence.from.unescaped;
					}
					dispatchEvent( rosterEvent );
				}
			}
		}

		/**
		 *
		 * @param	contact
		 * @param	groupNames
		 */
		private function setContactGroups( contact:RosterItemVO, groupNames:Array ):void
		{
			if ( !groupNames || groupNames.length == 0 )
			{
				groupNames = [ "General" ];
			}
			for each ( var name:String in groupNames )
			{
				//if there's no group by this name already, we need to make one
				if ( !getGroup( name ) )
					_groups[ name ] = new RosterGroup( name );
			}
			for each ( var group:RosterGroup in _groups )
			{
				if ( groupNames.indexOf( group.label ) >= 0 )
				{
					group.addItem( contact );
				}
				else
				{
					group.removeItem( contact );
				}
			}
		}

		/**
		 * Updates the information for an existing contact. You can use this method to change the
		 * display name or associated group for a contact in your roster.
		 *
		 * @param	rosterItem The value object of the contact to update
		 * @param	newName The new display name for this contact
		 * @param	newGroups The new groups to associate the contact with
		 */
		private function updateContact( rosterItem:RosterItemVO, newName:String, groupNames:Array ):void
		{
			var iq:IQ = new IQ( null, IQ.TYPE_SET, XMPPStanza.generateID( "update_contact_" ) );
			var ext:RosterExtension = new RosterExtension( iq.getNode() );

			ext.addItem( rosterItem.jid.escaped, rosterItem.subscribeType, newName,
						 groupNames );
			iq.addExtension( ext );
			_connection.send( iq );
		}

		/**
		 *
		 * @param	item
		 * @param	presence
		 */
		private function updateRosterItemPresence( item:RosterItemVO, presence:Presence ):void
		{
			try
			{
				item.status = presence.status;
				item.show = presence.show;
				item.priority = presence.priority;
				if ( !presence.type )
				{
					item.online = true;
				}
				else if ( presence.type == Presence.TYPE_UNAVAILABLE )
				{
					item.online = false;
				}
				itemUpdated( item );

				var event:RosterEvent = new RosterEvent( RosterEvent.USER_PRESENCE_UPDATED );
				event.jid = item.jid;
				event.data = item;
				dispatchEvent( event );

				_presenceMap[ item.jid.toString() ] = presence;
			}
			catch ( error:Error )
			{
				trace( error.getStackTrace() );
			}
		}

		/**
		 *
		 * @param	item
		 * @param	type
		 * @param	name
		 * @param	newGroupNames
		 */
		private function updateRosterItemSubscription( item:RosterItemVO, type:String, name:String, newGroupNames:Array ):void
		{
			item.subscribeType = type;

			setContactGroups( item, newGroupNames );

			if ( name )
			{
				item.displayName = name;
			}

			var event:RosterEvent = new RosterEvent( RosterEvent.USER_SUBSCRIPTION_UPDATED );
			event.jid = item.jid;
			event.data = item;
			dispatchEvent( event );
		}

		/**
		 * The instance of the XMPPConnection class to use for the roster to use for
		 * sending and receiving data.
		 */
		public function get connection():XMPPConnection
		{
			return _connection;
		}

		public function set connection( value:XMPPConnection ):void
		{
			_connection = value;
			_connection.addEventListener( PresenceEvent.PRESENCE, handleEvent );
			_connection.addEventListener( LoginEvent.LOGIN, handleEvent );
			_connection.addEventListener( RosterExtension.NS, handleEvent );
		}
	}
}
