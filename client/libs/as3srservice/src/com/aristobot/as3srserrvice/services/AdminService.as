package com.aristobot.as3srserrvice.services
{

	import com.aristobot.as3srserrvice.events.ResultEvent;
	import com.aristobot.data.IconsWrapper;
	import com.aristobot.data.PushNotification;
	import com.aristobot.data.Tokens;
	import com.aristobot.data.UserIcon;
	
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;

	public class AdminService extends RestService
	{		
		public function AdminService(url:String, apiKey:String, accessToken:String = null)
		{
			super(url, apiKey, null, accessToken);
		}
		
		public function set accessToken(value:String):void
		{
			_accessToken = value;
			createHeaders();
		}
				
		public function login(resultHandler:Function, faultHandler:Function = null):void
		{
			get("/admin/login", Tokens, resultHandler, faultHandler);
		}
		
		public function clean(resultHandler:Function=null, faultHandler:Function = null):void
		{
			postText("/admin/clean", " ", resultHandler, faultHandler);
		}
		
		public function updateRankings(resultHandler:Function=null, faultHandler:Function = null):void
		{
			postText("/admin/update-rankings", " ", resultHandler, faultHandler);
		}
		
		public function sendPushNotificationToUser(username:String, applicationId:int, message:String, params:String=null, resultHandler:Function=null, faultHandler:Function = null):void
		{
			var pn:PushNotification = new PushNotification();
			
			pn.username = username;
			pn.applicationId = applicationId;
			pn.message = message;
			pn.params = params;
			
			postObject("/admin/send-push-user", pn, resultHandler, faultHandler);
		}
		
		public function sendPushNotificationToAll(applicationId:int, message:String, params:String=null, resultHandler:Function=null, faultHandler:Function = null):void
		{
			var pn:PushNotification = new PushNotification();
			
			pn.applicationId = applicationId;
			pn.message = message;
			pn.params = params;
			
			postObject("/admin/send-push-all", pn, resultHandler, faultHandler);
		}
				
		override protected function result(resultObj:Object):void
		{
			if (resultObj is Tokens){
				accessToken = (resultObj as Tokens).accessToken;
				dispatchEvent(new ResultEvent(ResultEvent.AUTHENTICATED, resultObj));
			}
			
			super.result(resultObj);
		}
		
	}
}