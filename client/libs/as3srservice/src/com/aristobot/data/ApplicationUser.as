package com.aristobot.data
{

	[Bindable]
	public class ApplicationUser extends User
	{		
		public var emailAddress:String;
		public var icons:Array;
		public var messages:Array;
		public var hasUnreadMessages:Boolean;
		public var hasUnreadPriorityMessages:Boolean;
		
		public var wins:int;
		public var losses:int
		public var ties:int;
		
		public var rating:int;
		
		public var isDebug:Boolean;
	}
}