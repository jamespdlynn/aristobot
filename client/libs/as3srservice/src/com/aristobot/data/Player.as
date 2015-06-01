package com.aristobot.data
{
	[Bindable]
	public class Player extends User
	{
		public var playerStatus:String;
		
		public var isTurn:Boolean;
		
		public var score:int;
		
		public var drawRequested:Boolean;

		public var playerNumber:int;
		public function get isFirstPlayer():Boolean{
			return playerNumber == 1;
		}
	}
}