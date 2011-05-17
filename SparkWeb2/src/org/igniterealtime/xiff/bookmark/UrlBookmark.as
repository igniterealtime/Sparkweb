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

	import org.igniterealtime.xiff.data.ISerializable;

	public class UrlBookmark implements ISerializable
	{
		private var _node:XMLNode;

		/**
		 *
		 * @param	name
		 * @param	url
		 */
		public function UrlBookmark( name:String = null, url:String = null )
		{
			if ( !name && !url )
			{
				return;
			}
			else if ( !name || !url )
			{
				throw new Error( "Name and url cannot be null, they must either both be null or an Object" );
			}

			_node = new XMLNode( 1, "url" );
			_node.attributes.name = name;
			_node.attributes.url = url;
		}

		public function deserialize( node:XMLNode ):Boolean
		{
			_node = node.cloneNode( true );
			return true;
		}

		public function get name():String
		{
			return _node.attributes.name;
		}

		public function serialize( parentNode:XMLNode ):Boolean
		{
			parentNode.appendChild( _node.cloneNode( true ));
			return true;
		}

		public function get url():String
		{
			return _node.attributes.uri;
		}
	}
}
