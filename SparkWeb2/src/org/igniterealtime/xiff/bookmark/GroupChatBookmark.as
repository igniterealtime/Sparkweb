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
package org.igniterealtime.xiff.bookmark
{
	import flash.xml.XMLNode;

	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.ISerializable;

	public class GroupChatBookmark implements ISerializable
	{
		private var _groupChatNode:XMLNode;

		private var _nickNode:XMLNode;

		private var _passwordNode:XMLNode;

		/**
		 *
		 * @param	name
		 * @param	jid
		 * @param	autoJoin
		 * @param	nickname
		 * @param	password
		 */
		public function GroupChatBookmark( name:String = null, jid:EscapedJID = null,
										   autoJoin:Boolean = false, nickname:String = null,
										   password:String = null )
		{
			if ( !name && !jid )
			{
				return;
			}
			else if ( !name || !jid )
			{
				throw new Error( "Name and jid cannot be null, they must either both be null or an Object" );
			}
			var groupChatNode:XMLNode = new XMLNode( 1, "conference" );
			groupChatNode.attributes.name = name;
			groupChatNode.attributes.jid = jid.toString();
			if ( autoJoin )
			{
				groupChatNode.attributes.autojoin = "true";
			}
			if ( nickname )
			{
				var nicknameNode:XMLNode = new XMLNode( 1, "nick" );
				nicknameNode.appendChild( new XMLNode( 3, nickname ));
				groupChatNode.appendChild( nicknameNode );
			}
			if ( password )
			{
				var passwordNode:XMLNode = new XMLNode( 1, "password" );
				passwordNode.appendChild( new XMLNode( 3, password ));
				groupChatNode.appendChild( passwordNode );
			}
			_groupChatNode = groupChatNode;
		}

		public function get autoJoin():Boolean
		{
			return _groupChatNode.attributes.autojoin == "true";
		}

		public function set autoJoin( value:Boolean ):void
		{
			_groupChatNode.attributes.autojoin = value.toString();
		}

		public function deserialize( node:XMLNode ):Boolean
		{
			_groupChatNode = node.cloneNode( false );

			var children:Array = node.childNodes;
			for each ( var child:XMLNode in children )
			{
				if ( child.nodeName == "nick" )
				{
					_nickNode = child.cloneNode( true );
				}
				else if ( child.nodeName == "password" )
				{
					_passwordNode = child.cloneNode( true );
				}
			}

			return true;
		}

		public function get jid():EscapedJID
		{
			return new EscapedJID( _groupChatNode.attributes.jid );
		}

		public function get name():String
		{
			return _groupChatNode.attributes.name;
		}

		public function get nickname():String
		{
			return _nickNode.firstChild.nodeValue;
		}

		public function get password():String
		{
			return _passwordNode.firstChild.nodeValue;
		}

		public function serialize( parentNode:XMLNode ):Boolean
		{
			var groupChatNode:XMLNode = _groupChatNode.cloneNode( true );
			var nickNode:XMLNode = ( _nickNode != null ? _nickNode.cloneNode( true ) :
				null );
			var passwordNode:XMLNode = ( _passwordNode != null ? _passwordNode.cloneNode( true ) :
				null );

			if ( nickNode != null )
			{
				groupChatNode.appendChild( nickNode );
			}
			if ( passwordNode != null )
			{
				groupChatNode.appendChild( passwordNode );
			}

			parentNode.appendChild( groupChatNode );

			return true;
		}
	}
}
