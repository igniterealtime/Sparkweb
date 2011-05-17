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

	
	import org.igniterealtime.xiff.data.IExtension;
	import flash.xml.XMLDocument;
	
	/**
	 * This is a static class that contains class constructors for all extensions that could come from the network.
	 */
	public class ExtensionClassRegistry
	{
		private static var _classes:Array = [];
		
		public static function register( extensionClass:Class ):Boolean
		{
			//trace ("ExtensionClassRegistry.register(" + extensionClass + ")");
			
			var extensionInstance:IExtension = new extensionClass();
			
			//if (extensionInstance instanceof IExtension) {
			if (extensionInstance is IExtension)
			{
				_classes[extensionInstance.getNS()] = extensionClass;
				return true;
			}
			return false;
		}
		
		public static function lookup( ns:String ):Class
		{
			return _classes[ ns ];
		}
	}
}
