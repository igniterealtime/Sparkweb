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
package org.igniterealtime.xiff.vcard
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.xml.XMLDocument;

	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.XMPPStanza;
	import org.igniterealtime.xiff.data.vcard.VCardExtension;
	import org.igniterealtime.xiff.events.VCardEvent;
	import org.igniterealtime.xiff.util.DateTimeParser;

	/**
	 * Dispatched when the vCard has loaded.
	 *
	 * @eventType org.igniterealtime.xiff.events.VCardEvent.LOADED
	 */
	[Event( name="loaded", type="org.igniterealtime.xiff.events.VCardEvent" )]

	/**
	 * Dispatched when the vCard has been saved.
	 *
	 * @eventType org.igniterealtime.xiff.events.VCardEvent.SAVED
	 */
	[Event( name="saved", type="org.igniterealtime.xiff.events.VCardEvent" )]

	/**
	 * Dispatched when saving the vCard fails.
	 *
	 * @eventType org.igniterealtime.xiff.events.VCardEvent.SAVE_ERROR
	 */
	[Event( name="saveError", type="org.igniterealtime.xiff.events.VCardEvent" )]

	/**
	 * @see http://tools.ietf.org/html/rfc2426
	 */
	public class VCard extends EventDispatcher
	{
		/**
		 * The interval on which to flush the vCard cache.
		 * The default value is 6 hours.
		 */
		public static var cacheFlushInterval:Number = ( 6 * 60 * 60 * 1000 );

		/**
		 * VCard cache indexed by the UnescapedJID.bareJID of the user.
		 */
		private static var cache:Dictionary = new Dictionary();

		/**
		 * Flush the vCard cache every 6 hours by default.
		 */
		private static var cacheFlushTimer:Timer = new Timer( cacheFlushInterval, 0 );

		/**
		 * Queue of the pending requests
		 */
		private static var requestQueue:Array = [];

		/**
		 * Timer to process the queue.
		 */
		private static var requestTimer:Timer;

		/**
		 * Birthday.
		 */
		public var birthday:Date;

		/**
		 * Free-form descriptive text.
		 */
		public var description:String;

		/**
		 * Email address.
		 */
		public var email:String;

		/**
		 * Formatted or display name.
		 */
		public var formattedName:String;

		/**
		 * Geographical position.
		 */
		public var geographicalPosition:VCardGeographicalPosition;

		/**
		 * Structured home address.
		 */
		public var homeAddress:VCardAddress;

		/**
		 * Home address label.
		 */
		public var homeAddressLabel:String;

		/**
		 * Home telephone number.
		 */
		public var homeTelephone:VCardTelephone;

		/**
		 * Jabber ID.
		 */
		public var jid:UnescapedJID;

		/**
		 * Organization logo.
		 */
		public var logo:VCardPhoto;

		/**
		 * Mailer (e.g., Mail User Agent Type).
		 */
		public var mailer:String;

		/**
		 * Structured name.
		 */
		public var name:VCardName;

		/**
		 * Nickname.
		 */
		public var nickname:String;

		/**
		 * Commentary note.
		 */
		public var note:String;

		/**
		 * Organizational name and unit.
		 */
		public var organization:VCardOrganization;

		/**
		 * Photograph.
		 */
		public var photo:VCardPhoto;

		/**
		 * Privacy classification.
		 */
		public var privacyClass:String;

		/**
		 * Identifier of product that generated the vCard.
		 */
		public var productID:String;

		/**
		 * Last revised.
		 */
		public var revision:Date;

		/**
		 * Role.
		 */
		public var role:String;

		/**
		 * Sort string.
		 */
		public var sortString:String;

		/**
		 * Formatted name pronunciation.
		 */
		public var sound:VCardSound;

		/**
		 * Time zone's Standard Time UTC offset.
		 */
		public var timezone:Date;

		/**
		 * Title.
		 */
		public var title:String;

		/**
		 * Unique identifier.
		 */
		public var uid:String;

		/**
		 * Directory URL.
		 */
		public var url:String;

		/**
		 * Version of the vCard. Usually 2.0 or 3.0.
		 * @see http://xmpp.org/extensions/xep-0054.html#impl
		 */
		public var version:String;

		/**
		 * Structured work address.
		 */
		public var workAddress:VCardAddress;

		/**
		 * Work address label.
		 */
		public var workAddressLabel:String;

		/**
		 * Work telephone number.
		 */
		public var workTelephone:VCardTelephone;

		/**
		 * @private
		 */
		private var extensionNames:Array = [];

		/**
		 * @private
		 */
		private var _loaded:Boolean;

		/**
		 * @private
		 */
		private var _extensions:Dictionary = new Dictionary();

		/**
		 * Don't call directly, use the static method getVCard() and add a callback.
		 */
		public function VCard()
		{
		}

		/**
		 * The way a vCard is requested and then later referred to.
		 * <code>var vCard:VCard = VCard.getVCard( connection, jid );<br />
		 * vCard.addEventListener( VCardEvent.LOADED, onVCardLoaded );</code>
		 * @param connection
		 * @param jid
		 * @return Reference to the vCard which will be filled once the loaded event occurs.
		 */
		public static function getVCard( connection:XMPPConnection, jid:UnescapedJID ):VCard
		{
			if ( !cacheFlushTimer.running )
			{
				cacheFlushTimer.reset();
				cacheFlushTimer.delay = cacheFlushInterval;
				cacheFlushTimer.start();
				cacheFlushTimer.addEventListener( TimerEvent.TIMER, function( event:TimerEvent ):void
				{
					for each ( var card:VCard in cache )
					{
						pushRequest( connection, card );
					}
					clearCache();
				} );
			}

			var cachedCard:VCard = cache[ jid.bareJID ] as VCard;
			if ( cachedCard )
			{
				return cachedCard;
			}

			var vCard:VCard = new VCard();
			vCard.jid = jid;

			cache[ jid.bareJID ] = vCard;

			pushRequest( connection, vCard );

			return vCard;
		}

		/**
		 * Immediately expires the vCard cache.
		 */
		public static function expireCache():void
		{
			if ( cacheFlushTimer.running )
			{
				cacheFlushTimer.stop();
			}
		}

		/**
		 * Immediately clears the vCard cache.
		 */
		public static function clearCache():void
		{
			cache = new Dictionary();
		}

		/**
		 * Add the request to the stack of requests
		 * @param connection
		 * @param vCard
		 */
		private static function pushRequest( connection:XMPPConnection, vCard:VCard ):void
		{
			if ( !requestTimer )
			{
				requestTimer = new Timer( 1, 1 );
				requestTimer.addEventListener( TimerEvent.TIMER_COMPLETE, sendRequest );
			}
			requestQueue.push( { connection: connection, card: vCard } );
			requestTimer.reset();
			requestTimer.start();
		}

		/**
		 * Send a request
		 * @param event
		 */
		private static function sendRequest( event:TimerEvent ):void
		{
			if ( requestQueue.length == 0 )
			{
				return;
			}
			var req:Object = requestQueue.pop();
			var connection:XMPPConnection = req.connection;
			var vCard:VCard = req.card;
			var jid:UnescapedJID = vCard.jid;

			var recipient:EscapedJID = jid.equals( connection.jid, true ) ? null : jid.escaped;
			var iq:IQ = new IQ( recipient, IQ.TYPE_GET );

			iq.callback = vCard.handleVCard;
			iq.addExtension( new VCardExtension() );

			connection.send( iq );
			requestTimer.reset();
			requestTimer.start();
		}

		/**
		 * Deserializes the incoming IQ to fill the values of this vCard.
		 * @param iq
		 */
		public function handleVCard( iq:IQ ):void
		{
			namespace ns = "vcard-temp";
			use namespace ns;

			var node:XML = XML( iq.getNode() );
			var vCardNode:XML = node.children()[ 0 ];

			if ( !vCardNode )
			{
				return;
			}

			version = vCardNode.@version;

			var nodes:XMLList = vCardNode.children();

			for each ( var child:XML in nodes )
			{
				switch ( child.localName() )
				{
					//There is some ambiguity surrounding how vCard versions are handled so
					//we need to check it here as well as looking for the attribute as above.
					//SEE:  http://xmpp.org/extensions/xep-0054.html#impl
					case "VERSION":
						version = child.text();
						break;

					case "FN":
						formattedName = child.text();
						break;

					case "N":
						name = new VCardName( child.GIVEN, child.MIDDLE, child.FAMILY, child.PREFIX, child.SUFFIX );
						break;

					case "NICKNAME":
						nickname = child.text();
						break;

					case "PHOTO":
						photo = new VCardPhoto();
						for each ( var photoData:XML in child.children() )
						{
							var photoValue:String = photoData.text();

							if ( photoData.localName() == "TYPE" && photoValue.length > 0 )
							{
								photo.type = photoValue;
							}
							else if ( photoData.localName() == "BINVAL" && photoValue.length > 0 )
							{
								photo.binaryValue = photoValue;
							}
							else if ( photoData.localName() == "EXTVAL" && photoValue.length > 0 )
							{
								photo.externalValue = photoValue;
							}
						}
						break;

					case "BDAY":
						var bday:String = child.children()[ 0 ];
						if ( bday != null && bday.length > 8 )
						{
							birthday = DateTimeParser.string2date( bday );
						}
						break;

					case "ADR":
						if ( child.WORK.length() == 1 )
						{
							workAddress = new VCardAddress( child.STREET, child.LOCALITY, child.REGION, child.PCODE, child.CTRY, child.EXTADD, child.POBOX );
						}
						else if ( child.HOME.length() == 1 )
						{
							homeAddress = new VCardAddress( child.STREET, child.LOCALITY, child.REGION, child.PCODE, child.CTRY, child.EXTADD, child.POBOX );
						}
						break;

					case "LABEL":
						if ( child.WORK.length() == 1 )
						{
							workAddressLabel = child.LINE;
						}
						else if ( child.HOME.length() == 1 )
						{
							homeAddressLabel = child.LINE;
						}
						break;

					case "TEL":
						if ( child.WORK.length() == 1 )
						{
							workTelephone = new VCardTelephone();
							if ( child.VOICE.length() == 1 )
								workTelephone.voice = child.NUMBER;
							else if ( child.FAX.length() == 1 )
								workTelephone.fax = child.NUMBER;
							else if ( child.PAGER.length() == 1 )
								workTelephone.pager = child.NUMBER;
							else if ( child.MSG.length() == 1 )
								workTelephone.msg = child.NUMBER;
							else if ( child.CELL.length() == 1 )
								workTelephone.cell = child.NUMBER;
							else if ( child.VIDEO.length() == 1 )
								workTelephone.video = child.NUMBER;
						}
						else if ( child.HOME.length() == 1 )
						{
							homeTelephone = new VCardTelephone();
							if ( child.VOICE.length() == 1 )
								homeTelephone.voice = child.NUMBER;
							else if ( child.FAX.length() == 1 )
								homeTelephone.fax = child.NUMBER;
							else if ( child.PAGER.length() == 1 )
								homeTelephone.pager = child.NUMBER;
							else if ( child.MSG.length() == 1 )
								homeTelephone.msg = child.NUMBER;
							else if ( child.CELL.length() == 1 )
								homeTelephone.cell = child.NUMBER;
							else if ( child.VIDEO.length() == 1 )
								homeTelephone.video = child.NUMBER;
						}
						break;

					case "EMAIL":
						for each ( var emailChild:XML in child.children() )
						{
							if ( emailChild.localName() == "USERID" )
							{
								email = emailChild.children()[ 0 ];
							}
						}
						break;

					case "JABBERID":
						var jabberid:String = child.text();
						if ( jabberid != null && jabberid.length > 0 )
						{
							jid = new UnescapedJID( jabberid );
						}
						break;

					case "MAILER":
						mailer = child.text();
						break;

					case "TZ":
						var tz:String = child.children()[ 0 ];
						if ( tz != null && tz.length > 8 )
						{
							timezone = DateTimeParser.string2date( tz );
						}
						break;

					case "GEO":
						geographicalPosition = new VCardGeographicalPosition( child.LAT, child.LON );
						break;

					case "TITLE":
						title = child.text();
						break;

					case "ROLE":
						role = child.text();
						break;

					case "LOGO":
						logo = new VCardPhoto();
						for each ( var logoData:XML in child.children() )
						{
							var logoValue:String = logoData.text();

							if ( logoData.localName() == "TYPE" && logoValue.length > 0 )
							{
								logo.type = logoValue;
							}
							else if ( logoData.localName() == "BINVAL" && logoValue.length > 0 )
							{
								logo.binaryValue = logoValue;
							}
							else if ( logoData.localName() == "EXTVAL" && logoValue.length > 0 )
							{
								logo.externalValue = logoValue;
							}
						}
						break;

					case "AGENT":
						break;

					case "ORG":
						organization = new VCardOrganization( child.ORGNAME, child.ORGUNIT );
						break;

					case "CATEGORIES":
						break;

					case "NOTE":
						note = child.text();
						break;

					case "PRODID":
						productID = child.text();
						break;

					case "REV":
						var rev:String = child.children()[ 0 ];
						if ( rev != null && rev.length > 8 )
						{
							revision = DateTimeParser.string2date( rev );
						}
						break;

					case "SORT-STRING":
						sortString = child.text();
						break;

					case "SOUND":
						sound = new VCardSound();
						if ( child.PHONETIC.length() == 1 )
						{
							sound.phonetic = child.PHONETIC;
						}
						else if ( child.BINVAL.length() == 1 )
						{
							sound.binaryValue = child.BINVAL;
						}
						else if ( child.EXTVAL.length() == 1 )
						{
							sound.externalValue = child.EXTVAL;
						}
						break;

					case "UID":
						uid = child.text();
						break;

					case "URL":
						url = child.text();
						break;

					case "CLASS":
						if ( child.PUBLIC.length() == 1 )
						{
							privacyClass = "public";
						}
						else if ( child.PRIVATE.length() == 1 )
						{
							privacyClass = "private";
						}
						else if ( child.CONFIDENTIAL.length() == 1 )
						{
							privacyClass = "confidential";
						}
						break;

					case "KEY":
						break;

					case "DESC":
						description = child.text();
						break;

					default:
						trace( "handleVCard. Private extension: " + child.name() );
						extensionNames.push( child.localName() );
						extensions[ child.localName() ] = child.text().toString();
						break;
				}
			}

			_loaded = true;
			dispatchEvent( new VCardEvent( VCardEvent.LOADED, this, true, false ) );
		}

		/**
		 * Saves a vCard.
		 * @param connection
		 */
		public function saveVCard( connection:XMPPConnection ):void
		{
			var id:String = XMPPStanza.generateID( "save_vcard_" );
			var iq:IQ = new IQ( null, IQ.TYPE_SET, id, saveVCard_result );
			var vcardExt:VCardExtension = new VCardExtension();
			var vcardExtNode:XML = new XML( vcardExt.getNode().toString() );

			//FN
			if ( formattedName )
			{
				vcardExtNode.FN = formattedName;
			}

			//N
			if ( name )
			{
				var nameNode:XML = <N/>;

				if ( name.family )
				{
					nameNode.FAMILY = name.family;
				}

				if ( name.given )
				{
					nameNode.GIVEN = name.given;
				}

				if ( name.middle )
				{
					nameNode.MIDDLE = name.middle;
				}

				if ( name.prefix )
				{
					nameNode.PREFIX = name.prefix;
				}

				if ( name.suffix )
				{
					nameNode.SUFFIX = name.suffix;
				}

				vcardExtNode.appendChild( nameNode );
			}

			//NICKNAME
			if ( nickname )
			{
				vcardExtNode.NICKNAME = nickname;
			}

			//PHOTO
			if ( photo && ( ( photo.type && photo.binaryValue ) || photo.externalValue ) )
			{
				var photoNode:XML = <PHOTO/>;

				if ( photo.binaryValue )
				{
					try
					{
						var photoBinaryNode:XML = <BINVAL/>;
						photoBinaryNode.appendChild( photo.binaryValue );
						photoNode.appendChild( photoBinaryNode );
					}
					catch( error:Error )
					{
						throw new Error( "VCard:saveVCard Error converting bytes to string " + error.message );
					}

					var photoTypeNode:XML = <TYPE/>;
					photoTypeNode.appendChild( photo.type );
					photoNode.appendChild( photoTypeNode );
				}
				else
				{
					var photoExtNode:XML = <EXTVAL/>;
					photoExtNode.appendChild( photo.externalValue );
					photoNode.appendChild( photoExtNode );
				}

				vcardExtNode.appendChild( photoNode );
			}

			//BDAY
			if ( birthday )
			{
				vcardExtNode.BDAY = DateTimeParser.date2string( birthday );
			}

			//ADR
			if ( workAddress )
			{
				var workAddressNode:XML = <ADR/>;
				workAddressNode.appendChild( <WORK/> );

				if ( workAddress.poBox )
				{
					workAddressNode.POBOX = workAddress.poBox;
				}

				if ( workAddress.extendedAddress )
				{
					workAddressNode.EXTADD = workAddress.extendedAddress;
				}

				if ( workAddress.street )
				{
					workAddressNode.STREET = workAddress.street;
				}

				if ( workAddress.locality )
				{
					workAddressNode.LOCALITY = workAddress.locality;
				}

				if ( workAddress.region )
				{
					workAddressNode.REGION = workAddress.region;
				}

				if ( workAddress.postalCode )
				{
					workAddressNode.PCODE = workAddress.postalCode;
				}

				if ( workAddress.country )
				{
					workAddressNode.CTRY = workAddress.country;
				}

				vcardExtNode.appendChild( workAddressNode );
			}

			if ( homeAddress )
			{
				var homeAddressNode:XML = <ADR/>;
				homeAddressNode.appendChild( <HOME/> );

				if ( homeAddress.poBox )
				{
					homeAddressNode.POBOX = homeAddress.poBox;
				}

				if ( homeAddress.extendedAddress )
				{
					homeAddressNode.EXTADD = homeAddress.extendedAddress;
				}

				if ( homeAddress.street )
				{
					homeAddressNode.STREET = homeAddress.street;
				}

				if ( homeAddress.locality )
				{
					homeAddressNode.LOCALITY = homeAddress.locality;
				}

				if ( homeAddress.region )
				{
					homeAddressNode.REGION = homeAddress.region;
				}

				if ( homeAddress.postalCode )
				{
					homeAddressNode.PCODE = homeAddress.postalCode;
				}

				if ( homeAddress.country )
				{
					homeAddressNode.CTRY = homeAddress.country;
				}

				vcardExtNode.appendChild( homeAddressNode );
			}

			//LABEL
			if ( workAddressLabel )
			{
				var workAddressLabelNode:XML = <LABEL/>;
				workAddressLabelNode.appendChild( <WORK/> );
				workAddressLabelNode.LINE = workAddressLabel;
				vcardExtNode.appendChild( workAddressLabelNode );
			}

			if ( homeAddressLabel )
			{
				var homeAddressLabelNode:XML = <LABEL/>;
				homeAddressLabelNode.appendChild( <HOME/> );
				homeAddressLabelNode.LINE = homeAddressLabel;
				vcardExtNode.appendChild( homeAddressLabelNode );
			}

			//TEL
			var phoneNode:XML = <TEL/>;
			if ( workTelephone )
			{
				phoneNode.setChildren( <WORK/> );

				if ( workTelephone.voice )
				{
					var workVoiceNode:XML = phoneNode.copy();
					workVoiceNode.appendChild( <VOICE/> );
					workVoiceNode.NUMBER = workTelephone.voice;
					vcardExtNode.appendChild( workVoiceNode );
				}

				if ( workTelephone.fax )
				{
					var workFaxNode:XML = phoneNode.copy();
					workFaxNode.appendChild( <FAX/> );
					workFaxNode.NUMBER = workTelephone.fax;
					vcardExtNode.appendChild( workFaxNode );
				}

				if ( workTelephone.pager )
				{
					var workPagerNode:XML = phoneNode.copy();
					workPagerNode.appendChild( <PAGER/> );
					workPagerNode.NUMBER = workTelephone.pager;
					vcardExtNode.appendChild( workPagerNode );
				}

				if ( workTelephone.msg )
				{
					var workMsgNode:XML = phoneNode.copy();
					workMsgNode.appendChild( <MSG/> );
					workMsgNode.NUMBER = workTelephone.msg;
					vcardExtNode.appendChild( workMsgNode );
				}

				if ( workTelephone.cell )
				{
					var workCellNode:XML = phoneNode.copy();
					workCellNode.appendChild( <CELL/> );
					workCellNode.NUMBER = workTelephone.cell;
					vcardExtNode.appendChild( workCellNode );
				}

				if ( workTelephone.video )
				{
					var workVideoNode:XML = phoneNode.copy();
					workVideoNode.appendChild( <VIDEO/> );
					workVideoNode.NUMBER = workTelephone.video;
					vcardExtNode.appendChild( workVideoNode );
				}
			}
			if ( homeTelephone )
			{
				phoneNode.setChildren( <HOME/> );

				if ( homeTelephone.voice )
				{
					var homeVoiceNode:XML = phoneNode.copy();
					homeVoiceNode.appendChild( <VOICE/> );
					homeVoiceNode.NUMBER = homeTelephone.voice;
					vcardExtNode.appendChild( homeVoiceNode );
				}

				if ( homeTelephone.fax )
				{
					var homeFaxNode:XML = phoneNode.copy();
					homeFaxNode.appendChild( <FAX/> );
					homeFaxNode.NUMBER = homeTelephone.fax;
					vcardExtNode.appendChild( homeFaxNode );
				}

				if ( homeTelephone.pager )
				{
					var homePagerNode:XML = phoneNode.copy();
					homePagerNode.appendChild( <PAGER/> );
					homePagerNode.NUMBER = homeTelephone.pager;
					vcardExtNode.appendChild( homePagerNode );
				}

				if ( homeTelephone.msg )
				{
					var homeMsgNode:XML = phoneNode.copy();
					homeMsgNode.appendChild( <MSG/> );
					homeMsgNode.NUMBER = homeTelephone.msg;
					vcardExtNode.appendChild( homeMsgNode );
				}

				if ( homeTelephone.cell )
				{
					var homeCellNode:XML = phoneNode.copy();
					homeCellNode.appendChild( <CELL/> );
					homeCellNode.NUMBER = homeTelephone.cell;
					vcardExtNode.appendChild( homeCellNode );
				}

				if ( homeTelephone.video )
				{
					var homeVideoNode:XML = phoneNode.copy();
					homeVideoNode.appendChild( <VIDEO/> );
					homeVideoNode.NUMBER = homeTelephone.video;
					vcardExtNode.appendChild( homeVideoNode );
				}
			}

			//EMAIL
			if ( email )
			{
				var emailNode:XML = <EMAIL/>;
				emailNode.appendChild( <INTERNET/> );
				emailNode.appendChild( <PREF/> );
				emailNode.USERID = email;
				vcardExtNode.appendChild( emailNode );
			}

			//JABBERID
			if ( jid )
			{
				vcardExtNode.JABBERID = jid.toString();
			}

			//MAILER
			if ( mailer )
			{
				vcardExtNode.MAILER = mailer;
			}

			//TZ
			if ( timezone )
			{
				vcardExtNode.TZ = DateTimeParser.date2string( timezone );
			}

			//GEO
			if( geographicalPosition )
			{
				var geoNode:XML = <GEO/>;

				if ( geographicalPosition.latitude )
				{
					geoNode.LAT = geographicalPosition.latitude;
				}

				if ( geographicalPosition.longitude )
				{
					geoNode.LON = geographicalPosition.longitude;
				}

				vcardExtNode.appendChild( geoNode );
			}

			//TITLE
			if ( title )
			{
				vcardExtNode.TITLE = title;
			}

			//ROLE
			if ( role )
			{
				vcardExtNode.ROLE = role;
			}

			//LOGO
			if ( logo && ( ( logo.type && logo.binaryValue ) || logo.externalValue ) )
			{
				var logoNode:XML = <LOGO/>;

				if ( logo.binaryValue )
				{
					try
					{
						var logoBinaryNode:XML = <BINVAL/>;
						logoBinaryNode.appendChild( logo.binaryValue );
						logoNode.appendChild( logoBinaryNode );
					}
					catch( error:Error )
					{
						throw new Error( "VCard:saveVCard Error converting bytes to string " + error.message );
					}

					var logoTypeNode:XML = <TYPE/>;
					logoTypeNode.appendChild( logo.type );
					logoNode.appendChild( logoTypeNode );
				}
				else
				{
					var logoExtNode:XML = <EXTVAL/>;
					logoExtNode.appendChild( logo.externalValue );
					logoNode.appendChild( logoExtNode );
				}

				vcardExtNode.appendChild( logoNode );
			}

			//AGENT

			//ORG
			if ( organization )
			{
				var organizationNode:XML = <ORG/>;

				if ( organization.name )
				{
					organizationNode.ORGNAME = organization.name;
				}

				if ( organization.unit )
				{
					organizationNode.ORGUNIT = organization.unit;
				}

				vcardExtNode.appendChild( organizationNode );
			}

			//CATEGORIES

			//NOTE
			if ( note )
			{
				vcardExtNode.NOTE = note;
			}

			//PRODID
			if ( productID )
			{
				vcardExtNode.PRODID = productID;
			}

			//REV
			if ( revision )
			{
				vcardExtNode.REV = DateTimeParser.date2string( revision );
			}

			//SORT-STRING
			if ( sortString )
			{
				var sortStringNode:XML = <SORT-STRING/>;
				sortStringNode.appendChild( sortString );
				vcardExtNode.appendChild( sortStringNode );
			}

			//SOUND
			if ( sound && ( sound.phonetic || sound.binaryValue || sound.externalValue ) )
			{
				var soundNode:XML = <SOUND/>;

				if ( sound.phonetic )
				{
					var phoneticNode:XML = <PHONETIC/>;
					phoneticNode.appendChild( sound.phonetic );
					soundNode.appendChild( phoneticNode );
				}
				else if ( sound.binaryValue )
				{
					try
					{
						var soundBinaryNode:XML = <BINVAL/>;
						soundBinaryNode.appendChild( sound.binaryValue );
						soundNode.appendChild( soundBinaryNode );
					}
					catch( error:Error )
					{
						throw new Error( "VCard:saveVCard Error converting bytes to string " + error.message );
					}
				}
				else
				{
					var soundExtNode:XML = <EXTVAL/>;
					soundExtNode.appendChild( sound.externalValue );
					soundNode.appendChild( soundExtNode );
				}

				vcardExtNode.appendChild( soundNode );
			}

			//UID
			if ( uid )
			{
				vcardExtNode.UID = uid;
			}

			//URL
			if ( url )
			{
				vcardExtNode.URL = url;
			}

			//CLASS
			if( privacyClass && ( privacyClass == "public" || privacyClass == "private" || privacyClass == "confidential" ) )
			{
				var classNode:XML = <CLASS/>;

				if ( privacyClass == "public" )
				{
					var publicNode:XML = <PUBLIC/>;
					classNode.appendChild( publicNode );
				}
				else if ( privacyClass == "private" )
				{
					var privateNode:XML = <PRIVATE/>;
					classNode.appendChild( privateNode );
				}
				else ( privacyClass == "confidential" )
				{
					var confidentialNode:XML = <CONFIDENTIAL/>;
					classNode.appendChild( confidentialNode );
				}

				vcardExtNode.appendChild( classNode );
			}

			//KEY

			//DESC
			if ( description )
			{
				vcardExtNode.DESC = description;
			}

			//X
			if ( extensionNames.length > 0 )
			{
				for each( var xName:String in extensionNames )
				{
					vcardExtNode[ xName ] = _extensions[ xName ];
				}
			}

			var xmlDoc:XMLDocument = new XMLDocument( vcardExtNode.toString() );
			vcardExt.setNode( xmlDoc.firstChild );

			iq.addExtension( vcardExt );
			connection.send( iq );
		}

		/**
		 *
		 * @param resultIQ
		 */
		public function saveVCard_result( resultIQ:IQ ):void
		{
			var bareJID:String = resultIQ.to.unescaped.bareJID;
			if ( resultIQ.type == IQ.TYPE_ERROR )
			{
				dispatchEvent( new VCardEvent( VCardEvent.SAVE_ERROR, cache[ bareJID ],
					true, true ) );
			}
			else
			{
				delete cache[ bareJID ]; // Force profile refresh on next view
				
				dispatchEvent( new VCardEvent( VCardEvent.SAVED, this, true, false ) );
			}
		}

		/**
		 * Indicates whether the vCard has been loaded.
		 */
		public function get loaded():Boolean
		{
			return _loaded;
		}

		/**
		 * Map of the vCard's private extensions.
		 */
		public function get extensions():Dictionary
		{
			return _extensions;
		}
	}
}
