package com.aristobot.data
{
	import flash.utils.getDefinitionByName;
	
	import mx.managers.ICursorManager;
	

	[Bindable]
	public class GameData
	{
		public var gameKey:String;
		
		public var gameStatus:String;
		
		public var lastActionMessage:String;
		
		public var player:Player;
				
		public var opposingPlayers:Array = [];
		
		[Transient]
		public function get opposingPlayer():Player{
			return (opposingPlayers.length == 1) ? opposingPlayers[0] as Player : null;
		}		
		public function set opposingPlayer(value:Player):void{
			opposingPlayers[0] = value;
		}
		
		public var createdDate:RoboDate;
		
		public var lastUpdatedDate:RoboDate;

		public var currentGameState:String;
		
		public var previousGameMoves:Array = [];
		
		public var conversation:Conversation;
		
		public var turnIndex:int;
		
		public var iconUnlockInfo:IconUnlockInfo;
		
		public static function isValidGameKey(key:String):Boolean{
			return key && key.length == 32;
		}
		
	}
}