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

	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.ISerializable;
	import org.igniterealtime.xiff.privatedata.IPrivatePayload;

	public class BookmarkPrivatePayload implements IPrivatePayload
	{

		private var _groupChatBookmarks:Array = [];

		private var _others:Array = [];

		private var _urlBookmarks:Array = [];

		public function BookmarkPrivatePayload( groupChatBookmarks:Array = null,
												urlBookmarks:Array = null )
		{
			if ( groupChatBookmarks )
			{
				for each ( var bookmark:GroupChatBookmark in groupChatBookmarks )
				{
					if ( _groupChatBookmarks.every( function( testGroupChatBookmark:GroupChatBookmark,
															  index:int, array:Array ):Boolean
						{
							return testGroupChatBookmark.jid != bookmark.jid;
						}))
						_groupChatBookmarks.push( bookmark );
				}
			}
			if ( urlBookmarks )
			{
				for each ( var urlBookmark:UrlBookmark in urlBookmarks )
				{
					if ( _urlBookmarks.every( function( testURLBookmark:UrlBookmark,
														index:int, array:Array ):Boolean
						{
							return testURLBookmark.url != urlBookmark.url;
						}))
						_urlBookmarks.push( urlBookmark );
				}
			}
		}

		public function deserialize( bookmarks:XMLNode ):Boolean
		{
			for each ( var child:XMLNode in bookmarks.childNodes )
			{
				if ( child.nodeName == "conference" )
				{
					var groupChatBookmark:GroupChatBookmark = new GroupChatBookmark();
					groupChatBookmark.deserialize( child );
					//don't add it if it's a duplicate
					if ( _groupChatBookmarks.every( function( testGroupChatBookmark:GroupChatBookmark,
															  index:int, array:Array ):Boolean
						{
							return testGroupChatBookmark.jid != groupChatBookmark.jid;
						}))
						_groupChatBookmarks.push( groupChatBookmark );
				}
				else if ( child.nodeName == "url" )
				{
					var urlBookmark:UrlBookmark = new UrlBookmark();
					urlBookmark.deserialize( child );
					//don't add it if it's a duplicate
					if ( _urlBookmarks.every( function( testURLBookmark:UrlBookmark,
														index:int, array:Array ):Boolean
						{
							return testURLBookmark.url != urlBookmark.url;
						}))
						_urlBookmarks.push( urlBookmark );
				}
				else
				{
					_others.push( child );
				}
			}
			return true;
		}

		public function getElementName():String
		{
			return "storage";
		}

		public function getNS():String
		{
			return "storage:bookmarks";
		}

		public function get groupChatBookmarks():Array
		{
			return _groupChatBookmarks.slice();
		}

		//removes the bookmark from the list, and returns it
		public function removeGroupChatBookmark( jid:UnescapedJID ):GroupChatBookmark
		{
			var removedItem:GroupChatBookmark = null;
			var newBookmarks:Array = [];
			for each ( var bookmark:GroupChatBookmark in _groupChatBookmarks )
			{
				if ( !bookmark.jid.unescaped.equals( jid, false ))
					newBookmarks.push( bookmark );
				else
					removedItem = bookmark;
			}
			_groupChatBookmarks = newBookmarks;
			return removedItem;
		}

		public function serialize( parentNode:XMLNode ):Boolean
		{
			var node:XMLNode = new XMLNode( 1, getElementName());
			node.attributes.xmlns = getNS();
			var serializer:Function = function( element:ISerializable, index:int,
												arr:Array ):void
			{
				element.serialize( parentNode );
			};
			_groupChatBookmarks.forEach( serializer );
			_urlBookmarks.forEach( serializer );
			return true;
		}

		public function get urlBookmarks():Array
		{
			return _urlBookmarks.slice();
		}
	}
}
