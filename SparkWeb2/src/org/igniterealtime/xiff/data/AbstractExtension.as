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
	import flash.xml.XMLNode;

	public class AbstractExtension extends Extension implements ISerializable {
		public function AbstractExtension(parent:XMLNode = null) {
			super(parent);
		}
		
		public function serialize(parentNode:XMLNode):Boolean
		{
			var node:XMLNode = getNode().cloneNode(true);
			var extensions:Array = getAllExtensions();
			for (var i:int = 0; i < extensions.length; ++i) {
				if (extensions[i] is ISerializable) {
					ISerializable(extensions[i]).serialize(node);
				}
			}
			parentNode.appendChild(node);
			return true;
		}
		
		public function deserialize(node:XMLNode):Boolean
		{
			setNode(node);
			for each(var extNode:XMLNode in node.childNodes) 
			{
				var extClass:Class = ExtensionClassRegistry.lookup(extNode.attributes.xmlns);
				if (extClass == null) {
					continue;
				}
				var ext:IExtension = new extClass();
				if (ext == null) {
					continue;
				}
				if (ext is ISerializable) {
					ISerializable(ext).deserialize(extNode);
				}
				addExtension(ext);
			}
			return true;
		}
		
	}
}