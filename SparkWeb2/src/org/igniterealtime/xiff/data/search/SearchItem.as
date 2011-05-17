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
package org.igniterealtime.xiff.data.search{
	
	import org.igniterealtime.xiff.data.XMLStanza;
	import org.igniterealtime.xiff.data.ISerializable;
	import flash.xml.XMLNode;
	
	/**
	 * This class is used by the SearchExtension for internal representation of
	 * information pertaining to items matching the search query.
	 *
	 */
	public class SearchItem extends XMLStanza implements ISerializable
	{
		public static const ELEMENT_NAME:String = "item";
	
		private var _fields:Object = {};
	
		public function SearchItem(parent:XMLNode = null)
		{
			super();
			
			getNode().nodeName = ELEMENT_NAME;
	
			if (exists(parent))
			{
				parent.appendChild(getNode());
			}
		}
	
		public function serialize(parent:XMLNode):Boolean
		{
			if (parent != getNode().parentNode)
			{
				parent.appendChild(getNode().cloneNode(true));
			}
	
			return true;
		}
	
		public function deserialize(node:XMLNode):Boolean
		{
			setNode(node);
	
			var children:Array = node.childNodes;
			for ( var i:String in children )
			{
				_fields[children[i].nodeName.toLowerCase()] = children[i];
			}
			return true;
		}

		public function getField(name:String):String
		{
			if (_fields[name] != null && _fields[name].firstChild != null)
			{
				return _fields[name].firstChild.nodeValue;
			}
			return null;
		}
	
		public function setField(name:String, value:String):void
		{
			_fields[name] = replaceTextNode(getNode(), _fields[name], name, value);
		}
	
		/**
		 * JID
		 */
		public function get jid():String
		{
			return getNode().attributes.jid;
		}
	
		public function set jid(value:String):void
		{
			getNode().attributes.jid = value;
		}
		
		/**
		 * Username
		 */
		public function get username():String 
		{ 
			return getField("jid"); 
		}
		public function set username(value:String):void 
		{ 
			setField("jid", value);
		}
	
		/**
		 * Nick
		 */
		public function get nick():String 
		{ 
			return getField("nick"); 
		}
		public function set nick(value:String):void 
		{ 
			setField("nick", value);
		}
	
		/**
		 * First
		 */
		public function get first():String 
		{ 
			return getField("first"); 
		}
		public function set first(value:String):void 
		{ 
			setField("first", value);
		}
	
		/**
		 * Last
		 */
		public function get last():String 
		{ 
			return getField("last"); 
		}
		public function set last(value:String):void 
		{ 
			setField("last", value); 
		}
	
		/**
		 * E-mail
		 */
		public function get email():String 
		{ 
			return getField("email"); 
		}
		public function set email(value:String):void 
		{ 
			setField("email", value); 
		}
		
		/**
		 * Name
		 */
		public function get name():String 
		{
			return getField("name"); 
		}
		public function set name(value:String):void 
		{
			setField("name", value); 
		}
	}
}