package com.yourpalmark.chat
{
	import com.yourpalmark.chat.data.LoginCredentials;
	
	import flash.events.EventDispatcher;
	import flash.system.Security;
	
	import org.igniterealtime.xiff.conference.InviteListener;
	import org.igniterealtime.xiff.core.JID;
	import org.igniterealtime.xiff.core.XMPPSocketConnection;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.data.im.RosterItemVO;
	import org.igniterealtime.xiff.data.muc.MUC;
	import org.igniterealtime.xiff.events.ConnectionSuccessEvent;
	import org.igniterealtime.xiff.events.DisconnectionEvent;
	import org.igniterealtime.xiff.events.IncomingDataEvent;
	import org.igniterealtime.xiff.events.InviteEvent;
	import org.igniterealtime.xiff.events.LoginEvent;
	import org.igniterealtime.xiff.events.MessageEvent;
	import org.igniterealtime.xiff.events.OutgoingDataEvent;
	import org.igniterealtime.xiff.events.PresenceEvent;
	import org.igniterealtime.xiff.events.RegistrationFieldsEvent;
	import org.igniterealtime.xiff.events.RegistrationSuccessEvent;
	import org.igniterealtime.xiff.events.RosterEvent;
	import org.igniterealtime.xiff.events.XIFFErrorEvent;
	import org.igniterealtime.xiff.im.Roster;
	
	public class ChatManager extends EventDispatcher
	{
		[Bindable]
		public static var serverLocation:String = "localhost";
		
		private var streamType:String = "standard";
		private var registerUser:Boolean;
		private var registrationData:Object;
		
		private var _connection:XMPPSocketConnection;
		private var _inviteListener:InviteListener;
		private var _roster:Roster;
		private var _currentUserJID:JID;
		
		public function ChatManager()
		{
			setupConnection();
			setupInviteListener();
			setupRoster();
			setupChat();
		}
		
		public static function isValidJID( jid:JID ):Boolean
		{
			var value:Boolean = false;
			var pattern:RegExp = /(\w|[_.\-])+@(localhost$|((\w|-)+\.)+\w{2,4}$){1}/;
			var result:Object = pattern.exec( jid.toString() );
			if( result )
			{
				value = true;
			}
			return value;
		}
		
		public function get connection():XMPPSocketConnection
		{
			return _connection;
		}
		
		public function get inviteListener():InviteListener
		{
			return _inviteListener;
		}
		
		public function get roster():Roster
		{
			return _roster;
		}
		
		public function get currentUserJID():JID
		{
			return _currentUserJID;
		}
		
		public function connect( credentials:LoginCredentials ):void
		{
			Security.loadPolicyFile( serverLocation + "/crossdomain.xml" );
			registerUser = false;
			_currentUserJID = new JID( credentials.username );
			connection.username = credentials.username;
			connection.password = credentials.password;
			connection.server = serverLocation;
			connection.connect( streamType );
		}
		
		public function disconnect():void
		{
			connection.disconnect();
		}
		
		public function updatePresence( show:String, status:String ):void
		{
			roster.setPresence( show, status, 0 );
		}
		
		public function register( credentials:LoginCredentials ):void
        {
			registerUser = true;
			
			connection.username = null;
			connection.password = null;	
			
			connection.server = serverLocation;
			connection.connect( streamType );
			
			registrationData = {};
			registrationData.username = credentials.username;
			registrationData.password = credentials.password;
        }
		
		public function addBuddy( jid:JID ):void
		{
			roster.addContact( jid, jid.toString(), "Buddies", true );
		}
		
		public function removeBuddy( rosterItem:RosterItemVO ):void
		{
			roster.removeContact( rosterItem );
		}
		
		public function updateGroup( rosterItem:RosterItemVO, groupName:String ):void
		{
			roster.updateContactGroups( rosterItem, [ groupName ] );
		}
		
		private function setupConnection():void
		{
			_connection = new XMPPSocketConnection();
			_connection.addEventListener( ConnectionSuccessEvent.CONNECT_SUCCESS, onConnectSuccess );
			_connection.addEventListener( DisconnectionEvent.DISCONNECT, onDisconnect );
			_connection.addEventListener( LoginEvent.LOGIN, onLogin );
			_connection.addEventListener( XIFFErrorEvent.XIFF_ERROR, onXIFFError );
			_connection.addEventListener( OutgoingDataEvent.OUTGOING_DATA, onOutgoingData )
			_connection.addEventListener( IncomingDataEvent.INCOMING_DATA, onIncomingData );
			_connection.addEventListener( RegistrationFieldsEvent.REG_FIELDS, onRegistrationFields );
			_connection.addEventListener( RegistrationSuccessEvent.REGISTRATION_SUCCESS, onRegistrationSuccess );
			_connection.addEventListener( PresenceEvent.PRESENCE, onPresence );
			_connection.addEventListener( MessageEvent.MESSAGE, onMessage );
		}
		
		private function setupInviteListener():void
		{
			_inviteListener = new InviteListener();
			_inviteListener.addEventListener( InviteEvent.INVITED, onInvited );
			_inviteListener.setConnection( _connection );
		}
		
		private function setupRoster():void
		{
			_roster = new Roster();
			_roster.addEventListener( RosterEvent.ROSTER_LOADED, onRosterLoaded );
			_roster.addEventListener( RosterEvent.SUBSCRIPTION_DENIAL, onSubscriptionDenial );
			_roster.addEventListener( RosterEvent.SUBSCRIPTION_REQUEST, onSubscriptionRequest );
			_roster.addEventListener( RosterEvent.SUBSCRIPTION_REVOCATION, onSubscriptionRevocation );
			_roster.addEventListener( RosterEvent.USER_ADDED, onUserAdded );
			_roster.addEventListener( RosterEvent.USER_AVAILABLE, onUserAvailable );
			_roster.addEventListener( RosterEvent.USER_PRESENCE_UPDATED, onUserPresenceUpdated );
			_roster.addEventListener( RosterEvent.USER_REMOVED, onUserRemoved );
			_roster.addEventListener( RosterEvent.USER_SUBSCRIPTION_UPDATED, onUserSubscriptionUpdated );
			_roster.addEventListener( RosterEvent.USER_UNAVAILABLE, onUserUnavailable );
			_roster.connection = _connection;
		}
		
		private function setupChat():void
		{
			MUC.enable();
		}
		
		
		private function onConnectSuccess( event:ConnectionSuccessEvent ):void
		{
			if( registerUser )
			{
				_connection.sendRegistrationFields( registrationData, null );
			}
			
			dispatchEvent( event );
		}
		
		private function onDisconnect( event:DisconnectionEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onLogin( event:LoginEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onXIFFError( event:XIFFErrorEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onOutgoingData( event:OutgoingDataEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onIncomingData( event:IncomingDataEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onRegistrationFields( event:RegistrationFieldsEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onRegistrationSuccess( event:RegistrationSuccessEvent ):void
		{
			_connection.disconnect();
			dispatchEvent( event );
		}
		
		private function onPresence( event:PresenceEvent ):void
		{
			var presence:Presence = event.data[ 0 ] as Presence;
			
			if( presence.type == Presence.ERROR_TYPE )
			{
				var xiffErrorEvent:XIFFErrorEvent = new XIFFErrorEvent();
				xiffErrorEvent.errorCode = presence.errorCode;
				xiffErrorEvent.errorCondition = presence.errorCondition;
				xiffErrorEvent.errorMessage = presence.errorMessage;
				xiffErrorEvent.errorType = presence.errorType;
				onXIFFError( xiffErrorEvent );
			}
			else
			{
				dispatchEvent( event );
			}
		}
		
		private function onMessage( event:MessageEvent ):void
		{
			var message:Message = event.data as Message;
			
			if( message.type == Message.ERROR_TYPE )
			{
				var xiffErrorEvent:XIFFErrorEvent = new XIFFErrorEvent();
				xiffErrorEvent.errorCode = message.errorCode;
				xiffErrorEvent.errorCondition = message.errorCondition;
				xiffErrorEvent.errorMessage = message.errorMessage;
				xiffErrorEvent.errorType = message.errorType;
				onXIFFError( xiffErrorEvent );
			}
			else
			{
				dispatchEvent( event );
			}
		}
		
		private function onInvited( event:InviteEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onRosterLoaded( event:RosterEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onSubscriptionDenial( event:RosterEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onSubscriptionRequest( event:RosterEvent ):void
		{
			if( _roster.contains( RosterItemVO.get( event.jid, false ) ) )
			{
				_roster.grantSubscription( event.jid, true );
			}
			
			dispatchEvent( event );
		}
		
		private function onSubscriptionRevocation( event:RosterEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onUserAdded( event:RosterEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onUserAvailable( event:RosterEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onUserPresenceUpdated( event:RosterEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onUserRemoved( event:RosterEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onUserSubscriptionUpdated( event:RosterEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onUserUnavailable( event:RosterEvent ):void
		{
			dispatchEvent( event );
		}
		
	}
}