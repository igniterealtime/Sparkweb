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
package org.igniterealtime.xiff.data.sharedgroups
{
	import flash.xml.XMLNode;
	import org.igniterealtime.xiff.data.ISerializable;
	import org.igniterealtime.xiff.data.IExtension;

	/**
	 * Similar idea to XEP-0140 (http://xmpp.org/extensions/xep-0140.html) which was
	 * retracted in favor of XEP-0144 (http://xmpp.org/extensions/xep-0144.html).
	 */
	public class SharedGroupsExtension implements IExtension, ISerializable
	{
		public function getNS():String
		{
			return "http://www.jivesoftware.org/protocol/sharedgroup";
		}
		
		public function getElementName():String
		{
			return "sharedgroup";
		}

		public function serialize(parentNode:XMLNode):Boolean
		{
			var xmlNode:XMLNode = new XMLNode(1, getElementName() + " xmlns='" + getNS() + "'");
			parentNode.appendChild(xmlNode);
			return true;
		}
		
		public function deserialize(node:XMLNode):Boolean
		{
			return true;
		}
		
	}
}
