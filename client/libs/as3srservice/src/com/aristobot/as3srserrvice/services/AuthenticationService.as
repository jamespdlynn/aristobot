package com.aristobot.as3srserrvice.services
{

	import com.aristobot.as3srserrvice.events.ResultEvent;
	import com.aristobot.data.DeviceData;
	import com.aristobot.data.IconsWrapper;
	import com.aristobot.data.PushNotificationToken;
	import com.aristobot.data.RegistrationData;
	import com.aristobot.data.Tokens;
	import com.aristobot.data.UserCredentials;
	
	public class AuthenticationService extends RestService
	{
		protected var userCreds:UserCredentials;
		
		public function AuthenticationService(url:String, apiKey:String, versionNumber:String)
		{
			super(url, apiKey, versionNumber);
		}
		
		public function set accessToken(value:String):void
		{
			_accessToken = value;
			createHeaders();
		}
		
		public function connect(data:DeviceData, resultHandler:Function, faultHandler:Function=null):void
		{
			postObject("/authentication/connect", data, resultHandler, faultHandler);
			parseClass = RegistrationData;
		}
		
		public function login(creds:UserCredentials,resultHandler:Function, faultHandler:Function = null):void
		{
			createHeaders();
			postObject("/authentication/login", creds, resultHandler, faultHandler);
			parseClass = Tokens;
		}
		
		public function autoLogin(refreshToken:String, resultHandler:Function, faultHandler:Function = null):void
		{
			createHeaders();
			postText("/authentication/autoLogin", refreshToken, resultHandler, faultHandler);
			parseClass = Tokens;
		}
		
		public function registerUser(creds:UserCredentials, resultHandler:Function, faultHandler:Function = null):void
		{
			createHeaders();
			postObject("/authentication/registerUser", creds, resultHandler, faultHandler);
			parseClass = Tokens;
		}
		
		public function logout(resultHandler:Function = null, faultHandler:Function = null):void
		{
			postText("/authentication/logout", " ", resultHandler, faultHandler);
		}
		
		public function getDefaultIcons(resultHandler:Function, faultHandler:Function = null):void
		{
			get("/icons/default", IconsWrapper, resultHandler, faultHandler);
		}
		
		public function forgotPassword(creds:UserCredentials, resultHandler:Function, faultHandler:Function = null):void
		{
			postObject("/authentication/forgotPassword", creds, resultHandler, faultHandler);
		}
		
		public function setPushNotificationToken(token:PushNotificationToken, resultHandler:Function, faultHandler:Function = null):void
		{
			postObject("/authentication/setPushNotificationToken", token, resultHandler, faultHandler);
		}
		
		public function deletePushNotificationToken(resultHandler:Function, faultHandler:Function = null):void
		{
			postText("/authentication/deletePushNotificationToken", " ", resultHandler, faultHandler);
		}
		
		override protected function result(resultObj:Object):void
		{
			/*Instead of sending the ResultObject to the client result handler, 
			send it up to the SRModel and send no arguments to the handler*/
			if (resultObj is Tokens){
				accessToken = (resultObj as Tokens).accessToken;
				dispatchEvent(new ResultEvent(ResultEvent.AUTHENTICATED, resultObj));
			}
			
			super.result(resultObj);

		}
	}
}