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
	 * A helper class that abstracts the serialization of strokes and
	 * provides an interface to access the properties
	 *
	*/
	public class Stroke implements ISerializable
	{
		private var _color:uint;
		private var _width:Number;
		private var _opacity:Number;
	
		public function Stroke() 
		{ 
			
		}
	
		/**
		 * Serializes the Stroke into the parent node.  Because the stroke
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
				parent.attributes['stroke'] = "#" + _color.toString(16); 
			}
	        if (_width)
			{ 
				parent.attributes['stroke-width'] = _width.toString(); 
			}
	        if (_opacity) 
			{
				parent.attributes['stroke-opacity'] = _opacity.toString(); 
			}
	
	        return true;
	    }
	
		/**
		 * Extracts the known stroke attributes from the node
		 *
		 * @param	parent The parent node that this extension should be serialized into
		 * @return An indicator as to whether serialization was successful
		 */
		public function deserialize( node:XMLNode ):Boolean
		{
	        if (node.attributes['stroke'])
			{
	            _color = new Number('0x' + node.attributes['stroke'].slice(1));
	        }
	        if (node.attributes['stroke-width']) 
			{
	            _width = new Number(node.attributes['stroke-width']);
	        }
	        if (node.attributes['stroke-opacity'])
			{
	            _opacity = new Number(node.attributes['stroke-opacity']);
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
	     * The width of the stroke in pixels.  This is in a format used by
	     * MovieClip.lineStyle
	     *
	     */
	    public function get width():Number
		{ 
			return _width ? _width : 1; 
		}
	    public function set width(value:Number):void 
		{
			_width = value; 
		}
	
	    /**
	     * The opacity of the stroke, in percent. 100 is solid, 0 is transparent.
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