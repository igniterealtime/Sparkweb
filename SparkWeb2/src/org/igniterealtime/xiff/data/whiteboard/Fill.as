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
	import org.igniterealtime.xiff.data.ISerializable;
	import flash.xml.XMLNode;
	
	/**
	 * A helper class that abstracts the serialization of fills and
	 * provides an interface to access the properties providing defaults
	 * if no properties were defined in the XML.
	 *
	*/
	public class Fill implements ISerializable
	{
	    private var _color:uint;
	    private var _opacity:Number;
	
	    public function Fill() 
		{ 
		
		}
	
		/**
		 * Serializes the Fill into the parent node.  Because the fill
	     * serializes into the attributes of the XML node, it will directly modify
	     * the parent node passed.
		 *
		 * @param	parent The parent node that this extension should be serialized into
		 * @return An indicator as to whether serialization was successful
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
	        if (_color) 
			{ 
				parent.attributes['fill'] = "#" + _color.toString(16);
			}
	        if (_opacity)
			{
				parent.attributes['fill-opacity'] = _opacity.toString(); 
			}
	
	        return true;
	    }
	
		/**
		 * Extracts the known fill attributes from the node
		 *
		 * @param	parent The parent node that this extension should be serialized into
		 * @return An indicator as to whether serialization was successful
		 */
		public function deserialize( node:XMLNode ):Boolean
		{
	        if (node.attributes['fill'])
			{
	            _color = new Number('0x' + node.attributes['fill'].slice(1));
	        }
	        if (node.attributes['fill-opacity']) 
			{
	            _opacity = new Number(node.attributes['fill-opacity']);
	        }
	
	        return true;
	    }
	
	    /**
	     * The value of the RGB color.  This is the same color format used by
	     * MovieClip.lineStyle
	     *
	     */
		public function get color():uint 
		{
			return _color ? _color : 0; 
		}
		public function set color(value:uint):void
		{
			_color = value;
		}
	
	    /**
	     * The opacity of the fill, in percent. 100 is solid, 0 is transparent.
	     * This property can be used as the alpha parameter of MovieClip.lineStyle
	     *
	     */
	    public function get opacity():Number 
		{ 
			return _opacity ? _opacity : 100; 
		}
	    public function set opacity(value:Number):void 
		{
			_opacity = value;
		}
	}
}