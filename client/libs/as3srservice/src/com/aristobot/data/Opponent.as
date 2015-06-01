package com.aristobot.data
{
	[Bindable]
	public class Opponent extends User
	{
		
		public var winsAgainst:int;
		
		public var lossesAgainst:int;
		
		public var tiesAgainst:int;
		
		public var validated:Boolean;
		
		public var lastPlayedAgainstDate:RoboDate;
		
		public var conversation:Conversation;
		
		public var applicationWins:int;
		
		public var applicationLosses:int;
		
		public var applicationTies:int;
		
	}
}