/*
 *This file is part of SparkWeb.
 *
 *SparkWeb is free software: you can redistribute it and/or modify
 *it under the terms of the GNU Lesser General Public License as published by
 *the Free Software Foundation, either version 3 of the License, or
 *(at your option) any later version.
 *
 *SparkWeb is distributed in the hope that it will be useful,
 *but WITHOUT ANY WARRANTY; without even the implied warranty of
 *MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *GNU Lesser General Public License for more details.
 *
 *You should have received a copy of the GNU Lesser General Public License
 *along with SparkWeb.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.jivesoftware.spark.managers 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.core.Application;
	
	import org.jivesoftware.xiff.core.JID;
	import org.jivesoftware.xiff.core.XMPPBOSHConnection;
	import org.jivesoftware.xiff.core.XMPPConnection;
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.IQ;
	import org.jivesoftware.xiff.data.Message;
	import org.jivesoftware.xiff.data.Presence;
	import org.jivesoftware.xiff.data.events.MessageEventExtension;
	import org.jivesoftware.xiff.data.im.RosterItemVO;
	import org.jivesoftware.xiff.events.IncomingDataEvent;
	import org.jivesoftware.xiff.events.LoginEvent;
	import org.jivesoftware.xiff.events.OutgoingDataEvent;
	
	
	/**
	 * Responsible for the delegation of messages and presences.
	 */
	public class ConnectionManager extends EventDispatcher 
	{
		private var con:XMPPConnection;
		private var _lastSent:int = 0;
		//todo: use bind() equiv instead
		private var eIQID:String;
		
		/**
		 * Creates a new instance of the ConnectionManager.
		 */
		public function ConnectionManager():void 
		{
			var type:String = SparkManager.getConfigValueForKey("connectionType");
			switch(type)
			{
				case "http":
					con = new XMPPBOSHConnection();
					(con as XMPPBOSHConnection).secure = false;
					break;
				case "https":
					con = new XMPPBOSHConnection();
					(con as XMPPBOSHConnection).secure = true;
					break;
				case "socket":
				default:
					con = new XMPPConnection();	
			}
			if(con is XMPPBOSHConnection)
				con.port = Number(SparkManager.getConfigValueForKey("port"));
		}
		
		/**
		 * Log into server.
		 * @param username the username of the account.
		 * @param password the user password.
		 * @param server the server domain.
		 */
		public function login(username:String, password:String, server:String, resource:String="sparkweb"):void 
		{
			con.username = username;
			con.password = password;
			con.server = server;
			con.resource = resource;
			con.addEventListener("outgoingData", packetSent);
			con.connect( "terminatedFlash");
				
			con.addEventListener(LoginEvent.LOGIN, function(evt:LoginEvent):void {
				SparkManager.me = RosterItemVO.get(con.jid, true);
			});
			
			var timer:Timer = new Timer(15000, 15000);
			timer.addEventListener(TimerEvent.TIMER, checkKeepAlive);
			timer.start();
		}
		
		/**
		 * Do a simple keep alive.
		 */
		public function checkKeepAlive(event:TimerEvent):void 
		{
			if(new Date().getTime() - _lastSent > 15000)
				con.sendKeepAlive();
		}
		
		public function packetSent(event:Event):void {
			_lastSent = new Date().getTime();
		}
		
		
		/**
		 * Returns the XMPPConnection used for this session.
		 * @return the XMPPConnection.
		 */	
		public function get connection():XMPPConnection {
			return con;
		}
		
		/**
		 * Sends a single message to a user.
		 * @param jid the jid to send the message to.
		 * @param body the body of the message to send.
		 */
		public function sendMessage(jid:JID, body:String):void 
		{
			var message:Message = new Message();
			message.addExtension(new MessageEventExtension());
			message.to = jid;
			message.body = body;
			message.type = Message.CHAT_TYPE;
			con.send(message);
		}
	}
}
