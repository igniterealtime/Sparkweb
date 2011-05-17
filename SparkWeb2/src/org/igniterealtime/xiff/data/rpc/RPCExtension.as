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
	import org.igniterealtime.xiff.data.*;
	import org.igniterealtime.xiff.data.rpc.XMLRPC;
	import flash.xml.XMLNode;
	
	/**
	 * Implements <a href="http://xmpp.org/extensions/xep-0009.html">XEP-0009<a> for XML-RPC over XMPP.
	 * @see http://xmpp.org/extensions/xep-0009.html
	 */
	public class RPCExtension extends Extension implements IExtension, ISerializable
	{
		public static const NS:String = "jabber:iq:rpc";
		public static const ELEMENT_NAME:String = "query";
	
	    private static var staticDepends:Class = ExtensionClassRegistry;
	
		private var _result:Array;
		private var _fault:Object;
	
		/**
		 *
		 */
		public function RPCExtension()
		{
			
		}
		
		/**
		 * Place the remote call.  This method serializes the remote procedure call to XML.
		 * The call will be made on the remote machine when the stanza containing this extension is sent to the server.
		 *
		 * If this extension is being returned, then check the result property instead.
		 *
		 * @param	methodName The name of the remote procedure to call
		 * @param	params	A collection of parameters of any type
		 * @see	#result
		 */
		public function call(methodName:String, params:Array):void
		{
			XMLRPC.toXML(getNode(), methodName, params);
		}
	
		/**
		 * Interface method, returning the namespace for this extension
		 *
		 * @see	org.igniterealtime.xiff.data.IExtension
		 */
		public function getNS():String
		{
			return RPCExtension.NS;
		}
	
		/**
		 * Interface method, returning the namespace for this extension
		 *
		 * @see	org.igniterealtime.xiff.data.IExtension
		 */
		public function getElementName():String
		{
			return RPCExtension.ELEMENT_NAME;
		}
	
	    /**
	     * Performs the registration of this extension into the extension registry.
	     *
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register(RPCExtension);
	    }
	
		/**
		 * Interface method, returning the namespace for this extension
		 *
		 * @see	org.igniterealtime.xiff.data.ISerializable
		 */
		public function serialize( parent:XMLNode ):Boolean
		{
			if (!exists(getNode().parentNode))
			{
				parent.appendChild(getNode().cloneNode(true));
			}
			return true;
		}
	
		/**
		 * Interface method, returning the namespace for this extension
		 *
		 * @see	org.igniterealtime.xiff.data.ISerializable
		 */
		public function deserialize( node:XMLNode ):Boolean
		{
			setNode(node);
	
			var res:Array = XMLRPC.fromXML(node);
			if (res.isFault)
			{
				_fault = res;
			}
			else
			{
				_result = res[0];
			}
	
			return true;
		}
	
		/**
		 * The result of this remote procedure call.  It can contain elements of any type.
		 *
		 * @return Array of demarshalled results from the remote procedure
		 */
		public function get result():Array
		{
			return _result;
		}
	
		/**
		 * Check this if property if you wish to determine the remote procedure call produced an error.
		 * If the XMPP stanza never made it to the RPC service, then the error would be on the
		 * stanza object instead of this extension.
		 *
		 * @return True if the remote procedure call produced an error
		 */
		public function get isFault():Boolean
		{
			return _fault.isFault;
		}
	
		/**
		 * The object containing the fault of the remote procedure call.
		 * This object could have any properties, as fault results are only structurally defined.
		 *
		 */
		public function get fault():Object
		{
			return _fault;
		}
	
		/**
		 * A common result from most RPC servers to describe a fault
		 *
		 */
		public function get faultCode():Number
		{
			return _fault.faultCode;
		}
	
		/**
		 * A common result from most RPC servers to describe a fault
		 *
		 */
		public function get faultString():String
		{
			return _fault.faultString;
		}
	}
}
