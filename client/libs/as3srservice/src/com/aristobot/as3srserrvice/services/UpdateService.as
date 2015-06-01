package com.aristobot.as3srserrvice.services
{

	import com.aristobot.data.Conversation;
	import com.aristobot.data.GameData;
	import com.aristobot.data.GamesWrapper;
	import com.aristobot.data.IconsWrapper;
	
	import flash.net.URLRequestHeader;

	public class UpdateService extends RestService
	{		
		public function UpdateService(url:String, apiKey:String, accessToken:String)
		{
			super(url, apiKey, null, accessToken);
		}
		
		public function getAllGameUpdates(resultHandler:Function, faultHandler:Function = null, expired:Boolean = false, opponentUsername:String =null, lastUpdatedDateTime:Number=NaN):void
		{
			var url:String = "/games?expiredGames="+expired+"&";
			
			if (opponentUsername) url+="opponentUsername="+opponentUsername+"&";
			if (lastUpdatedDateTime) url+= "lastUpdatedDateTime="+lastUpdatedDateTime;
			
	
			get(url, GamesWrapper, resultHandler, faultHandler);
		}

		public function getGameUpdate(gameKey:String, resultHandler:Function, faultHandler:Function = null, turnIndex:int=-1):void
		{
			var url:String =  turnIndex >= 0  ?  "/games/"+gameKey+"?turnIndex="+turnIndex : "/games/"+gameKey;
			get(url, GameData, resultHandler, faultHandler);
		}
		
		public function getConversationUpdate(conversationKey:String, resultHandler:Function, faultHandler:Function = null, lastUpdatedDateTime:Number=NaN):void
		{
			var url:String =  "/messages/conversation/"+conversationKey+"?onlyIfUnread=true";
			get(url, Conversation, resultHandler, faultHandler);
		}

	}
}