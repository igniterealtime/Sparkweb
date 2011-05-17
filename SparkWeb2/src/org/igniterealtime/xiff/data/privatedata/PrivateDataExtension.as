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
package org.igniterealtime.xiff.data.privatedata
{
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.data.ExtensionClassRegistry;
	import org.igniterealtime.xiff.data.IExtension;
	import org.igniterealtime.xiff.data.ISerializable;
	import org.igniterealtime.xiff.privatedata.IPrivatePayload;
	
	public class PrivateDataExtension implements IExtension, ISerializable
	{
		private var _extension:XMLNode;
		
		private var _payload:IPrivatePayload;
		
		/**
		 *
		 * @param	privateName
		 * @param	privateNamespace
		 * @param	payload
		 */
		public function PrivateDataExtension(privateName:String = null, privateNamespace:String = null,
											 payload:IPrivatePayload = null)
		{
			_extension = new XMLNode(1, privateName);
			_extension.attributes["xmlns"] = privateNamespace;
			_payload = payload;
		}
		
		public function getNS():String
		{
			return "jabber:iq:private";
		}
		
		public function getElementName():String
		{
			return "query";
		}
		
		public function get privateName():String
		{
			return _extension.nodeName;
		}
		
		public function get privateNamespace():String
		{
			return _extension.attributes["xmlns"];
		}
		
		public function get payload():IPrivatePayload
		{
			return _payload;
		}
		
		public function serialize(parentNode:XMLNode):Boolean
		{
			var extension:XMLNode = _extension.cloneNode(true);
			var query:XMLNode = new XMLNode(1, "query");
			query.attributes.xmlns = "jabber:iq:private";
			query.appendChild(extension);
			parentNode.appendChild(query);
			
			return _serializePayload(extension);
		}
		
		private function _serializePayload(parentNode:XMLNode):Boolean
		{
			if (_payload == null)
			{
				return true;
			}
			else
			{
				return _payload.serialize(parentNode);
			}
		}
		
		public function deserialize(node:XMLNode):Boolean
		{
			var payloadNode:XMLNode = node.firstChild;
			var ns:String = payloadNode.attributes["xmlns"];
			if (ns == null)
			{
				return false;
			}
			
			_extension = new XMLNode(1, payloadNode.nodeName);
			_extension.attributes["xmlns"] = ns;
			
			var extClass:Class = ExtensionClassRegistry.lookup(ns);
			if (extClass == null)
			{
				return false;
			}
			var ext:IPrivatePayload = new extClass();
			if (ext != null && ext is IPrivatePayload)
			{
				ext.deserialize(payloadNode);
				_payload = ext;
				return true;
			}
			else
			{
				return false;
			}
		}
	
	}
}
