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
package org.igniterealtime.xiff.data.id
{
	import org.igniterealtime.xiff.data.id.IIDGenerator;
	
	/**
	 * Uses a simple incrementation of a static variable to generate new IDs.
	 * Guaranteed to generate unique IDs for the duration of application execution.
	 */
	public class IncrementalGenerator implements IIDGenerator
	{
		private var myCounter:int = 0;
		private static var instance:IIDGenerator;
		
		public static function getInstance():IIDGenerator
		{
			if(instance == null)
			{
				instance = new IncrementalGenerator();
			}
			
			return instance;
		}
	
		public function IncrementalGenerator()
		{
			
		}
	
		/**
		 * Gets the unique ID.
		 *
		 * @param	prefix The ID prefix to use when generating the ID
		 * @return The generated ID
		 */
		public function getID(prefix:String):String
		{
			myCounter++;
			var id:String;
	
			if ( prefix != null ) {
				id = prefix + myCounter;
			} else {
				id = myCounter.toString();
			}
			return id;
		}
	}
}
