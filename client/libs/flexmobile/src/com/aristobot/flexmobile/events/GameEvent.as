package com.aristobot.flexmobile.events
{
	import com.aristobot.data.GameData;
	
	import flash.events.Event;

	public class GameEvent extends Event
	{
		public static const SELECT:String = "select";
		public static const ACCEPT:String = "accept";
		public static const DECLINE:String = "decline";
		
		public static const REFRESH:String = "refresh";
		public static const RESIGN:String = "resign";
		public static const REQUEST_DRAW:String = "requestDraw";
		public static const CANCEL:String = "cancel";
		public static const REMATCH:String = "rematch";
		public static const CHAT:String = "chat";
		
		public static const GAME_DATA_UPDATE:String = "gameDataUpdated";
		
		public var gameData:GameData;
		
		public function GameEvent(type:String, gameData:GameData=null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.gameData = gameData;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new GameEvent(type, gameData);
		}
	
	}
}