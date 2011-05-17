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
package org.igniterealtime.xiff.events
{
	import flash.events.Event;

	import org.igniterealtime.xiff.bookmark.GroupChatBookmark;
	import org.igniterealtime.xiff.bookmark.UrlBookmark;

	/**
	 *
	 */
	public class BookmarkChangedEvent extends Event
	{
		/**
		 *
		 * @default
		 */
		public static const GROUPCHAT_BOOKMARK_ADDED:String = "groupchatBookmarkAdded";

		/**
		 *
		 * @default
		 */
		public static const GROUPCHAT_BOOKMARK_REMOVED:String = "groupchatBookmarkRemoved";
		
		/**
		 *
		 * @default
		 */
		public var groupchatBookmark:GroupChatBookmark = null;

		/**
		 *
		 * @default
		 */
		public var urlBookmark:UrlBookmark = null;

		/**
		 *
		 * @param type
		 * @param bookmark
		 */
		public function BookmarkChangedEvent( type:String, bookmark:* )
		{
			super( type );
			if ( bookmark is GroupChatBookmark )
			{
				groupchatBookmark = bookmark as GroupChatBookmark;
			}
			else
			{
				urlBookmark = bookmark as UrlBookmark;
			}
		}

		override public function clone():Event
		{
			var bookmark:* = urlBookmark;
			if ( groupchatBookmark != null )
			{
				bookmark = groupchatBookmark;
			}
			return new BookmarkChangedEvent( type, bookmark );
		}

		override public function toString():String
		{
			return '[BookmarkChangedEvent type="' + type + '" bubbles=' + bubbles +
				' cancelable=' + cancelable + ' eventPhase=' + eventPhase + ']';
		}
	}
}
