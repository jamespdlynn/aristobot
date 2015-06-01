package com.aristobot.as3srserrvice.services
{

	import com.aristobot.data.ApplicationUser;
	import com.aristobot.data.Conversation;
	import com.aristobot.data.MessagesWrapper;
	import com.aristobot.data.OutgoingChatMessage;
	import com.aristobot.data.SystemMessage;
	import com.aristobot.data.UserCredentials;
	
	import flash.net.URLRequestHeader;
	
	import mx.managers.SystemManager;

	public class MessageService extends RestService
	{		
		public function MessageService(url:String, apiKey:String, accessToken:String)
		{
			super(url, apiKey, null, accessToken);
		}
		
		public function getSystemMessages(resultHandler:Function, faultHandler:Function = null):void
		{
			get("/messages/systemMessages", MessagesWrapper, resultHandler, faultHandler);
		}
		
		public function markMessageRead(messageKey:String, resultHandler:Function = null, faultHandler:Function = null):void
		{
			postText("/messages/markMessageRead", messageKey, resultHandler, faultHandler);
		}
		
		public function getConversation(conversationKey:String, resultHandler:Function = null, faultHandler:Function = null):void
		{
			get("/messages/conversation/"+conversationKey, Conversation, resultHandler, faultHandler);
		}
		
		public function sendChatMessage(chatMessage:OutgoingChatMessage, sendAsSystemMessage:Boolean = false, resultHandler:Function = null, faultHandler:Function = null):void
		{
			postObject("/messages/sendChatMessage?sendAsSystemMessage="+sendAsSystemMessage, chatMessage, resultHandler, faultHandler);
		}
		
		public function markConversationRead(conversationKey:String, resultHandler:Function = null, faultHandler:Function = null):void
		{
			postText("/messages/markConversationRead", conversationKey, resultHandler, faultHandler);
		}
		
		public function getConversationUpdate(conversationKey:String, resultHandler:Function, faultHandler:Function = null):void
		{
			var url:String =  "/messages/conversation/"+conversationKey+"?onlyIfUnread=true";
			get(url, Conversation, resultHandler, faultHandler);
		}
		
		public function getAllSystemMessages(resultHandler:Function, faultHandler:Function = null):void
		{
			get("/admin/messages", MessagesWrapper, resultHandler, faultHandler);
		}
		
		public function updateSystemMessage(message:SystemMessage, resultHandler:Function=null, faultHandler:Function = null):void
		{
			postObject("/admin/update-message", message, resultHandler, faultHandler);
		}
		
		public function sendSystemMessage(message:SystemMessage, sendAsEmail:Boolean = false, resultHandler:Function=null, faultHandler:Function = null):void
		{
			postObject("/admin/send-message?sendAsEmail="+sendAsEmail, message, resultHandler, faultHandler);
		}
		
		public function deleteSystemMessage(messageKey:String, resultHandler:Function=null, faultHandler:Function = null):void
		{
			postText("/admin/delete-message", messageKey, resultHandler, faultHandler);
		}

	}
}