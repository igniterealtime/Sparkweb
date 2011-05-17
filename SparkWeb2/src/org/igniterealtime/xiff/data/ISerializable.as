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
package org.igniterealtime.xiff.data
{

	
	/**
	 * All XMPP stanzas that will interact with the library should implement this interface.
	 */
	import flash.xml.XMLNode;

	public interface ISerializable
	{
		/**
		 * Called when the library need to retrieve the state of the instance.  If the instance manages its own state, then the state should be copied into the XMLNode passed.  If the instance also implements INodeProxy, then the parent should be verified against the parent XMLNode passed to determine if the serialization is in the same namespace.
		 *
		 * @param	parentNode (XMLNode) The container of the XML.
		 * @return	On success, return true.
		 */
		function serialize( parentNode:XMLNode ):Boolean;
	
		/**
		 * Called when data is retrieved from the XMLSocket, use this method to extract any state into internal state.
		 * @param	node (XMLNode) The node that should be used as the data container.
		 * @return	On success, return true.
		 */
		function deserialize( node:XMLNode ):Boolean;
		
	}
}