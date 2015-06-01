package com.aristobot.chess.data
{
	[Bindable]
	public class CapturedIconVO
	{
		public function CapturedIconVO(type:String, iconSource:Class=null, numCaptured:int=1, isWhite:Boolean=true)
		{
			this.type = type;
			this.iconSource = iconSource;
			this.numCaptured = numCaptured;
			this.isWhite = isWhite;
		}
		
		public var type:String;
		public var iconSource:Class;
		public var numCaptured:int;
		public var isWhite:Boolean;
	}
}