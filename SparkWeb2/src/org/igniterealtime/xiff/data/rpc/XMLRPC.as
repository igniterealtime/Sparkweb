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
package org.igniterealtime.xiff.data.rpc
{
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	/**
	 * Implements client side XML marshalling of methods and parameters into XMLRPC.
	 * For more information on RPC over XMPP, see <a href="http://xmpp.org/extensions/xep-0009.html">
	 * http://xmpp.org/extensions/xep-0009.html</a>.
	 */
	public class XMLRPC
	{
		private static var XMLFactory:XMLDocument = new XMLDocument();
	
		/**
		 * Extract and marshall the XML-RPC response to Flash types.
		 *
		 * @param	xml The XML containing the message response
		 * @return Mixed object of either an array of results from the method call or a fault.
		 * If the result is a fault, "result.isFault" will evaulate as true.
		 */
		public static function fromXML(xml:XMLNode):Array
		{
			var result:Array;
			var response:XMLNode = findNode("methodResponse", xml);
	
			if (response.firstChild.nodeName == "fault")
			{
				// methodResponse/fault/value/struct
				result = extractValue(response.firstChild.firstChild.firstChild);
				result.isFault = true;
			} 
			else 
			{
				result = [];
				var params:XMLNode = findNode("params", response);
				if (params != null) {
					for (var param_idx:int = 0; param_idx < params.childNodes.length; param_idx++)
					{
						var param:Array = params.childNodes[param_idx].firstChild;
	
						for (var type_idx:int = 0; type_idx < param.childNodes.length; type_idx++)
						{
							result.push(extractValue(param.childNodes[type_idx]));
						}
					}
				}
			}
			return result;
		}
	
		/**
		 * The marshalling process, accepting a block of XML, a string description of the remote method,
		 * and an array of flash type parameters.
		 *
		 * @return XMLNode containing the XML marshalled result
		 */
		public static function toXML(parent:XMLNode, method:String, params:Array):XMLNode
		{
			var mc:XMLNode = addNode(parent, "methodCall");
			addText(addNode(mc, "methodName"), method);
	
			var p:XMLNode = addNode(mc, "params");
			for (var i:int = 0; i < params.length; ++i)
			{
				addParameter(p, params[i]);
			}
	
			return mc;
		}
	
		private static function extractValue(value:XMLNode):*
		{
			var result:* = null;
	
			switch (value.nodeName)
			{ 
				case "int":
				case "i4":
				case "double":
					result = Number(value.firstChild.nodeValue);
					break;
	
				case "boolean":
					result = Number(value.firstChild.nodeValue) ? true : false;
					break;
	
				case "array":
					var value_array:Array = [];
					var next_value:*;
					for (var data_idx:int = 0; data_idx < value.firstChild.childNodes.length; data_idx++)
					{
						next_value = value.firstChild.childNodes[data_idx];
						value_array.push(extractValue(next_value.firstChild));
					}
					result = value_array;
					break;
	
				case "struct":
					var value_object:Object = {};
					for (var member_idx:int = 0; member_idx < value.childNodes.length; member_idx++)
					{
						var member:Array = value.childNodes[member_idx];
						var m_name:String = member.childNodes[0].firstChild.nodeValue;
						var m_value:* = extractValue(member.childNodes[1].firstChild);
						value_object[m_name] = m_value;
					}
					result = value_object;
					break;
	
				case "dateTime.iso8601":
				case "Base64":
				case "string":
				default:
					result = value.firstChild.nodeValue.toString();
					break;
	
			}
	
			return result;
		}
	
		private static function addParameter(node:XMLNode, param:*):XMLNode
		{
			return addValue(addNode(node, "param"), param);
		}
	
		private static function addValue(node:XMLNode, value:*):XMLNode
		{
			var value_node:XMLNode = addNode(node, "value");
	
			if (typeof(value) == "string") {
				addText(addNode(value_node, "string"), value);
	
			} else if (typeof(value) == "number") {
				if (Math.floor(value) != value) {
					addText(addNode(value_node, "double"), value);
				} else {
					addText(addNode(value_node, "int"), value.toString());
				}
	
			} else if (typeof(value) == "boolean") {
				addText(addNode(value_node, "boolean"), value == false ? "0" : "1");
	
			} else if (value is Array) {
				var data:XMLNode = addNode(addNode(value_node, "array"), "data");
				for (var i:int=0; i < value.length; ++i) {
					addValue(data, value[i]);
				}
			} else if (typeof(value) == "object") {
				// Special case where type is simple custom type is defined
				if (value.type != undefined && value.value != undefined) {
					addText(addNode(value_node, value.type), value.value);
				} else {
					var struct:XMLNode = addNode(value_node, "struct");
					for (var attr:String in value) {
						var member:XMLNode = addNode(struct, "member");
						addText(addNode(member, "name"), attr);
						addValue(member, value[attr]);
					}
				}
			}
	
			return node;
		}
	
		private static function addNode(parent:XMLNode, name:String):XMLNode
		{
			var child:XMLNode = XMLRPC.XMLFactory.createElement(name);
			parent.appendChild(child);
			return parent.lastChild;
		}
	
		private static function addText(parent:XMLNode, value:String):XMLNode
		{
			var child:XMLNode = XMLRPC.XMLFactory.createTextNode(value);
			parent.appendChild(child);
			return parent.lastChild;
		}
	
		private static function findNode(name:String, xml:XMLNode):XMLNode
		{
			if (xml.nodeName == name) {
				return xml;
			} else {
				var child:XMLNode = null;
				for (var i:String in xml.childNodes) {
					child = findNode(name, xml.childNodes[i]);
					if (child != null) {
						return child;
					}
				}
			}
			return null;
		}
	
	}
}