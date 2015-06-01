package com.aristobot.flexmobile.data
{
	import com.aristobot.data.UserIcon;

	[Bindable]
	public class RegistrationCredentials
	{
		public var username:String = "";
		public var password:String = "";
		public var confirmPassword:String = "";
		public var emailAddress:String = "";
		public var icon:UserIcon;
		
	}
}