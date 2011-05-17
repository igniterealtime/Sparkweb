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
package org.igniterealtime.xiff.data.whiteboard
{
	import org.igniterealtime.xiff.data.*;	
	import org.igniterealtime.xiff.data.whiteboard.Path;
	import flash.xml.XMLNode;
	 
	/**
	 * A message extension for whitboard exchange. This class is the base class
	 * for other extension classes such as Path
	 *
	 * All child whiteboard objects are contained and serialized by this class
	 */
	public class WhiteboardExtension extends Extension implements IExtension, ISerializable
	{
		public static const ELEMENT_NAME:String = "x";
		public static const NS:String = "xiff:wb";
	
	    private static var staticDepends:Class = ExtensionClassRegistry;
	
	    private var _paths:Array;
		
		public function WhiteboardExtension( parent:XMLNode = null )
		{
			super( parent );
	        _paths = [];
		}
	
		/**
		 * Gets the namespace associated with this extension.
		 * The namespace for the WhiteboardExtension is "xiff:wb".
		 *
		 * @return The namespace
		 */
		public function getNS():String
		{
			return WhiteboardExtension.NS;
		}
	
		/**
		 * Gets the element name associated with this extension.
		 * The element for this extension is "x".
		 *
		 * @return The element name
		 */
		public function getElementName():String
		{
			return WhiteboardExtension.ELEMENT_NAME;
		}
		
		/**
		 * Serializes the WhiteboardExtension data to XML for sending.
		 *
		 * @param	parent The parent node that this extension should be serialized into
		 * @return An indicator as to whether serialization was successful
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
	        getNode().removeNode();
	        var ext_node:XMLNode = XMLFactory.createElement(getElementName());
	        ext_node.attributes.xmlns = getNS();
	
	        for (var i:int = 0; i < _paths.length; ++i)
			{
	            _paths[i].serialize(ext_node);
	        }
	
	        parent.appendChild(ext_node);
	
			return true;
		}
	
	    /**
	     * Performs the registration of this extension into the extension registry.  
	     * 
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(WhiteboardExtension);
	    }
		
		/**
		 * Deserializes the WhiteboardExtension data.
		 *
		 * @param	node The XML node associated this data
		 * @return An indicator as to whether deserialization was successful
		 */
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode( node );
	        _paths = [];
			var len:uint = node.childNodes.length;
	        for (var i:int = 0; i < len; ++i)
			{
	            var child:XMLNode = node.childNodes[i];
	            switch (child.nodeName) 
				{
	                case "path":
	                    var path:Path = new Path();
	                    path.deserialize(child);
	                    _paths.push(path);
	                    break;
	            }
	        }
			return true;
		}
	
	    /**
	     * The paths available in this whiteboard message
	     *
	     */
	    public function get paths():Array 
		{ 
			return _paths; 
		}
	
	}
}