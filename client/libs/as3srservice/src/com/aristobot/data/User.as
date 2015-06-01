package com.aristobot.data
{
	import flash.display.BitmapData;

	[Bindable]
	public class User
	{
		public var username:String;
		
		public var icon:UserIcon;
		
		public var level:int;
		
		public var unlockPercent:Number;
		
		public var hasApplication:Boolean;
	}
}