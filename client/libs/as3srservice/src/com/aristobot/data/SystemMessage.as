package com.aristobot.data
{
	[Bindable]
	public class SystemMessage
	{
		public static const CHAT_TYPE:String = "chat";
		
		public var messageKey:String;
		public var type:String;
		public var subject:String;
		public var body:String;
		public var icon:UserIcon;
		public var isPriority:Boolean;
		public var isRead:Boolean;
	}
}