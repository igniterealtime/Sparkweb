package com.jivesoftware.spark.chats
{
	public interface ChatUI
	{
		function get isTyping():Boolean;
		function set isTyping(flag:Boolean):void;
		
		function addMessage(message:SparkMessage):void;
		function addNotification(body:String, time:Date = null):void;
	}
}