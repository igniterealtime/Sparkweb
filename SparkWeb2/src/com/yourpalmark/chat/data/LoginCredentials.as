package com.yourpalmark.chat.data
{
	public class LoginCredentials
	{
		public var username:String;
		public var password:String;
		
		public function LoginCredentials( username:String=null, password:String=null )
		{
			this.username = username;
			this.password = password;
		}
		
	}
}