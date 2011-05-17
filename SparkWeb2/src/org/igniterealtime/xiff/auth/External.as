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
	import com.hurlant.util.Base64;

	import org.igniterealtime.xiff.core.XMPPConnection;

	/**
	 * This class provides SASL authentication using the EXTERNAL mechanism.
	 * This is particularly useful when TLS authentication is required.
	 * @see http://xmpp.org/extensions/xep-0178.html
	 */
	public class External extends SASLAuth
	{
		public static const MECHANISM:String = "EXTERNAL";

		public static const NS:String = "urn:ietf:params:xml:ns:xmpp-sasl";

		/**
		 * Creates a new External authentication object.
		 *
		 * @param	connection A reference to the XMPPConnection instance in use.
		 */
		public function External( connection:XMPPConnection )
		{
			var authContent:String = connection.jid.node;

			authContent = Base64.encode(authContent);

			/*
			var b64coder:Base64Encoder = new Base64Encoder();
			b64coder.insertNewLines = false;
			b64coder.encode( authContent );
			authContent = b64coder.flush();
			*/

			req.setNamespace( External.NS );
			req.@mechanism = External.MECHANISM;
			req.setChildren( authContent );

			stage = 0;
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
