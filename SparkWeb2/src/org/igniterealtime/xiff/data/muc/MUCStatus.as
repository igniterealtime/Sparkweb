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
package org.igniterealtime.xiff.data.muc
{
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.data.XMLStanza;
	
	public class MUCStatus
	{
		private var node:XMLNode;
		private var parent:XMLStanza
		public function MUCStatus(xmlNode:XMLNode, parentStanza:XMLStanza)
		{
			super();
			node = xmlNode ? xmlNode : new XMLNode(1, "status");
			parent = parentStanza;
		}

		/**
		 * Property used to add or retrieve a status code describing the condition that occurs.
		 */
		public function get code():Number
		{
			return node.attributes.code;
		}
		
		public function set code(value:Number):void
		{
			node.attributes.code = value.toString();
		}
		
		/**
		 * Property that contains some text with a description of a condition.
		 */
		public function get message():String
		{
			if(node.firstChild)
				return node.firstChild.nodeValue;
			
			return null;
		}
	
		public function set message(value:String):void
		{
			node = parent.replaceTextNode(parent.getNode(), node, "status", value);
		}
	}
}
