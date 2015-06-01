package com.aristobot.as3srserrvice.services
{
	
	import com.aristobot.data.GameData;
	import com.aristobot.data.GameUpdate;
	import com.aristobot.data.GamesWrapper;
	import com.aristobot.data.ICustomGameObject;
	import com.aristobot.data.MovesWrapper;
	import com.aristobot.data.Player;
	
	public class GameService extends RestService implements IGameService
	{
		
		protected var retreiveModified:Boolean;
		
		public function GameService(url:String, apiKey:String, accessToken:String)
		{
			super(url, apiKey, null, accessToken);
		}

		public function getAllGames(resultHandler:Function, faultHandler:Function = null):void
		{
			get("/games", GamesWrapper, resultHandler, faultHandler);
		}
		
		public function getGame(gameKey:String, resultHandler:Function, faultHandler:Function = null):void
		{
			get("/games/"+gameKey, GameData, resultHandler, faultHandler);
		}
		
		
		public function startNewGame(opponentUsername:String, customGameState:ICustomGameObject, resultHandler:Function = null, faultHandler:Function = null, retreiveModified:Boolean=true):void
		{
			this.retreiveModified = retreiveModified;	
			
			var gameUpdate:GameUpdate = new GameUpdate();
			gameUpdate.invitees = [opponentUsername];
			gameUpdate.newGameState = customGameState.marshall().toXMLString();
			
			postObject("/games/add", gameUpdate, resultHandler, faultHandler);
		}
		
		public function startNewGameAgainstMulitple(opponentUsernames:Vector.<String>, customGameState:ICustomGameObject, resultHandler:Function = null, faultHandler:Function = null, retreiveModified:Boolean=true):void
		{
			this.retreiveModified = retreiveModified;	
			
			var gameUpdate:GameUpdate = new GameUpdate();
			
			gameUpdate.invitees = new Array();
			for each (var username:String in opponentUsernames){
				gameUpdate.invitees.push(username);
			}
			
			gameUpdate.newGameState = customGameState.marshall().toXMLString();
			
			postObject("/games/add", gameUpdate, resultHandler, faultHandler);
		}
		
		public function cancelGame(gameKey:String, resultHandler:Function = null, faultHandler:Function = null):void
		{
			postText("/games/cancel", gameKey, resultHandler, faultHandler);
		}
		
		public function acceptGame(gameKey:String, resultHandler:Function = null, faultHandler:Function = null, retreiveModified:Boolean=true):void
		{
			this.retreiveModified = retreiveModified;	
			postText("/games/accept", gameKey, resultHandler, faultHandler);
		}
		
		public function declineGame(gameKey:String, resultHandler:Function = null, faultHandler:Function = null):void
		{
			postText("/games/decline", gameKey, resultHandler, faultHandler);
		}
		
		public function playTurn(gameKey:String, turnIndex:int, gameMove:ICustomGameObject, newGameState:ICustomGameObject, message:String,  resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=true):void
		{
			retreiveModified = rm;	
			
			var gameUpdate:GameUpdate = new GameUpdate();
			gameUpdate.gameKey = gameKey; 
			gameUpdate.turnKey = getTurnKey(gameKey, turnIndex);
			gameUpdate.gameMove = gameMove.marshall().toXMLString();
			gameUpdate.newGameState = newGameState.marshall().toXMLString();
			gameUpdate.customMessage = message;
			gameUpdate.gameEnded = false;
									
			postObject("/games/update", gameUpdate, resultHandler, faultHandler);
			
		}
		
		public function endGame(gameKey:String, turnIndex:int, gameMove:ICustomGameObject, newGameState:ICustomGameObject, message:String, winner:Player, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=true):void
		{
			retreiveModified = rm;	
			
			var gameUpdate:GameUpdate = new GameUpdate();
			gameUpdate.gameKey = gameKey; 
			gameUpdate.turnKey = getTurnKey(gameKey, turnIndex);
			gameUpdate.gameMove = gameMove.marshall().toXMLString();
			gameUpdate.newGameState = newGameState.marshall().toXMLString();
			gameUpdate.customMessage = message;
			gameUpdate.gameEnded = true;
			gameUpdate.winners = [winner.username];
			
			postObject("/games/update", gameUpdate, resultHandler, faultHandler);
		}
		
		public function endGameInDraw(gameKey:String, turnIndex:int, gameMove:ICustomGameObject, newGameState:ICustomGameObject, message:String, tiedPlayers:Vector.<Player>, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=true):void
		{
			retreiveModified = rm;	
			
			var gameUpdate:GameUpdate = new GameUpdate();
			gameUpdate.gameKey = gameKey; 
			gameUpdate.turnKey = getTurnKey(gameKey, turnIndex);
			gameUpdate.gameMove = gameMove.marshall().toXMLString();
			gameUpdate.newGameState = newGameState.marshall().toXMLString();
			gameUpdate.customMessage = message;
			gameUpdate.gameEnded = true;
			gameUpdate.winners = new Array();
			for each (var player:Player in tiedPlayers){
				gameUpdate.winners.push(player.username);
			}
			
			postObject("/games/update", gameUpdate, resultHandler, faultHandler);
			
		}
		
		public function resign(gameKey:String, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=true):void
		{
			retreiveModified = rm;	
			postText("/games/resign", gameKey, resultHandler, faultHandler);
		}
		
		public function offerDraw(gameKey:String, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=false):void
		{
			retreiveModified = rm;	
			postText("/games/requestDraw", gameKey, resultHandler, faultHandler);
		}
		
		public function acceptDraw(gameKey:String, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=true):void
		{
			retreiveModified = rm;	
			postText("/games/acceptDraw", gameKey, resultHandler, faultHandler);
		}
		
		public function declineDraw(gameKey:String, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=false):void
		{
			retreiveModified = rm;	
			postText("/games/declineDraw", gameKey, resultHandler, faultHandler);
		}
		
		public function nudge(gameKey:String, resultHandler:Function = null, faultHandler:Function = null, rm:Boolean=false):void
		{
			retreiveModified = rm;	
			postText("/games/nudge", gameKey, resultHandler, faultHandler);
		}
		
		public function getGameUpdate(gameKey:String, resultHandler:Function, faultHandler:Function = null, turnIndex:int=-1):void
		{
			var url:String =  turnIndex >= 0  ?  "/games/"+gameKey+"?turnIndex="+turnIndex : "/games/"+gameKey;
			get(url, GameData, resultHandler, faultHandler);
		}
		
		public function getAllGameUpdates(resultHandler:Function, faultHandler:Function = null, expired:Boolean = false, opponentUsername:String =null, lastUpdatedDateTime:Number=NaN):void
		{
			var url:String = "/games?expiredGames="+expired+"&";
			
			if (opponentUsername) url+="opponentUsername="+opponentUsername+"&";
			if (lastUpdatedDateTime) url+= "lastUpdatedDateTime="+lastUpdatedDateTime;
			
			
			get(url, GamesWrapper, resultHandler, faultHandler);
		}
		
		public function getGameMoves(gameKey:String, resultHandler:Function, faultHandler:Function = null):void
		{
			get("/games/moves/"+gameKey, MovesWrapper, resultHandler, faultHandler);
		}
		
	
		override protected function result(resultObj:Object):void
		{
			if (resultObj is String && retreiveModified){
				retreiveModified = false;
				getGame(resultObj as String, resultHandler, faultHandler);
			}
			else{
				super.result(resultObj);
			}
		}
		
		protected function getTurnKey(gameKey:String, turnIndex:int):String
		{
			return (gameKey.charCodeAt(turnIndex%gameKey.length) +(turnIndex * 599)).toString(16);
		}

		
	}
}