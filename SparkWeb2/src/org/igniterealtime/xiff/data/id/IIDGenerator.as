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
package org.igniterealtime.xiff.data.id
{	
	/**
	 * To use custom ID generators call the static function on the
	 * XMPPStanza class with an instance that implements IIDGenerator.
	 * 
	 * @example	<code>XMPPStanza.setIDGenerator( 
	 * 	new org.igniterealtime.xiff.data.id.SharedObjectGenerator() );</code>
	 */
	public interface IIDGenerator
	{
		/**
		 * Gets the generated ID.
		 *
		 * @param	prefix The prefix to use for the ID (for namespacing purposes)
		 * @return The generated ID
		 */
		function getID(prefix:String):String;
	}
}