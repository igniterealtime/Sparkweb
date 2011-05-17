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
package org.igniterealtime.xiff.collections
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import org.igniterealtime.xiff.collections.events.CollectionEvent;
	import org.igniterealtime.xiff.collections.events.CollectionEventKind;
	
	/**
	 * The ArrayCollection class is a wrapper class that exposes an Array as a
	 * collection that can be accessed and manipulated using collection methods.
	 */
	public class ArrayCollection extends Proxy implements IEventDispatcher
	{
		protected const OUT_OF_BOUNDS_MESSAGE:String = "The supplied index is out of bounds.";
		
		protected var eventDispatcher:EventDispatcher;
		
		protected var _source:Array = [];
		
		/**
		 * Constructor.
		 */
		public function ArrayCollection( source:Array = null )
		{
			super();
			
			eventDispatcher = new EventDispatcher( this );
			
			if (source)
			{
				this.source = source;
			}
		}
		
		/**
		 * The source of data in the ArrayCollection.
		 */
		public function get source():Array
		{
			return _source;
		}
		
		/**
		 * @private
		 */
		public function set source( value:Array ):void
		{
			_source = value ? value : [];
			internalDispatchEvent( CollectionEventKind.RESET );
		}
		
		/**
		 * The number of items in the ArrayCollection.
		 */
		public function get length():int
		{
			return _source ? _source.length : 0;
		}
		
		/**
		 * Get the item at the specified index.
		 */
		public function getItemAt( index:int ):*
		{
			if ( index < 0 || index >= length )
			{
				throw new RangeError( OUT_OF_BOUNDS_MESSAGE );
			}
			
			return _source[ index ];
		}
		
		/**
		 * Places the item at the specified index.
		 * If an item was already at that index the new item will replace it
		 * and it will be returned.
		 */
		public function setItemAt( item:*, index:int ):*
		{
			if ( index < 0 || index >= length )
			{
				throw new RangeError( OUT_OF_BOUNDS_MESSAGE );
			}
			
			var replaced:* = _source.splice( index, 1, item )[ 0 ];
			internalDispatchEvent( CollectionEventKind.REPLACE, item, index );
			return replaced;
		}
		
		/**
		 * Add the specified item to the end of the list.
		 * Equivalent to addItemAt( item, length );
		 */
		public function addItem( item:* ):void
		{
			addItemAt( item, length );
		}
		
		/**
		 * Add the specified item at the specified index.
		 * Any item that was after this index is moved out by one.
		 */
		public function addItemAt( item:*, index:int ):void
		{
			if ( index < 0 || index > length )
			{
				throw new RangeError( OUT_OF_BOUNDS_MESSAGE );
			}
			
			_source.splice( index, 0, item );
			
			internalDispatchEvent( CollectionEventKind.ADD, item, index );
		}
		
		/**
		 * Get the index of the item if it is in the ArrayCollection such that getItemAt( index ) == item.
		 */
		public function getItemIndex( item:* ):int
		{
			var n:int = _source.length;
			
			for ( var i:int = 0; i < n; i++ )
			{
				if ( _source[ i ] === item ) return i;
			}
			
			return -1;
		}
		
		/**
		 * Remove the specified item from this list, should it exist.
		 */
		public function removeItem( item:* ):Boolean
		{
			var index:int = getItemIndex( item );
			var result:Boolean = index >= 0;
			
			if ( result )
			{
				removeItemAt( index );
			}
			
			return result;
		}
		
		/**
		 * Removes the item at the specified index and returns it.
		 * Any items that were after this index are now one index earlier.
		 */
		public function removeItemAt( index:int ):*
		{
			if ( index < 0 || index >= length )
			{
				throw new RangeError( OUT_OF_BOUNDS_MESSAGE );
			}
			
			var removed:* = _source.splice( index, 1 )[ 0 ];
			internalDispatchEvent( CollectionEventKind.REMOVE, removed, index );
			return removed;
		}
		
		/**
		 * Remove all items from the ArrayCollection.
		 */
		public function removeAll():void
		{
			if ( length > 0 )
			{
				clearSource();
				internalDispatchEvent( CollectionEventKind.RESET );
			}
		}
		
		/**
		 * Remove all items from the ArrayCollection without dispatching a RESET event.
		 */
		public function clearSource():void
		{
			_source.splice( 0, length );
		}
		
		/**
		 * Returns whether the ArrayCollection contains the specified item.
		 */
		public function contains( item:* ):Boolean
		{
			return getItemIndex( item ) != -1;
		}
		
		/**
		 * Notifies the view that an item has been updated.
		 */
		public function itemUpdated( item:* ):void
		{
			internalDispatchEvent( CollectionEventKind.UPDATE, item );
		}
		
		/**
		 * Return an Array that is populated in the same order as the ArrayCollection.
		 */
		public function toArray():Array
		{
			return _source.concat();
		}
		
		/**
		 * Pretty prints the contents of the ArrayCollection to a string and returns it.
		 */
		public function toString():String
		{
			if( _source )
			{
				return _source.toString();
			}
			else
			{
				return "";
			}
		}
		
		/**
		 * Dispatches a collection event with the specified information.
		 */
		protected function internalDispatchEvent( kind:String, item:* = null, location:int = -1 ):void
		{
			var event:CollectionEvent = new CollectionEvent( CollectionEvent.COLLECTION_CHANGE );
			event.kind = kind;
			event.items.push( item );
			event.location = location;
			dispatchEvent( event );
		}
		
		//--------------------------------------------------------------------------
		//
		// Proxy methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Attempts to call getItemAt(), converting the property name into an int.
		 */
		override flash_proxy function getProperty( name:* ):*
		{
			if( name is QName )
				name = name.localName;
			
			var index:int = -1;
			
			try
			{
				// If caller passed in a number such as 5.5, it will be floored.
				var n:Number = parseInt( String( name ) );
				
				if( !isNaN( n ) )
					index = int( n );
			}
			catch( error:Error ) // localName was not a number
			{
			}
			
			if( index == -1 )
			{
				var message:String = "Unknown Property: " + name + ".";
				throw new Error( message );
			}
			else
			{
				return getItemAt( index );
			}
		}
		
		/**
		 *  @private
		 *  Attempts to call setItemAt(), converting the property name into an int.
		 */
		override flash_proxy function setProperty( name:*, value:* ):void
		{
			if( name is QName )
				name = name.localName;
			
			var index:int = -1;
			
			try
			{
				// If caller passed in a number such as 5.5, it will be floored.
				var n:Number = parseInt( String( name ) );
				
				if( !isNaN( n ) )
					index = int( n );
			}
			catch( error:Error ) // localName was not a number
			{
			}
			
			if( index == -1 )
			{
				var message:String = "Unknown Property: " + name + ".";
				throw new Error( message );
			}
			else
			{
				setItemAt( value, index );
			}
		}
		
		/**
		 *  @private
		 *  This is an internal function.
		 *  The VM will call this method for code like <code>"foo" in bar</code>
		 *
		 *  @param name The property name that should be tested for existence.
		 */
		override flash_proxy function hasProperty( name:* ):Boolean
		{
			if( name is QName )
				name = name.localName;
			
			var index:int = -1;
			
			try
			{
				// If caller passed in a number such as 5.5, it will be floored.
				var n:Number = parseInt( String( name ) );
				
				if( !isNaN( n ) )
					index = int( n );
			}
			catch( error:Error ) // localName was not a number
			{
			}
			
			if( index == -1 )
				return false;
			
			return index >= 0 && index < length;
		}
		
		/**
		 *  @private
		 */
		override flash_proxy function nextNameIndex( index:int ):int
		{
			return index < length ? index + 1 : 0;
		}
		
		/**
		 *  @private
		 */
		override flash_proxy function nextName( index:int ):String
		{
			return( index - 1 ).toString();
		}
		
		/**
		 *  @private
		 */
		override flash_proxy function nextValue( index:int ):*
		{
			return getItemAt( index - 1 );
		}
		
		/**
		 *  @private
		 *  Any methods that can't be found on this class shouldn't be called,
		 *  so return null
		 */
		override flash_proxy function callProperty( name:*, ... rest ):*
		{
			return null;
		}
		
		//--------------------------------------------------------------------------
		//
		// EventDispatcher methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Registers an event listener object with an EventDispatcher object so that the listener receives notification of an event.
		 */
		public function addEventListener( type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false ):void
		{
			eventDispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}
		
		/**
		 * Removes a listener from the EventDispatcher object.
		 */
		public function removeEventListener( type:String, listener:Function, useCapture:Boolean=false ):void
		{
			eventDispatcher.removeEventListener( type, listener, useCapture );
		}
		
		/**
		 * Dispatches an event into the event flow.
		 */
		public function dispatchEvent( event:Event ):Boolean
		{
			return eventDispatcher.dispatchEvent( event );
		}
		
		/**
		 * Checks whether the EventDispatcher object has any listeners registered for a specific type of event.
		 */
		public function hasEventListener( type:String ):Boolean
		{
			return eventDispatcher.hasEventListener( type );
		}
		
		/**
		 * Checks whether an event listener is registered with this EventDispatcher object or any of its ancestors for the specified event type.
		 */
		public function willTrigger( type:String ):Boolean
		{
			return eventDispatcher.willTrigger( type );
		}
		
	}
}
