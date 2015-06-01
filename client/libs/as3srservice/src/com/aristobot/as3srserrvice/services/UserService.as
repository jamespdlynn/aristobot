package com.aristobot.as3srserrvice.services
{

	import com.aristobot.data.ApplicationUser;
	import com.aristobot.data.User;
	import com.aristobot.data.UserCredentials;
	import com.aristobot.data.UsersWrapper;
	
	import flash.net.URLRequestHeader;

	public class UserService extends RestService
	{		
		public function UserService(url:String, apiKey:String, accessToken:String)
		{
			super(url, apiKey, null, accessToken);
		}
		
		public function getCurrentUser(resultHandler:Function, faultHandler:Function = null, includeIcons:Boolean = true, includeMessages:Boolean=true):void
		{
			get("/user?includeIcons="+includeIcons+"&includeMessages"+includeMessages, ApplicationUser, resultHandler, faultHandler);
		}
				
		public function updateUserInfo(creds:UserCredentials, resultHandler:Function = null, faultHandler:Function = null):void
		{
			postObject("/user/update", creds, resultHandler, faultHandler);	
		}
		
		public function getTopUsers(resultHandler:Function, faultHandler:Function=null):void
		{
			get("/user/leaderboard", UsersWrapper, resultHandler, faultHandler);
		}
		
		public function findUserByEmail(email:String, resultHandler:Function = null, faultHandler:Function = null):void
		{
			get("/user/find?email="+email, User, resultHandler, faultHandler);	
		}
		
		public function findUserByUsername(username:String, resultHandler:Function = null, faultHandler:Function = null):void
		{
			get("/user/find?username="+username, User, resultHandler, faultHandler);	
		}
		
		public function searchForUsers(keyword:String, resultHandler:Function, faultHandler:Function=null):void
		{
			get("/user/search?keyword="+keyword, UsersWrapper, resultHandler, faultHandler);
		}
		
		public function searchForUsersByEmail(email:String, resultHandler:Function, faultHandler:Function=null):void
		{
			get("/user/search?email="+email, UsersWrapper, resultHandler, faultHandler);
		}
		
		public function inviteToPlay(emailAddresses:Vector.<String>, resultHandler:Function=null, faultHandler:Function=null):void{
			
			var listString:String  = "";
			for each (var address:String in emailAddresses){
				listString += address+",";
			}
			postText("/user/invite", listString, resultHandler, faultHandler);
		}
	}
}