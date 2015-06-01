package com.aristobot.data
{
	public class UserCredentials
	{
		public var deviceId:String;
		public var username:String;
		public var password:String;
		public var emailAddress:String;
		public var iconKey:String;
		public var pushNotificationToken:PushNotificationToken;
		
		public static function create(deviceId:String, username:String, password:String, emailAddress:String = null, 
													 iconKey:String = null, pushNotificationToken:PushNotificationToken=null):UserCredentials
		{
			var creds:UserCredentials = new UserCredentials();
			creds.deviceId = deviceId;
			creds.username = username;
			creds.password = password;
			creds.emailAddress = emailAddress;
			creds.iconKey = iconKey;
			creds.pushNotificationToken = pushNotificationToken;
			
			return creds;
		}
	}
}