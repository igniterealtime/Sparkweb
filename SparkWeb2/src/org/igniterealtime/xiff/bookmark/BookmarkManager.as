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
	import flash.events.EventDispatcher;

	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.ExtensionClassRegistry;
	import org.igniterealtime.xiff.data.ISerializable;
	import org.igniterealtime.xiff.data.XMPPStanza;
	import org.igniterealtime.xiff.data.privatedata.PrivateDataExtension;
	import org.igniterealtime.xiff.events.BookmarkChangedEvent;
	import org.igniterealtime.xiff.events.BookmarkRetrievedEvent;
	import org.igniterealtime.xiff.privatedata.PrivateDataManager;
	import org.igniterealtime.xiff.util.Callback;

	/**
	 * @eventType org.igniterealtime.xiff.events.BookmarkChangedEvent.GROUPCHAT_BOOKMARK_ADDED
	 */
	[Event(name="groupchatBookmarkAdded", type="org.igniterealtime.xiff.events.BookmarkChangedEvent")]

	/**
	 * @eventType org.igniterealtime.xiff.events.BookmarkChangedEvent.GROUPCHAT_BOOKMARK_REMOVED
	 */
	[Event(name="groupchatBookmarkRemoved", type="org.igniterealtime.xiff.events.BookmarkChangedEvent")]

	/**
	 * @eventType org.igniterealtime.xiff.events.BookmarkRetrievedEvent.BOOKMARK_RETRIEVED
	 */
	[Event(name="bookmarkRetrieved", type="org.igniterealtime.xiff.events.BookmarkRetrievedEvent")]

	/**
	 * 
	 */
	public class BookmarkManager extends EventDispatcher
	{
		private static var bookmarkManagerConstructed:Boolean = bookmarkManagerStaticConstructor();

		private var _bookmarks:BookmarkPrivatePayload;

		private var _privateDataManager:PrivateDataManager;

		/**
		 *
		 * @param	privateDataManager
		 */
		public function BookmarkManager( privateDataManager:PrivateDataManager )
		{
			_privateDataManager = privateDataManager;
		}

		private static function bookmarkManagerStaticConstructor():Boolean
		{
			ExtensionClassRegistry.register( BookmarkPrivatePayload );
			return true;
		}

		/**
		 * 
		 * @param	serverBookmark
		 */
		public function addGroupChatBookmark( serverBookmark:GroupChatBookmark ):void
		{
			if ( !_bookmarks )
			{
				_privateDataManager.getPrivateData( "storage", "storage:bookmarks",
													new Callback( this, this[ "_processBookmarksAdd" ],
																  serverBookmark ));
			}
			else
			{
				_addBookmark( serverBookmark );
			}
		}

		public function fetchBookmarks():void
		{
			if ( !_bookmarks )
			{
				_privateDataManager.getPrivateData( "storage", "storage:bookmarks",
													new Callback( this, this[ "_processBookmarks" ]));
			}
			else
			{
				dispatchEvent( new BookmarkRetrievedEvent());
			}
		}

		public function getGroupChatBookmark( jid:UnescapedJID ):GroupChatBookmark
		{
			for each ( var bookmark:GroupChatBookmark in _bookmarks.groupChatBookmarks )
			{
				if ( bookmark.jid.unescaped.equals( jid, false ))
				{
					return bookmark;
				}
			}
			return null;
		}

		public function isGroupChatBookmarked( jid:UnescapedJID ):Boolean
		{
			for each ( var bookmark:GroupChatBookmark in _bookmarks.groupChatBookmarks )
			{
				if ( bookmark.jid.unescaped.equals( jid, false ))
				{
					return true;
				}
			}
			return false;
		}

		public function removeGroupChatBookmark( jid:UnescapedJID ):void
		{
			if ( !_bookmarks )
			{
				_privateDataManager.getPrivateData( "storage", "storage:bookmarks",
													new Callback( this, this[ "_processBookmarksRemove" ],
																  jid ));
			}
			else
			{
				_removeBookmark( jid );
			}
		}

		public function setAutoJoin( jid:UnescapedJID, state:Boolean ):void
		{
			if ( !_bookmarks )
			{
				_privateDataManager.getPrivateData( "storage", "storage:bookmarks",
													new Callback( this, this[ "_processBookmarksSetAuto" ],
																  jid, state ));
			}
			else
			{
				_setAutoJoin( jid, state );
			}
		}

		private function _addBookmark( bookmark:ISerializable ):void
		{
			var groupChats:Array = _bookmarks.groupChatBookmarks;
			var urls:Array = _bookmarks.urlBookmarks;

			if ( bookmark is GroupChatBookmark )
			{
				groupChats.push( bookmark );
			}
			else if ( bookmark is UrlBookmark )
			{
				urls.push( bookmark );
			}

			var payload:BookmarkPrivatePayload = new BookmarkPrivatePayload( groupChats,
																			 urls );
			_privateDataManager.setPrivateData( "storage", "storage:bookmarks", payload );
			_bookmarks = payload;
			dispatchEvent( new BookmarkChangedEvent( BookmarkChangedEvent.GROUPCHAT_BOOKMARK_ADDED,
													 bookmark ));
		}

		private function _processBookmarks( bookmarksIq:XMPPStanza ):void
		{
			var privateData:PrivateDataExtension = bookmarksIq.getAllExtensionsByNS( "jabber:iq:private" )[ 0 ];
			_bookmarks = BookmarkPrivatePayload( privateData.payload );
			dispatchEvent( new BookmarkRetrievedEvent());
		}

		private function _processBookmarksAdd( bookmark:ISerializable, bookmarksIq:XMPPStanza ):void
		{
			_processBookmarks( bookmarksIq );
			_addBookmark( bookmark );
		}

		private function _processBookmarksRemove( jid:UnescapedJID, bookmarksIq:XMPPStanza ):void
		{
			_processBookmarks( bookmarksIq );
			_removeBookmark( jid );
		}

		private function _processBookmarksSetAuto( jid:UnescapedJID, state:Boolean,
												   bookmarksIq:XMPPStanza ):void
		{
			_processBookmarks( bookmarksIq );
			_setAutoJoin( jid, state );
		}

		private function _removeBookmark( jid:UnescapedJID ):void
		{
			var removedBookmark:GroupChatBookmark = _bookmarks.removeGroupChatBookmark( jid );
			_updateBookmarks();
			dispatchEvent( new BookmarkChangedEvent( BookmarkChangedEvent.GROUPCHAT_BOOKMARK_REMOVED,
													 removedBookmark ));
		}

		private function _setAutoJoin( jid:UnescapedJID, state:Boolean ):void
		{
			for each ( var bookmark:GroupChatBookmark in _bookmarks.groupChatBookmarks )
			{
				if ( bookmark.jid.unescaped.equals( jid, false ))
				{
					bookmark.autoJoin = state;
				}
			}
			_updateBookmarks();
		}

		private function _updateBookmarks():void
		{
			var groupChats:Array = _bookmarks.groupChatBookmarks;
			var urls:Array = _bookmarks.urlBookmarks;

			var payload:BookmarkPrivatePayload = new BookmarkPrivatePayload( groupChats,
																			 urls );
			_privateDataManager.setPrivateData( "storage", "storage:bookmarks", payload );
		}

		/**
		 * 
		 */
		public function get bookmarks():BookmarkPrivatePayload
		{
			return _bookmarks;
		}
	}
}
