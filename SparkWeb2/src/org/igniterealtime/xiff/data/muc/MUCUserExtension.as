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
package org.igniterealtime.xiff.data.muc
{

	
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.IExtension;
	
	/**
	 * Implements the base MUC user protocol schema from
	 * <a href="http://www.xmpp.org/extensions/xep-0045.html">XEP-0045<a> for multi-user chat.
	 * @see http://xmpp.org/extensions/xep-0045.html
	 */
	public class MUCUserExtension extends MUCBaseExtension implements IExtension
	{
		public static const NS:String = "http://jabber.org/protocol/muc#user";
		public static const ELEMENT_NAME:String = "x";
	
		public static const TYPE_DECLINE:String = "decline";
		public static const TYPE_DESTROY:String = "destroy";
		public static const TYPE_INVITE:String = "invite";
		public static const TYPE_OTHER:String = "other";
	
		private var _actionNode:XMLNode;
		private var _passwordNode:XMLNode;
		private var _statuses:Array = [];
	
		/**
		 *
		 * @param	parent (Optional) The containing XMLNode for this extension
		 */
		public function MUCUserExtension( parent:XMLNode = null )
		{
			super(parent);
		}
	
		public function getNS():String
		{
			return MUCUserExtension.NS;
		}
	
		public function getElementName():String
		{
			return MUCUserExtension.ELEMENT_NAME;
		}
	
		override public function deserialize( node:XMLNode ):Boolean
		{
			super.deserialize(node);
	
			for each( var child:XMLNode in node.childNodes )
			{
				switch( child.nodeName )
				{
					case TYPE_DECLINE:
						_actionNode = child;
						break;
						
					case TYPE_DESTROY:
						_actionNode = child;
						break;
						
					case TYPE_INVITE:
						_actionNode = child;
						break;
						
					case "status":
						_statuses.push(new MUCStatus(child, this));
						break;
						
					case "password":
						_passwordNode = child;
						break;
				}
			}
			return true;
		}
	
		/**
		 * Use this extension to invite another user
		 */
		public function invite(to:EscapedJID, from:EscapedJID, reason:String):void
		{
			updateActionNode(TYPE_INVITE, {to:to.toString(), from:from ? from.toString() : null}, reason);
		}
	
		/**
		 * Use this extension to destroy a room
		 */
		public function destroy(room:EscapedJID, reason:String):void
		{
			updateActionNode(TYPE_DESTROY, {jid: room.toString()}, reason);
		}
	
		/**
		 * Use this extension to decline an invitation
		 */
		public function decline(to:EscapedJID, from:EscapedJID, reason:String):void
		{
			updateActionNode(TYPE_DECLINE, {to:to.toString(), from:from ? from.toString() : null}, reason);
		}
		
		public function hasStatusCode(code:Number):Boolean
		{
			for each(var status:MUCStatus in statuses)
			{
				if(status.code == code)
					return true;
			}
			return false;
		}
			
		/**
		 * Internal method that manages the type of node that we will use for invite/destroy/decline messages
		 */
		private function updateActionNode(type:String, attrs:Object, reason:String) : void
		{
			if (_actionNode != null) _actionNode.removeNode();
	
			_actionNode = XMLFactory.createElement(type);
			for (var i:String in attrs) {
				if (exists(attrs[i])) {
					_actionNode.attributes[i] = attrs[i];
				}
			}
			getNode().appendChild(_actionNode);
	
			if (reason.length > 0) {
				replaceTextNode(_actionNode, undefined, "reason", reason);
			}
		}
	
		/**
		 * The type of user extension this is
		 */
		public function get type():String
		{
			if (_actionNode == null)
				return null;
			return _actionNode.nodeName == null ? TYPE_OTHER : _actionNode.nodeName;
		}
	
		/**
		 * The to property for invite and decline action types
		 */
		public function get to():EscapedJID
		{
			return new EscapedJID(_actionNode.attributes.to);
		}
	
		/**
		 * The from property for invite and decline action types
		 */
		public function get from():EscapedJID
		{
			return new EscapedJID(_actionNode.attributes.from);
		}
	
		/**
		 * The jid property for destroy the action type
		 */
		public function get jid():EscapedJID
		{
			return new EscapedJID(_actionNode.attributes.jid);
		}
	
	    /**
	     * The reason for the invite/decline/destroy
	     */
	    public function get reason():String
	    {
	    	if (_actionNode.firstChild != null)
			{
	    		if (_actionNode.firstChild.firstChild != null) {
	    			return _actionNode.firstChild.firstChild.nodeValue;
	    		}
	    	}
	        return null;
	    }
	
		/**
		 * Property to use if the concerned room is password protected
		 */
		public function get password():String
		{
			if (_passwordNode == null) return null;
			return _passwordNode.firstChild.nodeValue;
		}
	
		public function set password(value:String):void
		{
			_passwordNode = replaceTextNode(getNode(), _passwordNode, "password", value);
		}
	
		
		public function get statuses():Array
		{
			return _statuses;
		}
		public function set statuses(value:Array):void
		{
			_statuses = value;
		}
	}
}
