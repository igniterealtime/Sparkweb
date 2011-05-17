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
package org.igniterealtime.xiff.collections.events
{
	/**
	 *  The CollectionEventKind class contains constants for the valid values
	 *  of the CollectionEvent class kind property.
	 */
	public final class CollectionEventKind
	{
		/**
		 *  Indicates that the collection added an item or items.
		 */
		public static const ADD:String = "add";

		/**
		 *  Indicates that the collection removed an item or items.
		 */
		public static const REMOVE:String = "remove";

		/**
		 *  Indicates that the item at the position identified by the
		 *  CollectionEvent location property has been replaced.
		 */
		public static const REPLACE:String = "replace";

		/**
		 *  Indicates that the collection has changed so drastically that
		 *  a reset is required.
		 */
		public static const RESET:String = "reset";

		/**
		 *  Indicates that one or more items were updated within the collection.
		 *  The affected item(s)
		 *  are stored in the items property.
		 */
		public static const UPDATE:String = "update";

	}
}
