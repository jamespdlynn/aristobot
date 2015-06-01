package com.aristobot.as3srserrvice.services
{
	import com.aristobot.data.ICustomGameObject;
	import com.aristobot.data.Player;

	public interface IGameService
	{
		function get isRunning():Boolean
			
		function cancel():void
			
		function getAllGames(resultHandler:Function, faultHandler:Function = null):void
			
		function getGame(gameKey:String, resultHandler:Function, faultHandler:Function = null):void
			
		function startNewGame(opponentUsername:String, customGameState:ICustomGameObject, resultHandler:Function = null, faultHandler:Function = null, retreiveModified:Boolean=true):void
	
		function startNewGameAgainstMulitple(opponentUsernames:Vector.<String>, customGameState:ICustomGameObject, resultHandler:Function = null, faultHandler:Function = null, retreiveModified:Boolean=true):void
		
		function cancelGame(gameKey:String, resultHandler:Function = null, faultHandler:Function = null):void
			
		function acceptGame(gameKey:String, resultHandler:Function = null, faultHandler:Function = null, retreiveModified:Boolean=true):void
			
		function declineGame(gameKey:String, resultHandler:Function = null, faultHandler:Function = null):void
		
		function playTurn(gameKey:String, turnIndex:int, gameMove:ICustomGameObject, newGameState:ICustomGameObject, message:String,  resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=true):void
	
		function endGame(gameKey:String, turnIndex:int, gameMove:ICustomGameObject, newGameState:ICustomGameObject, message:String, winner:Player, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=true):void

		function endGameInDraw(gameKey:String, turnIndex:int, gameMove:ICustomGameObject, newGameState:ICustomGameObject, message:String, tiedPlayers:Vector.<Player>, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=true):void
	
		function resign(gameKey:String, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=true):void

		function offerDraw(gameKey:String, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=false):void

		function acceptDraw(gameKey:String, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=true):void
		
		function declineDraw(gameKey:String, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=false):void
		
		function nudge(gameKey:String, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=false):void
			
		function getGameUpdate(gameKey:String, resultHandler:Function, faultHandler:Function = null, turnIndex:int=-1):void
		
		function getAllGameUpdates(resultHandler:Function, faultHandler:Function = null, expired:Boolean = false, opponentUsername:String =null, lastUpdatedDateTime:Number=NaN):void
		
		function getGameMoves(gameKey:String, resultHandler:Function, faultHandler:Function = null):void

		
	}
	
}