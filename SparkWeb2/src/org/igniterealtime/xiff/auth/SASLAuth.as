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
	/**
	 * This is a base class for use with Simple Authentication and Security Layer
	 * (SASL) mechanisms. Sub-class this class when creating new SASL mechanisms.
	 * @see http://tools.ietf.org/html/rfc4422
	 * @see http://en.wikipedia.org/wiki/Simple_Authentication_and_Security_Layer
	 */
	public class SASLAuth
	{
		/**
		 * The XML of the authentication request.
		 */
		protected var req:XML = <auth/>;

		/**
		 * The XML of the challenge response.
		 */
		protected var response:XML = <response/>;

		/**
		 * The current response stage.
		 */
		protected var stage:int;

		public function SASLAuth()
		{
			// Don't call directly SASLAuth; use a subclass
		}

		/**
		 * Called when a challenge to this authentication is received.
		 *
		 * @param	stage The current stage in the authentication process.
		 * @param	challenge The XML of the actual authentication challenge.
		 *
		 * @return The XML response to the challenge.
		 */
		public function handleChallenge( stage:int, challenge:XML ):XML
		{
			throw new Error( "Don't call this method on SASLAuth; use a subclass" );
		}

		/**
		 * Called when a response to this authentication is received.
		 *
		 * @param	stage The current stage in the authentication process.
		 * @param	response The XML of the actual authentication response.
		 *
		 * @return An object specifying the current state of the authentication.
		 */
		public function handleResponse( stage:int, response:XML ):Object
		{
			throw new Error( "Don't call this method on SASLAuth; use a subclass" );
		}

		/**
		 * The XML for the authentication request.
		 */
		public function get request():XML
		{
			return req;
		}
	}
}
