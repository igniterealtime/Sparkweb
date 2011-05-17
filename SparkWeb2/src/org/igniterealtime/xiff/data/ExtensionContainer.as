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
	import org.igniterealtime.xiff.data.IExtendable;
	
	/**
	 * Contains the implementation for a generic extension container.
	 * Use the static method "decorate" to implement the IExtendable interface on a class.
	 */
	public class ExtensionContainer implements IExtendable
	{
		public var _exts:Object = {};
		
		public function ExtensionContainer()
		{
			
		}
	
		public function addExtension( ext:IExtension ):IExtension
		{
			if (_exts[ext.getNS()] == null)
			{
				_exts[ext.getNS()] = [];
			}
			_exts[ext.getNS()].push(ext);
			return ext;
		}
	
		public function removeExtension( ext:IExtension ):Boolean
		{
			var extensions:Object = _exts[ext.getNS()];
			for (var i:String in extensions)
			{
				if (extensions[i] === ext)
				{
					extensions[i].remove();
					extensions.splice(parseInt(i), 1);
					return true;
				}
			}
			return false;
		}
		
		public function removeAllExtensions( ns:String ):void
		{
			for (var i:String in _exts[ns])
			{
				removeExtension( _exts[ns][i] );
			}
			_exts[ns] = [];
		}
	
		public function getAllExtensionsByNS( ns:String ):Array
		{
			return _exts[ns];
		}
		
		public function getExtension( name:String ):Extension
		{
			return getAllExtensions().filter( function(obj:IExtension, idx:int, arr:Array):Boolean
			{
				return obj.getElementName() == name;
			})[0];
		}
	
		public function getAllExtensions():Array
		{
			var exts:Array = [];
			for (var ns:String in _exts)
			{
				exts = exts.concat(_exts[ns]);
			}
			return exts;
		}
	}
}
