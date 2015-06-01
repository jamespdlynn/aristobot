package com.aristobot.checkers.data
{
	public class CapturedIcon
	{
		public function CapturedIcon(type:String, iconSource:Class=null, numCaptured:int=1, isRed:Boolean=true)
		{
			this.type = type;
			this.iconSource = iconSource;
			this.numCaptured = numCaptured;
			this.isRed = isRed;
		}
		
		public var type:String;
		public var iconSource:Class;
		public var numCaptured:int;
		public var isRed:Boolean;
	}
}