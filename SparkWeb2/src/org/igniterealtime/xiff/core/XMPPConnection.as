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
package org.igniterealtime.xiff.core
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import org.igniterealtime.xiff.auth.*;
	import org.igniterealtime.xiff.data.*;
	import org.igniterealtime.xiff.data.auth.AuthExtension;
	import org.igniterealtime.xiff.data.bind.BindExtension;
	import org.igniterealtime.xiff.data.forms.FormExtension;
	import org.igniterealtime.xiff.data.ping.PingExtension;
	import org.igniterealtime.xiff.data.register.RegisterExtension;
	import org.igniterealtime.xiff.data.session.SessionExtension;
	import org.igniterealtime.xiff.events.*;
	import org.igniterealtime.xiff.exception.SerializationException;

	/**
	 * Dispatched when a password change is successful.
	 *
	 * @eventType org.igniterealtime.xiff.events.ChangePasswordSuccessEvent.PASSWORD_SUCCESS
	 */
	[Event(name="changePasswordSuccess", type="org.igniterealtime.xiff.events.ChangePasswordSuccessEvent")]

	/**
	 * Dispatched when the connection is successfully made to the server.
	 *
	 * @eventType org.igniterealtime.xiff.events.ConnectionSuccessEvent.CONNECT_SUCCESS
	 */
	[Event(name="connection", type="org.igniterealtime.xiff.events.ConnectionSuccessEvent")]

	/**
	 * Dispatched when there is a disconnection from the server.
	 *
	 * @eventType org.igniterealtime.xiff.events.DisconnectionEvent.DISCONNECT
	 */
	[Event(name="disconnection", type="org.igniterealtime.xiff.events.DisconnectionEvent")]

	/**
	 * Dispatched when there is some type of XMPP error.
	 *
	 * @eventType org.igniterealtime.xiff.events.XIFFErrorEvent.XIFF_ERROR
	 */
	[Event(name="error", type="org.igniterealtime.xiff.events.XIFFErrorEvent")]

	/**
	 * Dispatched whenever there is incoming XML data.
	 *
	 * @eventType org.igniterealtime.xiff.events.IncomingDataEvent.INCOMING_DATA
	 */
	[Event(name="incomingData", type="org.igniterealtime.xiff.events.IncomingDataEvent")]

	/**
	 * Dispatched on successful authentication (login) with the server.
	 *
	 * @eventType org.igniterealtime.xiff.events.LoginEvent.LOGIN
	 */
	[Event(name="login", type="org.igniterealtime.xiff.events.LoginEvent")]

	/**
	 * Dispatched on incoming messages.
	 *
	 * @eventType org.igniterealtime.xiff.events.MessageEvent.MESSAGE
	 */
	[Event(name="message", type="org.igniterealtime.xiff.events.MessageEvent")]

	/**
	 * Dispatched whenever data is sent to the server.
	 *
	 * @eventType org.igniterealtime.xiff.events.OutgoingDataEvent.OUTGOING_DATA
	 */
	[Event(name="outgoingData", type="org.igniterealtime.xiff.events.OutgoingDataEvent")]

	/**
	 * Dispatched on incoming presence data.
	 *
	 * @eventType org.igniterealtime.xiff.events.PresenceEvent.PRESENCE
	 */
	[Event(name="presence", type="org.igniterealtime.xiff.events.PresenceEvent")]

	/**
	 * Dispatched on when new user account registration is successful.
	 *
	 * @eventType org.igniterealtime.xiff.events.RegistrationSuccessEvent.REGISTRATION_SUCCESS
	 */
	[Event(name="registrationSuccess", type="org.igniterealtime.xiff.events.RegistrationSuccessEvent")]

	/**
	 * This class is used to connect to and manage data coming from an XMPP server. Use one instance
	 * of this class per connection.
	 */
	public class XMPPConnection extends EventDispatcher
	{
		/**
		 * Stream type lets user set opening/closing tag.
		 * <code>&lt;stream:stream&gt;</code>
		 */
		public static const STREAM_TYPE_STANDARD:uint = 0;
		/**
		 * Stream type lets user set opening/closing tag.
		 * <code>&lt;stream:stream /&gt;</code>
		 */
		public static const STREAM_TYPE_STANDARD_TERMINATED:uint = 1;
		/**
		 * Stream type lets user set opening/closing tag.
		 * <code>&lt;flash:stream&gt;</code>
		 */
		public static const STREAM_TYPE_FLASH:uint = 2;
		/**
		 * Stream type lets user set opening/closing tag.
		 * <code>&lt;flash:stream /&gt;</code>
		 */
		public static const STREAM_TYPE_FLASH_TERMINATED:uint = 3;
		
		/**
		 * Binary socket used to connect to the XMPP server.
		 */
		protected var socket:Socket;

		/**
		 * Server to connect, could be different of the login domain.
		 * @exampleText talk.google.com
		 */
		protected var _server:String;

		/**
		 * Domain of the user. Might differ from the one used in the connection.
		 * @exampleText gmail.com
		 */
		protected var _domain:String;

		/**
		 * @private
		 */
		protected var _username:String;

		/**
		 * @private
		 */
		protected var _password:String;

		/**
		 * @default xiff
		 */
		protected var _resource:String = "xiff";

		/**
		 * @default 5222
		 */
		protected var _port:uint = 5222;

		/**
		 * True if both sides of the connected parties have accepted the zlib compression.
		 */
		protected var compressionNegotiated:Boolean = false;

		/**
		 * @private
		 */
		protected var loggedIn:Boolean = false;

		/**
		 * @default true
		 */
		private var _ignoreWhitespace:Boolean = true;

		/**
		 * @private
		 */
		protected var openingStreamTag:String;

		/**
		 * @private
		 */
		protected var closingStreamTag:String;

		/**
		 * @private
		 */
		protected var sessionID:String;

		/**
		 * @private
		 */
		protected var auth:SASLAuth;

		/**
		 * Hash to hold callbacks for IQs
		 * @private
		 */
		protected var pendingIQs:Object = {};

		/**
		 * @private
		 */
		protected var _compress:Boolean = false;

		/**
		 * @private
		 */
		protected var _queuePresences:Boolean = true;

		/**
		 * @private
		 */
		protected var _useAnonymousLogin:Boolean = false;

		/**
		 * @private
		 */
		protected var _active:Boolean = false;

		/**
		 * @private
		 */
		protected var _expireTagSearch:Boolean;

		/**
		 * Are there more than one connection at a time?
		 */
		protected static var _openConnections:Array = [];

		/**
		 * The types of SASL mechanisms available.
		 * @see org.igniterealtime.xiff.auth.Anonymous
		 * @see org.igniterealtime.xiff.auth.DigestMD5
		 * @see org.igniterealtime.xiff.auth.External
		 * @see org.igniterealtime.xiff.auth.Plain
		 */
		protected static var saslMechanisms:Object = {
				"PLAIN": Plain,
				"ANONYMOUS": Anonymous,
				"DIGEST-MD5": DigestMD5,
				"EXTERNAL": External
			};

		/**
		 * Save the previously received data if it was incomplete.
		 */
		protected var _incompleteRawXML:String = "";

		/**
		 * One of the STREAM_TYPE_.. constants.
		 * @default STREAM_TYPE_STANDARD
		 */
		protected var _streamType:uint = 0;
		private var presenceQueue:Array = [];
		private var presenceQueueTimer:Timer;

		/**
		 * @private
		 */
		protected var _outgoingBytes:uint = 0;

		/**
		 * @private
		 */
		protected var _incomingBytes:uint = 0;

		/**
		 *
		 */
		public function XMPPConnection()
		{
			AuthExtension.enable();
			BindExtension.enable();
			SessionExtension.enable();
			RegisterExtension.enable();
			FormExtension.enable();
			PingExtension.enable();
		}

		/**
		 * Connects to the server. Use one of the STREAM_TYPE_.. constants.
		 * Possible options are:
		 * <ul>
		 * <li>standard (default)</li>
		 * <li>standard terminated</li>
		 * <li>flash</li>
		 * <li>flash terminated</li>
		 * </ul>
		 * Some servers, like Jabber, Inc.'s XCP and Jabberd 1.4 expect &lt;flash:stream&gt; from
		 * a Flash client instead of the standard &lt;stream:stream&gt;.
		 *
		 * @param	streamType Any of the STREAM_TYPE_.. constants.
		 *
		 * @return A boolean indicating whether the server was found.
		 */
		public function connect( streamType:uint = 0 ):Boolean
		{
			createSocket();
			_streamType = streamType;

			active = false;
			loggedIn = false;

			chooseStreamTags( streamType );

			socket.connect( server, port );
			return true;
		}

		/**
		 *
		 * @param	name
		 * @param	authClass
		 */
		public static function registerSASLMechanism( name:String, authClass:Class ):void
		{
			saslMechanisms[ name ] = authClass;
		}

		/**
		 *
		 * @param	name
		 */
		public static function disableSASLMechanism( name:String ):void
		{
			saslMechanisms[ name ] = null;
		}

		/**
		 * Disconnects from the server if currently connected. After disconnect,
		 * a <code>DisconnectionEvent.DISCONNECT</code> event is broadcast.
		 * @see org.igniterealtime.xiff.events.DisconnectionEvent
		 */
		public function disconnect():void
		{
			if ( isActive() )
			{
				sendXML( closingStreamTag ); // String
				if (socket && socket.connected)
				{
					socket.close();
				}
				active = false;
				loggedIn = false;

				var disconnectionEvent:DisconnectionEvent = new DisconnectionEvent();
				dispatchEvent(disconnectionEvent);
			}
		}

		/**
		 * Sends data to the server. If the data to send cannot be serialized properly,
		 * this method throws a <code>SerializeException</code>.
		 *
		 * @param	o The data to send. This must be an instance of a class that implements the ISerializable interface.
		 * @see	org.igniterealtime.xiff.data.ISerializable
		 * @example	The following example sends a basic chat message to the user with the
		 * JID "sideshowbob@springfieldpenitentiary.gov".<br />
		 * <code>var message:Message = new Message( "sideshowbob@springfieldpenitentiary.gov", null, "Hi Bob.",
		 * "<b>Hi Bob.</b>", Message.TYPE_CHAT );
		 * myXMPPConnection.send( message );</code>
		 */
		public function send( o:XMPPStanza ):void
		{
			if ( isActive() )
			{
				if ( o is IQ )
				{
					var iq:IQ = o as IQ;
					if (iq.callback != null || iq.errorCallback != null)
					{
						addIQCallbackToPending( iq.id, iq.callback, iq.errorCallback );
					}
				}
				var root:XMLNode = o.getNode().parentNode;
				if (root == null)
				{
					root = new XMLDocument();
				}

				if (o.serialize(root))
				{
					sendXML( root.firstChild ); // XMLNode
				}
				else
				{
					throw new SerializationException();
				}
			}
		}

		/**
		 * Sends ping to server in order to keep the connection alive.
		 */
		public function sendKeepAlive():void
		{
			var ping:IQ = new IQ(new EscapedJID(server), IQ.TYPE_GET);
			ping.addExtension(new PingExtension());
			send(ping);
		}

		/**
		 * Determines whether the connection with the server is currently active. (Not necessarily logged in.
		 * For login status, use the <code>isLoggedIn()</code> method.)
		 *
		 * @return A boolean indicating whether the connection is active.
		 * @see	org.igniterealtime.xiff.core.XMPPConnection#isLoggedIn
		 */
		public function isActive():Boolean
		{
			return active;
		}

		/**
		 * Determines whether the user is connected and logged into the server.
		 *
		 * @return A boolean indicating whether the user is logged in.
		 * @see	org.igniterealtime.xiff.core.XMPPConnection#isActive
		 */
		public function isLoggedIn():Boolean
		{
			return loggedIn;
		}

		/**
		 * Issues a request for the information that must be submitted for registration with the server.
		 * When the data returns, a <code>RegistrationFieldsEvent.REG_FIELDS</code> event is dispatched
		 * containing the requested data.
		 */
		public function getRegistrationFields():void
		{
			var regIQ:IQ = new IQ( new EscapedJID(domain), IQ.TYPE_GET,
									 XMPPStanza.generateID("reg_info_"), getRegistrationFields_result );
			regIQ.addExtension(new RegisterExtension(regIQ.getNode()));

			send( regIQ );
		}

		/**
		 * Registers a new account with the server, sending the registration data as specified in the fieldMap@paramter.
		 *
		 * @param	fieldMap An object map containing the data to use for registration. The map should be composed of
		 * attribute:value pairs for each registration data item.
		 * @param	key (Optional) If a key was passed in the "data" field of the "registrationFields" event,
		 * that key must also be passed here.
		 * required field needed for registration.
		 */
		public function sendRegistrationFields( fieldMap:Object, key:String ):void
		{
			var regIQ:IQ = new IQ( new EscapedJID(domain), IQ.TYPE_SET,
									 XMPPStanza.generateID("reg_attempt_"), sendRegistrationFields_result );
			var ext:RegisterExtension = new RegisterExtension(regIQ.getNode());

			for ( var i:String in fieldMap )
			{
				ext.setField(i, fieldMap[i]);
			}
			if (key != null)
			{
				ext.key = key;
			}

			regIQ.addExtension(ext);
			send( regIQ );
		}

		/**
		 * Changes the user's account password on the server. If the password change is successful,
		 * the class will broadcast a <code>ChangePasswordSuccessEvent.PASSWORD_SUCCESS</code> event.
		 *
		 * @param	newPassword The new password
		 */
		public function changePassword( newPassword:String ):void
		{
			var passwdIQ:IQ = new IQ( new EscapedJID(domain), IQ.TYPE_SET,
										XMPPStanza.generateID("pswd_change_"), changePassword_result );
			var ext:RegisterExtension = new RegisterExtension(passwdIQ.getNode());

			ext.username = jid.escaped.bareJID;
			ext.password = newPassword;

			passwdIQ.addExtension(ext);
			send( passwdIQ );
		}

		/**
		 * Choose the stream start and ending tags based on the given type.
		 * @param	type	One of the <code>STREAM_TYPE_...</code> constants of this class.
		 */
		protected function chooseStreamTags(type:uint):void
		{
			openingStreamTag = '<?xml version="1.0" encoding="UTF-8"?>';
			if (type == STREAM_TYPE_FLASH || type == STREAM_TYPE_FLASH_TERMINATED)
			{
				openingStreamTag += '<flash';
				closingStreamTag = '</flash:stream>';
			}
			else
			{
				openingStreamTag += '<stream';
				closingStreamTag = '</stream:stream>';
			}

			openingStreamTag += ':stream xmlns="' + XMPPStanza.CLIENT_NAMESPACE + '" ';

			if (type == STREAM_TYPE_FLASH || type == STREAM_TYPE_FLASH_TERMINATED)
			{
				openingStreamTag += 'xmlns:flash="' + XMPPStanza.NAMESPACE_FLASH + '"';
			}
			else
			{
				openingStreamTag += 'xmlns:stream="' + XMPPStanza.NAMESPACE_STREAM + '"';
			}
			openingStreamTag += ' to="' + domain + '"'
				+ ' xml:lang="' + XMPPStanza.XML_LANG + '"'
				+ ' version="' + XMPPStanza.CLIENT_VERSION + '"';

			if (type == STREAM_TYPE_FLASH_TERMINATED || type == STREAM_TYPE_STANDARD_TERMINATED)
			{
				openingStreamTag += ' /';
			}

			openingStreamTag += '>';
		}

		/**
		 *
		 * @param	resultIQ
		 */
		protected function changePassword_result( resultIQ:IQ ):void
		{
			if ( resultIQ.type == IQ.TYPE_RESULT )
			{
				var event:ChangePasswordSuccessEvent = new ChangePasswordSuccessEvent();
				dispatchEvent(event);
			}
			else
			{
				// We weren't expecting this
				dispatchError( "unexpected-request", "Unexpected Request", "wait", 400 );
			}
		}

		/**
		 *
		 * @param	resultIQ
		 */
		protected function getRegistrationFields_result( resultIQ:IQ ):void
		{
			try
			{
				var ext:RegisterExtension = resultIQ.getAllExtensionsByNS(RegisterExtension.NS)[0];
				var fields:Array = ext.getRequiredFieldNames(); //TODO, phase this out

				var event:RegistrationFieldsEvent = new RegistrationFieldsEvent();
				event.fields = fields;
				event.data = ext;

				dispatchEvent(event);
			}
			catch (err:Error)
			{
				trace(err.getStackTrace());
			}
		}

		/**
		 * @private
		 */
		protected function sendRegistrationFields_result( resultIQ:IQ ):void
		{
			if ( resultIQ.type == IQ.TYPE_RESULT )
			{
				var event:RegistrationSuccessEvent = new RegistrationSuccessEvent();
				dispatchEvent( event );
			}
			else
			{
				// We weren't expecting this
				dispatchError( "unexpected-request", "Unexpected Request", "wait", 400 );
			}
		}

		/**
		 * Calls a appropriate parser base on the nodeName.
		 * @param	firstNode
		 */
		protected function handleNodeType(node:XMLNode):void
		{
			var nodeName:String = node.nodeName.toLowerCase();

			switch( nodeName )
			{
				case "stream:stream":
				case "flash:stream":
					_expireTagSearch = false;
					handleStream( node );
					break;

				case "stream:error":
					handleStreamError( node );
					break;

				case "stream:features":
					handleStreamFeatures( node );
					break;

				case "iq":
					handleIQ( node );
					break;

				case "message":
					handleMessage( node );
					break;

				case "presence":
					handlePresence( node );
					break;

				case "challenge":
					handleChallenge( node );
					break;

				case "success":
					handleAuthentication( node );
					break;

				case "compressed":
					// This states that the other side has accepted to use compression.
					// Now the connection needs to be reopened.
					compressionNegotiated = true;
					restartStream();
					break;

				case "failure":
					// Might be also that the requested compression method is not available.
					handleAuthentication( node );
					break;

				default:
					// silently ignore lack of or unknown stanzas
					// if the app designer wishes to handle raw data they
					// can on "incomingData".

					// Use case: received null byte, XMLSocket parses empty document
					// sends empty document

					// I am enabling this for debugging
					dispatchError( "undefined-condition", "Unknown Error", "modify", 500 );
					break;
			}
		}

		/**
		 * @private
		 */
		protected function handleStream( node:XMLNode ):void
		{
			sessionID = node.attributes.id;
			domain = node.attributes.from;

			for each(var childNode:XMLNode in node.childNodes)
			{
				if (childNode.nodeName == "stream:features")
				{
					handleStreamFeatures(childNode);
				}
			}
		}

		/**
		 * @see http://xmpp.org/registrar/stream-features.html
		 */
		protected function handleStreamFeatures( node:XMLNode ):void
		{
			if (!loggedIn)
			{
				for each(var feature:XMLNode in node.childNodes)
				{
					if (feature.nodeName == "starttls")
					{
						handleStreamTLS(feature);
					}
					else if (feature.nodeName == "mechanisms")
					{
						configureAuthMechanisms(feature);
					}
					else if (feature.nodeName == "compression")
					{
						// zlib is the most common and the one which is required to be implemented.
						if (_compress)
						{
							configureStreamCompression();
						}
					}
				}

				// Authenticate only after the possible compression
				if ((compress && compressionNegotiated) || !compress)
				{
					// TODO: Why is the username required here but it is not used at the backend?
					if (useAnonymousLogin || (username != null && username.length > 0))
					{
						beginAuthentication();
					}
					else
					{
						getRegistrationFields();
					}
				}
			}
			else
			{
				bindConnection();
			}
		}
		
		/**
		 *
		 * @param	node The feature containing starttls tag.
		 */
		protected function handleStreamTLS( node:XMLNode ):void
		{
			if (node.firstChild && node.firstChild.nodeName == "required")
			{
				// No TLS support yet
				dispatchError("TLS required", "The server requires TLS, but this feature is not implemented.", "cancel", 501);
				disconnect();
				return;
			}
		}

		/**
		 * Use the authentication which is first in the list (saslMechanisms) if possible.
		 * @param	mechanisms
		 * @see #saslMechanisms
		 */
		protected function configureAuthMechanisms(mechanisms:XMLNode):void
		{
			var authClass:Class;
			for each(var mechanism:XMLNode in mechanisms.childNodes)
			{
				authClass = saslMechanisms[mechanism.firstChild.nodeValue];
				if (useAnonymousLogin)
				{
					if (authClass == Anonymous)
					{
						break;
					}
				}
				else
				{
					if (authClass != Anonymous && authClass != null)
					{
						break;
					}
				}
			}

			if (!authClass)
			{
				dispatchError("SASL missing", "The server is not configured to support any available SASL mechanisms", "SASL", -1);
			}
			else
			{
				auth = new authClass(this);
			}
		}

		/**
		 * Ask the server to enable Zlib compression of the stream.
		 */
		protected function configureStreamCompression():void
		{
			// TODO: Build a proper extension which takes care XML building.
			var ask:XML = <compress xmlns="http://jabber.org/protocol/compress"><method>zlib</method></compress>;
			sendXML(ask); // XML
		}

		/**
		 * @private
		 */
		protected function handleStreamError( node:XMLNode ):void
		{
			dispatchError( "service-unavailable", "Remote Server Error", "cancel", 502 );

			// Cancel everything by closing connection
			try
			{
				socket.close();
			}
			catch (error:Error)
			{

			}

			active = false;
			loggedIn = false;

			var disconnectionEvent:DisconnectionEvent = new DisconnectionEvent();
			dispatchEvent( disconnectionEvent );
		}

		/**
		 * @private
		 */
		protected function handleIQ( node:XMLNode ):IQ
		{
			var iq:IQ = new IQ();
			// Populate the IQ with the incoming data
			if ( !iq.deserialize( node ) )
			{
				throw new SerializationException();
			}

			// If it's an error, handle it
			var callbackInfo:*;
			if ( iq.type == IQ.TYPE_ERROR)
			{
				dispatchError( iq.errorCondition, iq.errorMessage, iq.errorType, iq.errorCode );

				// Start the callback for this IQ if one exists
				if ( pendingIQs[iq.id] !== undefined )
				{
					callbackInfo = pendingIQs[iq.id];

					if (callbackInfo.errorFunc != null)
					{
						callbackInfo.errorFunc( iq );
					}
					pendingIQs[iq.id] = null;
					delete pendingIQs[iq.id];
				}
			}
			else
			{
				// Start the callback for this IQ if one exists
				if ( pendingIQs[iq.id] !== undefined )
				{
					callbackInfo = pendingIQs[iq.id];

					if (callbackInfo.func != null)
					{
						callbackInfo.func( iq );
					}
					pendingIQs[iq.id] = null;
					delete pendingIQs[iq.id];
				}
				else
				{
					var exts:Array = iq.getAllExtensions();
					for (var ns:String in exts)
					{
						// Static type casting
						var ext:IExtension = exts[ns] as IExtension;
						if (ext != null)
						{
							var iqEvent:IQEvent = new IQEvent(ext.getNS());
							iqEvent.data = ext;
							iqEvent.iq = iq;
							dispatchEvent( iqEvent );
						}
					}
				}
			}
			return iq;
		}

		/**
		 * @private
		 */
		protected function handleMessage( node:XMLNode ):Message
		{
			var message:Message = new Message();
			// Populate with data
			if ( !message.deserialize( node ) )
			{
				throw new SerializationException();
			}
			// ADDED in error handling for messages
			if ( message.type == Message.TYPE_ERROR )
			{
				var exts:Array = message.getAllExtensions();
				dispatchError( message.errorCondition, message.errorMessage,
					message.errorType, message.errorCode, exts.length > 0 ? exts[0] : null);
			}
			else
			{
				var messageEvent:MessageEvent = new MessageEvent();
				messageEvent.data = message;
				dispatchEvent( messageEvent );
			}
			return message;
		}

		/**
		 * @private
		 */
		protected function handlePresence( node:XMLNode ):Presence
		{
			if (!presenceQueueTimer)
			{
				presenceQueueTimer = new Timer(1, 1);
				presenceQueueTimer.addEventListener(TimerEvent.TIMER_COMPLETE, flushPresenceQueue);
			}

			var presence:Presence = new Presence();

			// Populate
			if ( !presence.deserialize( node ) )
			{
				throw new SerializationException();
			}

			if(queuePresences)
			{
				presenceQueue.push( presence );
	
				presenceQueueTimer.reset();
				presenceQueueTimer.start();
			}
			else
			{
				var presenceEvent:PresenceEvent = new PresenceEvent();
				presenceEvent.data = [ presence ];
				dispatchEvent( presenceEvent );
			}
			
			return presence;
		}

		protected function flushPresenceQueue(event:TimerEvent):void
		{
			if(presenceQueue.length > 0) {
				var presenceEvent:PresenceEvent = new PresenceEvent();
				presenceEvent.data = presenceQueue;
				dispatchEvent( presenceEvent );
				presenceQueue = [];
			}
		}

		/**
		 * @see flash.net.Socket
		 */
		protected function createSocket():void
		{
			socket = new Socket();
			socket.addEventListener(Event.CLOSE, socketClosed);
			socket.addEventListener(Event.CONNECT, socketConnected);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataReceived);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		}

		/**
		 *
		 * @param	event
		 */
		protected function socketDataReceived( event:ProgressEvent ):void
		{
			var bytedata:ByteArray = new ByteArray();
			// The default value of 0 causes all available data to be read.
			socket.readBytes( bytedata );
			parseDataReceived( bytedata );
		}
		
		/**
		 * Parses the data which the socket just received.
		 * Used to simplify the overrides from classes extending this one.
		 * @param	bytedata
		 */
		protected function parseDataReceived( bytedata:ByteArray ):void
		{
			// Increase the incoming data counter.
			_incomingBytes += bytedata.length;
			
			if (compressionNegotiated)
			{
				bytedata.uncompress();
			}
			bytedata.position = 0;
			var data:String = bytedata.readUTFBytes( bytedata.length );

			var rawXML:String = _incompleteRawXML + data;
			
			var rawData:ByteArray = new ByteArray();
			rawData.writeUTFBytes( rawXML );
			
			// data comign in could also be parts of base64 encoded stuff.
			
			// parseXML is more strict in AS3 so we must check for the presence of flash:stream
			// the unterminated tag should be in the first string of xml data retured from the server
			// TODO: use constants and the current setting against finding the start/end tags of stream.
			if (!_expireTagSearch)
			{
				var pattern:RegExp = new RegExp("<flash:stream");
				var resultObj:Object = pattern.exec(rawXML);
				if (resultObj != null) // stop searching for unterminated node
				{
					rawXML = rawXML.concat("</flash:stream>");
					_expireTagSearch = true;
				}
			}

			if (!_expireTagSearch)
			{
				var pattern2:RegExp = new RegExp("<stream:stream");
				var resultObj2:Object = pattern2.exec(rawXML);
				if (resultObj2 != null) // stop searching for unterminated node
				{
					rawXML = rawXML.concat("</stream:stream>");
					_expireTagSearch = true;
				}
			}

			var xmlData:XMLDocument = new XMLDocument();
			xmlData.ignoreWhite = _ignoreWhitespace;

			//var xml:XML;
			//XML.ignoreWhiteSpace = _ignoreWhitespace;

			//error handling to catch incomplete xml strings that have
			//been truncated by the socket
			try
			{
				//xml = new XML(rawXML);

				var isComplete: Boolean = true;
				xmlData.parseXML( rawXML );
				_incompleteRawXML = '';


			}
			catch (err:Error)
			{
				//concatenate the raw xml to the previous xml
				isComplete = false;
				_incompleteRawXML += data;
			}

			if (isComplete)
			{
				var incomingEvent:IncomingDataEvent = new IncomingDataEvent();
				incomingEvent.data = rawData;
				dispatchEvent( incomingEvent );
				
				var len:uint = xmlData.childNodes.length;
				for (var i:int = 0; i < len; ++i)
				{
					// Read the data and send it to the appropriate parser
					var currentNode:XMLNode = xmlData.childNodes[i];
					handleNodeType(currentNode);
				}
			}
		}

		/**
		 *
		 * @param	event
		 */
		protected function socketClosed(event:Event):void
		{
			active = false;
			loggedIn = false;
			
			var disconnectionEvent:DisconnectionEvent = new DisconnectionEvent();
			dispatchEvent( disconnectionEvent );
		}

		/**
		 *
		 * @param	event
		 */
		protected function socketConnected(event:Event):void
		{
			active = true;
			sendXML( openingStreamTag ); // String
			var connectionEvent:ConnectionSuccessEvent = new ConnectionSuccessEvent();
			dispatchEvent( connectionEvent );
		}

		/**
		 * This fires the standard dispatchError method. need to add the appropriate error code
		 * @private
		 */
		protected function onIOError(event:IOErrorEvent):void
		{
			dispatchError( "service-unavailable", "Service Unavailable", "cancel", 503 );
		}

		/**
		 * @private
		 */
		protected function onSecurityError(event:SecurityErrorEvent):void
		{
			trace("there was a security error of type: " + event.type + "\nError: " + event.text);
			dispatchError( "not-authorized", "Not Authorized", "auth", 401 );
		}

		/**
		 * @private
		 */
		protected function dispatchError( condition:String, message:String, type:String, code:int, extension:Extension = null ):void
		{
			var event:XIFFErrorEvent = new XIFFErrorEvent();
			event.errorCondition = condition;
			event.errorMessage = message;
			event.errorType = type;
			event.errorCode = code;
			event.errorExt = extension;
			dispatchEvent( event );
		}

		/**
		 * Data is untyped because it could be a string or XML.
		 * TODO: Accept only XML.
		 * @param	someData
		 */
		protected function sendXML( someData:* ):void
		{
			someData = someData is XML ? XML( someData ).toXMLString() : someData;
			
			var bytedata:ByteArray = new ByteArray();
			bytedata.writeUTFBytes(someData);
			
			bytedata.position = 0;
			if (compressionNegotiated)
			{
				bytedata.compress();
				bytedata.position = 0; // maybe not needed.
			}
			if ( socket && socket.connected )
			{
				socket.writeBytes( bytedata, 0, bytedata.length );
				socket.flush();
			}
			
			_outgoingBytes += bytedata.length;

			var event:OutgoingDataEvent = new OutgoingDataEvent();
			event.data = bytedata;
			dispatchEvent( event );
		}

		/**
		 * @private
		 */
		protected function beginAuthentication():void
		{
			if (auth != null)
			{
				sendXML(auth.request); // XMLNode
			}
			else
			{
				// We did not have a suitable auth method for this connection.
			}
		}

		/**
		 * @private
		 */
		protected function handleChallenge(challengeBody:XMLNode):void
		{
			var response:XML = auth.handleChallenge(0, XML(challengeBody.toString()));
			sendXML(response);
		}

		/**
		 * @private
		 */
		protected function handleAuthentication(responseBody:XMLNode):void
		{
			var status:Object = auth.handleResponse(0, XML(responseBody.toString()));
			if (status.authComplete)
			{
				if (status.authSuccess)
				{
					loggedIn = true;
					restartStream();
				}
				else
				{
					// ? dispatchError( "not-authorized", "Not Authorized", "auth", 401 );
					dispatchError("Authentication Error", "", "", 401);
					disconnect();
				}
			}
		}

		/**
		 * @private
		 */
		protected function restartStream():void
		{
			sendXML(openingStreamTag); // String
		}

		/**
		 * @private
		 */
		protected function bindConnection():void
		{
			var bindIQ:IQ = new IQ(null, IQ.TYPE_SET);

			var bindExt:BindExtension = new BindExtension();
			if (resource)
			{
				bindExt.resource = resource;
			}

			bindIQ.addExtension(bindExt);

			bindIQ.callback = handleBindResponse;
			bindIQ.errorCallback = handleBindError;

			send(bindIQ);
		}

		/**
		 * @private
		 */
		protected function handleBindResponse(packet:IQ):void
		{
			var bind:BindExtension = packet.getExtension("bind") as BindExtension;

			var jid:UnescapedJID = bind.jid.unescaped;

			_resource = jid.resource;
			_username = jid.node;
			_domain = jid.domain;

			establishSession();
		}
		
		/**
		 * Error handler callback
		 * @param	packet
		 */
		protected function handleBindError(packet:IQ):void
		{
			
		}

		/**
		 * @private
		 */
		private function establishSession():void
		{
			var sessionIQ:IQ = new IQ(null, IQ.TYPE_SET);

			sessionIQ.addExtension(new SessionExtension());

			sessionIQ.callback = handleSessionResponse;
			sessionIQ.errorCallback = handleSessionError;

			send(sessionIQ);
		}

		/**
		 * @private
		 */
		private function handleSessionResponse(packet:IQ):void
		{
			dispatchEvent(new LoginEvent());
		}
		
		/**
		 *
		 * @param	packet
		 */
		private function handleSessionError(packet:IQ):void
		{
			
		}

		/**
		 * @private
		 */
		protected function addIQCallbackToPending( id:String, callbackFunc:Function, errorCallbackFunc:Function ):void
		{
			pendingIQs[id] = { func:callbackFunc, errorFunc:errorCallbackFunc };
		}

		/**
		 * The XMPP server to use for connection.
		 */
		public function get server():String
		{
			if (!_server)
			{
				return _domain;
			}
			return _server;
		}
		public function set server( value:String ):void
		{
			_server = value;
		}

		/**
		 * The XMPP domain to use with the server.
		 */
		public function get domain():String
		{
			if (!_domain)
			{
				return _server;
			}
			return _domain;
		}
		public function set domain( value:String ):void
		{
			_domain = value;
		}

		/**
		 * The username to use for connection. If this property is null when <code>connect()</code> is called,
		 * the class will fetch registration field data rather than attempt to login.
		 */
		public function get username():String
		{
			return _username;
		}
		public function set username( value:String ):void
		{
			_username = value;
		}

		/**
		 * The password to use when logging in.
		 */
		public function get password():String
		{
			return _password;
		}
		public function set password( value:String ):void
		{
			_password = value;
		}

		/**
		 * The resource to use when logging in. A resource is required (defaults to "XIFF") and
		 * allows a user to login using the same account simultaneously (most likely from multiple machines).
		 * Typical examples of the resource include "Home" or "Office" to indicate the user's current location.
		 */
		public function get resource():String
		{
			return _resource;
		}
		public function set resource( value:String ):void
		{
			if ( value.length > 0 )
			{
				_resource = value;
			}
		}

		/**
		 * Whether to use anonymous login or not.
		 */
		public function get useAnonymousLogin():Boolean
		{
			return _useAnonymousLogin;
		}
		public function set useAnonymousLogin(value:Boolean):void
		{
			// set only if not connected
			if (!isActive())
			{
				_useAnonymousLogin = value;
			}
		}

		/**
		 * The port to use when connecting. The default XMPP port is 5222.
		 */
		public function get port():uint
		{
			return _port;
		}
		public function set port( value:uint ):void
		{
			_port = value;
		}

		/**
		 * Determines whether whitespace will be ignored on incoming XML data.
		 * Behaves the same as <code>XML.ignoreWhitespace</code>
		 */
		public function get ignoreWhiteSpace():Boolean
		{
			return _ignoreWhitespace;
		}
		public function set ignoreWhiteSpace( value:Boolean ):void
		{
			_ignoreWhitespace = value;
			XML.ignoreWhitespace = value;
		}

		/**
		 * Shall the zlib compression be allowed if the server supports it.
		 * @see http://xmpp.org/extensions/xep-0138.html
		 * @default false
		 */
		public function get compress():Boolean
		{
			return _compress;
		}
		public function set compress(value:Boolean):void
		{
			_compress = value;
		}

		/**
		 * Should the connection queue presence events for a small interval so that it can send multiple in a batch?
		 * @default true To maintain original behavior -- has to be explicitly set to false to disable.
		 */
		public function get queuePresences():Boolean
		{
			return _queuePresences;
		}
		public function set queuePresences(value:Boolean):void
		{
			if(_queuePresences && !value)
			{		// if we are disabling queueing, handle all queued presence
				if(presenceQueueTimer)
					presenceQueueTimer.stop();
				
				flushPresenceQueue(null);
			}
			_queuePresences = value;
		}

		/**
		 * Gets the fully qualified unescaped JID of the user.
		 * A fully-qualified JID includes the resource. A bare JID does not.
		 * To get the bare JID, use the <code>bareJID</code> property of the UnescapedJID.
		 *
		 * @return The fully qualified unescaped JID
		 * @see	org.igniterealtime.xiff.core.UnescapedJID#bareJID
		 */
		public function get jid():UnescapedJID
		{
			return new UnescapedJID(_username + "@" + _domain + "/" + _resource);
		}

		/**
		 *
		 */
		protected function get active():Boolean
		{
			return _active;
		}
		protected function set active(value:Boolean):void
		{
			if (value)
			{
				_openConnections.push(this);
			}
			else
			{
				_openConnections.splice(_openConnections.indexOf(this), 1);
			}
			_active = value;
		}
		
		/**
		 * Get the count of the received bytes.
		 */
		public function get incomingBytes():uint
		{
			return _incomingBytes;
		}
		
		/**
		 * Get the count of current bytes sent by this connection
		 */
		public function get outgoingBytes():uint
		{
			return _outgoingBytes;
		}

		/**
		 *
		 */
		public static function get openConnections():Array
		{
			return _openConnections;
		}
	}
}
