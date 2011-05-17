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
package org.igniterealtime.xiff.data.forms
{
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.data.Extension;
	import org.igniterealtime.xiff.data.ExtensionClassRegistry;
	import org.igniterealtime.xiff.data.IExtension;
	import org.igniterealtime.xiff.data.ISerializable;
	import org.igniterealtime.xiff.data.XMLStanza;
	
	/**
	 * Implements the base functionality shared by all MUC extensions
	 * @see http://xmpp.org/extensions/xep-0004.html
	 */
	public class FormExtension extends Extension implements IExtension, ISerializable
	{
	    public static const FIELD_TYPE_BOOLEAN:String = "boolean";
	    public static const FIELD_TYPE_FIXED:String = "fixed";
	    public static const FIELD_TYPE_HIDDEN:String = "hidden";
	    public static const FIELD_TYPE_JID_MULTI:String = "jid-multi";
	    public static const FIELD_TYPE_JID_SINGLE:String = "jid-single";
	    public static const FIELD_TYPE_LIST_MULTI:String = "list-multi";
	    public static const FIELD_TYPE_LIST_SINGLE:String = "list-single";
	    public static const FIELD_TYPE_TEXT_MULTI:String = "text-multi";
	    public static const FIELD_TYPE_TEXT_PRIVATE:String = "text-private";
	    public static const FIELD_TYPE_TEXT_SINGLE:String = "text-single";
	
	    public static const TYPE_REQUEST:String = "form";
	    public static const TYPE_RESULT:String = "result";
	    public static const TYPE_SUBMIT:String = "submit";
	    public static const TYPE_CANCEL:String = "cancel";
	
	    public static const NS:String = "jabber:x:data";
	    public static const ELEMENT_NAME:String = "x";
	
		//private static var isStaticConstructed:Boolean = enable();
		//private static var staticDependencies:Array = [ ExtensionClassRegistry ];
	
		private var _items:Array = [];
		private var _fields:Array = [];
	    private var myReportedFields:Array = [];
	
	    private var myInstructionsNode:XMLNode;
	    private var myTitleNode:XMLNode;
	
		/**
		 *
		 * @param	parent (Optional) The containing XMLNode for this extension
		 */
		public function FormExtension( parent:XMLNode = null )
		{
			super(parent);
		}
	
		public function getNS():String
		{
			return FormExtension.NS;
		}
	
		public function getElementName():String
		{
			return FormExtension.ELEMENT_NAME;
		}
		
		public static function enable():Boolean
	    {
	        ExtensionClassRegistry.register(FormExtension);
	        return true;
	    }
		
		/**
		 * Called when this extension is being put back on the network.
		 * Perform any further serialization for Extensions and items
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
			var node:XMLNode = getNode();
	
			for each (var field:FormField in _fields)
			{
				if (!field.serialize(node))
				{
					return false;
				}
			}
	
			if (parent != node.parentNode)
			{
				parent.appendChild(node.cloneNode(true));
			}
	
			return true;
		}
	
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode(node);
	
			removeAllItems();
			removeAllFields();
	
			for each( var c:XMLNode in node.childNodes )
			{
				var field:FormField;
				switch( c.nodeName )
				{
	                case "instructions": 
						myInstructionsNode = c; 
						break;
						
	                case "title":
						myTitleNode = c;
						break;
						
	                case "reported":
	                	for each(var reportedFieldXML:XMLNode in c.childNodes)
	                	{
	                		field = new FormField();
	                		field.deserialize(reportedFieldXML);
	                		myReportedFields.push(field);
	                	}
	                    break;
	
					case "item":
						var itemFields:Array = [];
	                    for each(var itemFieldXML:XMLNode in c.childNodes)
	                    {
	                        field = new FormField();
	                        field.deserialize(itemFieldXML);
	                        itemFields.push(field);
	                    }
	                    _items.push(itemFields);
						break;
	
	                case "field":
	                    field = new FormField();
	                    field.deserialize(c);
	                    _fields.push(field);
	                    break;
				}
			}
			return true;
		}
	
	    /**
	     * This is an accessor to the hidden field type <code>FORM_TYPE</code>
	     * easily check what kind of form this is.
	     *
		 * @return String the registered namespace of this form type
	     * @see	http://xmpp.org/extensions/xep-0068.html
	     */
	    public function getFormType():String
	    {
	        // Most likely at the start of the array
	        for each(var field:FormField in _fields)
			{
	        	if(field.name == "FORM_TYPE")
	        		return field.value;
	        }
	        return "";
	    }
	
		/**
		 * Item interface to array of fields if they are contained in an "item" element
		 *
		 * @return Array containing Arrays of FormFields objects
		 */
	    public function getAllItems():Array
	    {
	        return _items;
	    }
	
	    /**
		 *
	     * @param	value the name of the form field to retrieve
	     * @return	FormField the matching form field
	     */
	    public function getFormField(value:String):FormField
	    {
	    	 for each (var field:FormField in _fields)
	    	 {
			 	if (field.name == value)
				{
			 		return field;
				}
			 }
			 return null;
	    }
	
		/**
		 * Item interface to array of fields if they are contained in an "item" element
		 *
		 * @return Array of FormFields objects
		 */
	    public function getAllFields():Array
	    {
	        return _fields;
	    }
	
	    /**
	     * Sets the fields given a fieldmap object containing keys of field names
	     * and values of value arrays
	     *
	     * @param	fieldmap Object in format obj[key:String].value:Array
	     */
	    public function setFields(fieldmap:Object):void
	    {
	        removeAllFields();
	        for (var f:String in fieldmap)
			{
	            var field:FormField = new FormField();
	            field.name = f;
	            field.setAllValues(fieldmap[f]);
	            _fields.push(field);
	        }
	    }
	
		/**
		 * Use this method to remove all items.
		 *
		 */
		public function removeAllItems():void
		{
			for each(var item:FormField in _items)
			{
	            for each(var i:* in item)
				{
	                i.getNode().removeNode();
	                i.setNode(null);
	            }
			}
		 	_items = [];
		}
		/**
		 * Use this method to remove all fields.
		 *
		 */
		public function removeAllFields():void
		{
			for each(var item:FormField in _fields)
			{
	            for each(var i:* in item)
				{
	                i.getNode().removeNode();
	                i.setNode(null);
	            }
			}
		 	_fields = [];
		}
	
	    /**
	     * Instructions describing what to do with this form
	     *
	     */
	    public function get instructions():String
	    {
	    	if (myInstructionsNode && myInstructionsNode.firstChild)
			{
	    		return myInstructionsNode.firstChild.nodeValue;
			}
	
	    	return null;
	    }
	    public function set instructions(value:String) :void
	    {
	        myInstructionsNode = replaceTextNode(getNode(), myInstructionsNode, "instructions", value);
	    }
	
	    /**
	     * The title of this form
	     *
	     */
	    public function get title():String
	    {
	    	if (myTitleNode && myTitleNode.firstChild)
			{
	    		return myTitleNode.firstChild.nodeValue;
			}
	
	    	return null;
	    }
	    public function set title(value:String) :void
	    {
	        myTitleNode = replaceTextNode(getNode(), myTitleNode, "Title", value);
	    }
	
	    /**
	     * Array of fields found in individual items due to a search query result
	     *
	     * @return	Array of FormField objects containing information about the fields
	     * in the fields retrieved by getAllItems
	     */
	    public function getReportedFields():Array
	    {
	        return myReportedFields;
	    }
	
	    /**
	     * The type of form.  May be one of the following:
	     *
	     * <code>FormExtension.TYPE_REQUEST</code>
	     * <code>FormExtension.TYPE_RESULT</code>
	     * <code>FormExtension.TYPE_SUBMIT</code>
	     * <code>FormExtension.TYPE_CANCEL</code>
	     *
	     */
	
	    public function get type():String
		{
			return getNode().attributes.type;
		}
	    public function set type(value:String) :void
	    {
	        // TODO ensure it is in the enumeration of "cancel", "form", "result", "submit"
	        // TODO Change the behavior of the serialization depending on the type
	        getNode().attributes.type = value;
	    }
	}
}
