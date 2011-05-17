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
package org.igniterealtime.xiff.auth
{
	import com.hurlant.crypto.hash.MD5;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;

	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import org.igniterealtime.xiff.core.XMPPConnection;

	/**
	 * This class provides SASL authentication using the DIGEST-MD5 mechanism, a HTTP Digest
	 * compatible challenge-response scheme based upon MD5. DIGEST-MD5 offers a data security layer.
	 * @see http://en.wikipedia.org/wiki/Digest_access_authentication
	 * @see http://tools.ietf.org/html/rfc1321
	 * @see http://www.ietf.org/rfc/rfc2831.txt
	 */
	public class DigestMD5 extends SASLAuth
	{
		public static const MECHANISM:String = "DIGEST-MD5";

		public static const NS:String = "urn:ietf:params:xml:ns:xmpp-sasl";

		private var connection:XMPPConnection;

		/**
		* Creates a new External authentication object.
		*
		* @param	connection A reference to the XMPPConnection instance in use.
		*/
		public function DigestMD5( connection:XMPPConnection )
		{
			this.connection = connection;

			var authContent:String = Base64.encode( connection.jid.node );

			req.setNamespace( DigestMD5.NS );
			req.@mechanism = DigestMD5.MECHANISM;
			req.setChildren( authContent );

			stage = 0;
		}

		/**
		 * Construct the response as described by DIGEST-MD5 documentation.
		 */
		private function formatResponse( map:Dictionary ):String
		{
			var md5:MD5 = new MD5();

			var password:String = connection.password;

			var ha1_1:ByteArray = new ByteArray();
			ha1_1.writeUTFBytes( map.username + ":" + map.realm + ":" + password );
			ha1_1 = md5.hash( ha1_1 );

			var ha1_2:ByteArray = new ByteArray();
			ha1_2.writeUTFBytes( ":" + map.nonce + ":" + map.cnonce );

			var ha1:ByteArray = new ByteArray();
			ha1.writeBytes( ha1_1 );
			ha1.writeBytes( ha1_2 );
			ha1 = md5.hash( ha1 );

			var ha2:ByteArray = new ByteArray();
			ha2.writeUTFBytes( "AUTHENTICATE:" + map[ "digest-uri" ] );
			ha2 = md5.hash( ha2 );

			var sha1:String = convertToBase16String( ha1 );
			var sha2:String = convertToBase16String( ha2 );

			var b:ByteArray = new ByteArray();
			b.writeUTFBytes( sha1 + ":" + map.nonce + ":" + map.nc + ":" + map.cnonce + ":" + map.qop + ":" + sha2 );
			b = md5.hash( b );

			return Hex.fromArray( b );
		}

		private function convertToBase16String( bytes:ByteArray ):String
		{
			var str:String = "";

			bytes.position = 0;
			while( bytes.bytesAvailable )
			{
				var byte:int = bytes.readUnsignedByte();
				var byteStr:String = byte.toString( 16 ).toLowerCase();
				str += byteStr.length == 1 ? "0" + byteStr : byteStr;
			}

			return str;
		}

		/**
		 * Called when a challenge to this authentication is received.
		 *
		 * @param	stage The current stage in the authentication process.
		 * @param	challenge The XML of the actual authentication challenge.
		 *
		 * @return The XML response to the challenge.
		 */
		override public function handleChallenge( stage:int, challenge:XML ):XML
		{
			var decodedChallenge:String = Base64.decode( challenge );
			var challengeKeyValuePairs:Array = decodedChallenge.replace( /\"/g, "").split( "," );
			var challengeMap:Dictionary = new Dictionary();
			for each( var keyValuePair:String in challengeKeyValuePairs )
			{
				var keyValue:Array = keyValuePair.split( "=" );
				challengeMap[ keyValue[ 0 ] ] = keyValue[ 1 ];
			}

			var resp:XML = new XML( response );
			resp.setNamespace( DigestMD5.NS );

			if( !challengeMap.rspauth )
			{
				var responseMap:Dictionary = new Dictionary();
				responseMap.username = connection.username;
				responseMap.realm = challengeMap.realm ? challengeMap.realm : "";
				responseMap.nonce = challengeMap.nonce;
				responseMap.cnonce = new Date().time;
				responseMap.nc = "00000001";
				responseMap.qop = challengeMap.qop ? challengeMap.qop : "auth";
				responseMap[ "digest-uri" ] = "xmpp/" + ( challengeMap.realm ? challengeMap.realm : connection.domain );
				responseMap.charset = challengeMap.charset;
				responseMap.response = formatResponse( responseMap );

				var challengeResponse:String = "username=\"" + responseMap.username + "\"";
				if( challengeMap.realm ) challengeResponse += ",realm=\"" + responseMap.realm + "\"";
				challengeResponse += ",nonce=\"" + responseMap.nonce + "\"";
				challengeResponse += ",cnonce=\"" + responseMap.cnonce + "\"";
				challengeResponse += ",nc=" + responseMap.nc;
				challengeResponse += ",qop=" + responseMap.qop;
				challengeResponse += ",digest-uri=\"" + responseMap[ "digest-uri" ] + "\"";
				challengeResponse += ",response=" + responseMap.response;
				challengeResponse += ",charset=" + responseMap.charset;
				challengeResponse = Base64.encode( challengeResponse );

				resp.setChildren( challengeResponse );
			}

			return resp;
		}

		/**
		* Called when a response to this authentication is received.
		*
		* @param	stage The current stage in the authentication process.
		* @param	response The XML of the actual authentication response.
		*
		* @return An object specifying the current state of the authentication.
		*/
		override public function handleResponse( stage:int, response:XML ):Object
		{
			var success:Boolean = response.localName() == "success";
			return {
				authComplete: true,
				authSuccess: success,
				authStage: stage++
			};
		}
	}
}
