package com.aristobot.as3srserrvice.services
{

	import com.aristobot.data.IconsWrapper;
	import com.aristobot.data.LogData;
	
	import flash.net.URLRequestHeader;

	public class LogService extends RestService
	{		
		
		public function LogService(url:String, apiKey:String, deviceId:String=null, accessToken:String=null)
		{		
			super(url, apiKey, null, accessToken);
		}
		
		public function set accessToken(value:String):void
		{
			_accessToken = value;
			createHeaders();
		}
		
		public function log(data:LogData):void
		{
			postObject("/log", data);
		}	
		
		override protected function fault(faultCode:String, message:String=""):void
		{
			trace("Log Fault "+faultCode+": "+message);
		}

	}
}