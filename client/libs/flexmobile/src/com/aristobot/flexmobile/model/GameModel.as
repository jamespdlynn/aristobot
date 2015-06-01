package com.aristobot.flexmobile.model
{
	import com.aristobot.as3srserrvice.events.FaultEvent;
	import com.aristobot.as3srserrvice.events.ResultEvent;
	import com.aristobot.as3srserrvice.model.ServiceModel;
	import com.aristobot.as3srserrvice.model.Status;
	import com.aristobot.as3srserrvice.services.GameService;
	import com.aristobot.as3srserrvice.services.IGameService;
	import com.aristobot.data.GameData;
	import com.aristobot.data.ICustomGameObject;
	import com.aristobot.data.MovesWrapper;
	import com.aristobot.data.Player;
	import com.aristobot.data.User;
	import com.aristobot.flexmobile.components.IGameBoard;
	import com.aristobot.flexmobile.components.windows.GameConclusionWindow;
	import com.aristobot.flexmobile.data.GameBoardUpdateData;
	import com.aristobot.flexmobile.events.GameEvent;
	import com.aristobot.flexmobile.views.Chat;
	import com.aristobot.flexmobile.views.FindOpponent;
	import com.aristobot.flexmobile.views.Game;
	import com.aristobot.flexmobile.views.NewGame;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	
	import spark.components.View;
	import spark.components.ViewNavigatorApplication;
	import spark.transitions.CrossFadeViewTransition;

	public class GameModel extends EventDispatcher
	{
		private static var instance:GameModel;
		
		public function GameModel(enforcer:SingletonEnforcer)
		{
			if (instance){
				throw new Error("Only one instance of Class can be instantiated");
			}
		}
		
		public static function getInstance():GameModel
		{
			if (!instance){
				instance = new GameModel(new SingletonEnforcer());
			}
			return instance;
		}
		
		private var _gameBoard:IGameBoard;
		public function get gameBoard():IGameBoard{
			return _gameBoard;
		}
		public function set gameBoard(value:IGameBoard):void{
			_gameBoard = value;
		}
		
		public static const CURRENT_GAME_DATA_CHANGED:String = "currentGameDataChanged";

		private var _currentGameData:GameData;
		[Bindable (event="currentGameDataChanged")]
		public function get currentGameData():GameData{
			return _currentGameData;
		}
		public function resetCurrentGame():void
		{
			_currentGameData = null;
			previousMoves = null;
			gameService = null;
			pollService = null;
			activated = false;
			updateTimer.reset();
			
			gameBoard.resetBoard();
			gameBoard.resetGameData();
			
			dispatchEvent(new Event(CURRENT_GAME_DATA_CHANGED));
		}
		
		protected var previousMoves:Vector.<ICustomGameObject>;
		
		private var _isReplayPlaying:Boolean;
		[Bindable]
		public function get isReplayPlaying():Boolean{
			return _isReplayPlaying;
		}
		public function set isReplayPlaying(value:Boolean):void{
			_isReplayPlaying = value;
		}
		
		protected var pieceMoving:Boolean;	
		
		
		public static const NORMAL_ACTION_STATE:String = "normal";
		
		public static const CYCLE_ACTION_STATE:String = "cycle";
		
		public static const GAME_OVER_ACTION_STATE:String = "gameOver";
		
		public static const REPLAY_ACTION_STATE:String = "replay";
		
		protected static const UPDATE_TIMER_INTERVAL:Number = 5000;
		
		protected static var initializedGameBoard:Boolean = false;
		
		protected var srm:ServiceModel = ServiceModel.getInstance();
		
		protected var vm:ViewModel = ViewModel.getInstance();
		
		protected var vc:ViewController = ViewController.getInstance();
				
		protected var message:String;
		
		protected var activated:Boolean;
		
		protected var gameService:IGameService;
		
		protected var pollService:IGameService;
		
		public static const GAME_READY_EVENT:String = "gameReady";
		protected var _gameReady:Boolean;
		[Bindable (Event='gameReady')]
		public function get gameReady():Boolean{
			return _gameReady;
		}
		
		protected var updateTimer:Timer = new Timer(UPDATE_TIMER_INTERVAL);
		
		protected var _titleLabel:String;
		[Bindable]
		public function get titleLabel():String{
			return _titleLabel;
		}
		public function set titleLabel(value:String):void{
			_titleLabel = value;
		}
		
		protected var _titleImage:Class;
		[Bindable]
		public function get titleImage():Class{
			return _titleImage;
		}
		public function set titleImage(value:Class):void{
			_titleImage = value;
		}
		
		protected var _buttonEnabled:Boolean;
		[Bindable]
		public function get buttonEnabled():Boolean{
			return _buttonEnabled;
		}
		public function set buttonEnabled(value:Boolean):void{
			_buttonEnabled = value;
		}
		
		protected var _currentMoveIndex:int;
		[Bindable]
		public function get currentMoveIndex():int{
			return _currentMoveIndex;
		}
		public function set currentMoveIndex(value:int):void{
			_currentMoveIndex = value;
		}
		
		protected var _maxMoveIndex:int;
		[Bindable]
		public function get maxMoveIndex():int{
			return _maxMoveIndex;
		}
		public function set maxMoveIndex(value:int):void{
			_maxMoveIndex = value;
		}
		
		protected var _actionState:String;
		[Bindable]
		public function get actionState():String{
			return _actionState;
		}
		public function set actionState(value:String):void{
			_actionState = value;
		}

		
		public function createNewGame(user:User, isLocal:Boolean=false):void{
			
			if (currentGameData) resetCurrentGame();
			
			gameService = srm.gameService;
			
			if (user.hasApplication){
				AlertManager.displayLoadWindow("Creating Game...");
				gameService.startNewGame(user.username, gameBoard.createInitialGameState(), createGameResultHandler, createGameFaultHandler);
			}
			else{
				AlertManager.displayConfirmWindow(user.username + " does not appear to own "+vm.applicationName+". Would you like to send an email inviting them to download the app?", 
					["OK", "No Thanks"], function(event:Event):void{inviteToPlay(user.username)});
			}

		}
		
		protected function inviteToPlay(username:String):void{
			var invitees:Vector.<String> =  new Vector.<String>();
			invitees.push(username);
			srm.userService.inviteToPlay(invitees, function(event:ResultEvent):void{
				AlertManager.closeLoadWindow();
				AlertManager.displayNotificaitonWindow("Invitation sent!");
			});
			AlertManager.displayLoadWindow("Sending Invite...");
		}
		
		public function init(gameData:GameData, executeLastMove:Boolean=true):void
		{
			if (!srm.isAuthenticated() || !vc.dataLoaded){
				vc.autologin();
				return;
			}
			
			try
			{
				gameService = srm.gameService;
				pollService = srm.gameService;
				
				var redrawBoard:Boolean = !_currentGameData || _currentGameData.gameKey !=  gameData.gameKey;
				vm.updateGame(gameData);
				
				_gameReady = false;
				_currentGameData = gameData;
				buttonEnabled = false;

				if (currentGameData.gameStatus != Status.GAME_FINISHED)
				{
					if (currentGameData.player.isTurn){
						titleLabel = "Your Turn";
						titleImage = ImageManager.GoIcon;
					}
					else{
						titleLabel = (currentGameData.gameStatus == Status.GAME_INITIALIZING) ? "Awaiting Reply" : "Awaiting Turn";
						titleImage = ImageManager.AwaitingIcon;
					}
				}
				else if (currentGameData.player.playerStatus == Status.PLAYER_WON) {
					titleLabel= "Victory!";
					titleImage = ImageManager.VictoryIcon;
				}
				else if (currentGameData.player.playerStatus == Status.PLAYER_LOST){
					titleLabel = "Defeat!";
					titleImage = ImageManager.DefeatIcon;
				}
				else{
					titleLabel = "Draw!";
					titleImage = ImageManager.DrawIcon;
				}
				
				actionState = (currentGameData.gameStatus == Status.GAME_FINISHED) ? GAME_OVER_ACTION_STATE : NORMAL_ACTION_STATE;
				
				previousMoves = srm.parseCustomGameObjects(gameData.previousGameMoves);
				maxMoveIndex = (previousMoves) ? previousMoves.length : 0;
				currentMoveIndex = maxMoveIndex;

				var previousMove:ICustomGameObject = (executeLastMove && maxMoveIndex > 0) ? previousMoves[maxMoveIndex-1] : null;
				gameBoard.initializeGame(srm.parseCustomGameObject(gameData.currentGameState), currentGameData.player, previousMove, redrawBoard);
				
				if (activated){
					runGame();
				}
				else{
					var activeView:View = vc.navigator.activeView;
					if (activeView is Game || activeView is NewGame){
						vc.navigator.popView();
					}else if (activeView is FindOpponent){
						vc.navigator.popView();
						vc.navigator.popView();
					}
					vc.navigator.pushView(Game);
				}
				
				dispatchEvent(new Event(CURRENT_GAME_DATA_CHANGED));
			}
			catch (e:Error){
				AlertManager.displayNotificaitonWindow("Error Parsing Game Data", vc.autologin);
				vc.log("Error parsing game data :"+e.getStackTrace());
			}
			
		}
		
		public function cancelCalls():void
		{
			if (gameService){
				gameService.cancel();
			}
			
			if (pollService){
				pollService.cancel();
			}
		}
		
		public function initializeGameBoard(x:int, y:int, width:Number, height:Number):void
		{
			if (initializedGameBoard) return;
			
			if (!gameBoard) throw new Error("Game board never set in View Model");
			
			gameBoard.x = x;
			gameBoard.y = y;
			gameBoard.width = width;
			gameBoard.height = height;
			
			initializedGameBoard = true; 
		}
		
		public function activate():void
		{	
			if (!activated && currentGameData)
			{	
				activated = true;	
				updateTimer.addEventListener(TimerEvent.TIMER, pollForUpdate, false, 0, true);
				
				if (!srm.isAuthenticated() || !vc.dataLoaded){
					vc.autologin();
				}
				else
				{
					if (!gameReady){
						runGame();
					}
					else if (currentGameData.gameStatus != Status.GAME_FINISHED && !gameService.isRunning){
						init(currentGameData, false);
						ActionContentManager.startLoading();
						pollForUpdate();
					}	
				}
							
			}
		}
		
		public function deactivate():void
		{
			if (activated)
			{
				activated = false;
				
				updateTimer.reset();
				updateTimer.removeEventListener(TimerEvent.TIMER, pollForUpdate);
				
				
				if (isReplayPlaying){
					pauseReplay();
				}
				
				(FlexGlobals.topLevelApplication as ViewNavigatorApplication).viewMenuOpen = false;
			}
		}		
		
		protected function runGame():void
		{
			try{
				if (currentGameData.player.drawRequested && currentGameData.gameStatus == Status.GAME_RUNNING){
					AlertManager.displayConfirmWindow(currentGameData.opposingPlayer.username + " is offering a draw.", ["Accept","Decline"], acceptDrawHandler, declineDrawHandler);
				}
				else{
					gameBoard.run();
					buttonEnabled = true;
					_gameReady = true;
					startTimer();
					
					dispatchEvent(new Event(GAME_READY_EVENT));
				}
			}
			catch (e:Error){
				vc.log("Error Activating Game "+e.getStackTrace());
				AlertManager.displayNotificaitonWindow("Error Activating Game", vc.autologin);
			}
			
		}
		
		protected function startTimer():void
		{
			if (!pollService) return;
			
			updateTimer.reset();
			
			if (currentGameData && currentGameData.gameStatus != Status.GAME_FINISHED && (!currentGameData.player.isTurn || currentGameData.opposingPlayer.drawRequested)){
				updateTimer.start();
			}
		}
		
		public function revert(event:Event):void
		{
			gameBoard.revertTurn();
		}
		
		public function play(event:Event):void
		{
			if (!srm.isAuthenticated() || !vc.dataLoaded){
				vc.autologin();
				return;
			}
			
			if (gameService.isRunning || !currentGameData.player.isTurn || !gameBoard.playEnabled){
				vc.log("Play called incorrectly");
				init(currentGameData, false);
				return;
			}
			
			try
			{
				updateTimer.reset();
				var updateData:GameBoardUpdateData = gameBoard.executeTurn();
				
				switch (updateData.outcome)
				{
					case (Status.PLAYER_PLAYING):	
						gameService.playTurn(currentGameData.gameKey, currentGameData.turnIndex, updateData.gameMove, updateData.newGameState, updateData.turnMessage, gameUpdateResult, gameUpdateFault);
						break;
					
					case (Status.PLAYER_WON):
						gameService.endGame(currentGameData.gameKey, currentGameData.turnIndex, updateData.gameMove, updateData.newGameState, updateData.turnMessage, currentGameData.player, gameUpdateResult, gameUpdateFault);
						break;
					
					case (Status.PLAYER_LOST):
						gameService.endGame(currentGameData.gameKey, currentGameData.turnIndex, updateData.gameMove, updateData.newGameState, updateData.turnMessage, currentGameData.opposingPlayer, gameUpdateResult, gameUpdateFault);
						break;
					
					case (Status.PLAYER_TIED):
						var players:Vector.<Player> = new Vector.<Player>(2);
						players[0] = currentGameData.player;
						players[1] = currentGameData.opposingPlayer;
						
						gameService.endGameInDraw(currentGameData.gameKey, currentGameData.turnIndex, updateData.gameMove, updateData.newGameState, updateData.turnMessage, players, gameUpdateResult, gameUpdateFault);
						break;
					
					default:
						throw new Error("Gameboard must return a valid outcome status");
						break;
				}
				
				buttonEnabled = false;
				AlertManager.displayLoadWindow("Submitting Turn...");

			}
			catch (e:Error){
				vc.log("Error Submitting Turn: "+e.getStackTrace());
				AlertManager.displayNotificaitonWindow("Error Submitting Turn", vc.autologin);
			}
		}
		
	
		
		protected function gameUpdateResult(event:ResultEvent):void
		{			
			AlertManager.closeLoadWindow();
			ActionContentManager.stopLoading();
			
			var newGameData:GameData = event.resultObj as GameData;
			
			if (newGameData && currentGameData && newGameData.gameKey == currentGameData.gameKey && newGameData.turnIndex > currentGameData.turnIndex)
			{
				if (newGameData.gameStatus == Status.GAME_FINISHED){
					displayGameResult(newGameData);
				}
				else{
					SoundManager.playSound(SoundManager.ALERT);
				}
				
				init(newGameData, false);
			}			
		}

		protected function pollForUpdate(event:TimerEvent=null):void
		{
			if (!srm.isAuthenticated() || !vc.dataLoaded){
				vc.autologin();
				return;
			}
			
			if (pollService && !gameService.isRunning && !pollService.isRunning){
				updateTimer.reset();
				pollService.getGameUpdate(currentGameData.gameKey, pollUpdateResult, gameUpdateFault, currentGameData.turnIndex);
			}
			else{
				startTimer();
			}
		}
		
		protected function pollUpdateResult(event:ResultEvent):void
		{			
			ActionContentManager.stopLoading();
			
			if (!activated) return;
						
			var newGameData:GameData = event.resultObj as GameData;
			
			if (newGameData && currentGameData && newGameData.gameKey == currentGameData.gameKey && newGameData.turnIndex > currentGameData.turnIndex)
			{				
				if (newGameData.gameStatus == Status.GAME_FINISHED){
					displayGameResult(newGameData);
				}
				else{
					SoundManager.playSound(SoundManager.ALERT);
				}
				
				init(newGameData, true);
			}
			else{
				startTimer();
			}
		}
		
		protected function gameUpdateFault(event:FaultEvent):void
		{
			updateTimer.reset();
			ActionContentManager.stopLoading();
			AlertManager.closeLoadWindow();
			
			
			srm.defaultFaultHandler(event);
		}
		
		public function cancelGame(event:Event=null):void
		{
			buttonEnabled = false;
			gameService.cancelGame(currentGameData.gameKey, cancelResult, resignFaultHandler);
			AlertManager.displayLoadWindow("Canceling...");
		}
		
		protected function cancelResult(event:ResultEvent):void
		{
			AlertManager.closeLoadWindow();
			vm.removeGame(currentGameData);
			vc.navigator.popView();
		}
		
		public function resign(event:Event=null):void
		{
			buttonEnabled = false;
			gameService.resign(currentGameData.gameKey, gameUpdateResult, resignFaultHandler);
			AlertManager.displayLoadWindow("Resigning...");
		}
		
		public function requestDraw(event:Event=null):void
		{
			buttonEnabled = true;			
			gameService.offerDraw(currentGameData.gameKey, drawOfferedResultHandler, resignFaultHandler, true);
			AlertManager.displayLoadWindow("Offering Draw...");
		}
		
		protected function acceptDrawHandler(event:Event):void
		{
			buttonEnabled = false;
			gameService.acceptDraw(currentGameData.gameKey, gameUpdateResult, resignFaultHandler);
			AlertManager.displayLoadWindow("Accepting Draw...");
		}
		
		protected function declineDrawHandler(event:Event):void
		{
			currentGameData.player.drawRequested = false; 
			ActionContentManager.startLoading();
			gameService.declineDraw(currentGameData.gameKey, declineDrawResult, resignFaultHandler)
			runGame();
		}
		
		protected function drawOfferedResultHandler(event:ResultEvent):void
		{
			AlertManager.closeLoadWindow();
			
			AlertManager.displayNotificaitonWindow("Your opponent has been notified of your draw offer. Until they choose to accept it, please continue to play out this game.");
			init(event.resultObj as GameData, false);
		}
		
		protected function declineDrawResult(event:Event=null):void
		{
			ActionContentManager.stopLoading();
		}
		
		protected function resignFaultHandler(event:FaultEvent):void
		{
			AlertManager.closeLoadWindow();
			ActionContentManager.stopLoading();
			
			switch (event.faultCode)
			{
				case FaultEvent.CANNOT_RESIGN_AT_THIS_TIME:
				case FaultEvent.CANNOT_REQUEST_DRAW_AT_THIS_TIME:
					AlertManager.displayNotificaitonWindow(event.message);
					break;
				
				default:
					srm.defaultFaultHandler(event);
					break;
			}
			
		}
		
		public function rematch(event:Event=null):void
		{			
			if (!activated || !currentGameData) return;
			
			createNewGame(currentGameData.opposingPlayer);
		}
		
		public function chat(event:Event=null):void
		{
			if (!activated || !currentGameData) return;
			
			vc.navigator.pushView(Chat, currentGameData.conversation, null, new CrossFadeViewTransition());
		}
		
		public function backClick():void
		{
			if (currentGameData && previousMoves && currentMoveIndex > 0)
			{
				currentMoveIndex--;
				gameBoard.cyclePreviousMove(previousMoves[currentMoveIndex] as ICustomGameObject);
				actionState = CYCLE_ACTION_STATE;
			}
			
		}
		
		public function forwardClick():void
		{
			
			if (currentGameData && previousMoves)
			{
				
				if (currentMoveIndex < maxMoveIndex - 1){
					gameBoard.cycleNextMove(previousMoves[currentMoveIndex] as ICustomGameObject);
					currentMoveIndex++;
				}
				else{
					gameBoard.initializeGame(srm.parseCustomGameObject(currentGameData.currentGameState), currentGameData.player);
					gameBoard.run();
					
					currentMoveIndex = maxMoveIndex;
					actionState = NORMAL_ACTION_STATE;
				}

			}
		}
		
		public function displayGameResult(gameData:GameData, rematchEnabled:Boolean = false, rematchHandler:Function=null):void
		{
			var window:GameConclusionWindow = new GameConclusionWindow();
			window.gameData = gameData;
			window.rematchEnabled = rematchEnabled;
			
			if (rematchHandler != null){
				window.addEventListener(GameEvent.REMATCH, rematchHandler,false,0,true);
			}
			
			AlertManager.displayCustomWindow(window);
			
			switch (gameData.player.playerStatus)
			{
				case Status.PLAYER_WON:
					SoundManager.playSound(SoundManager.VICTORY);
					break;
				
				case Status.PLAYER_LOST:
					SoundManager.playSound(SoundManager.DEFEAT);
					break;
				
				case Status.PLAYER_TIED:
					SoundManager.playSound(SoundManager.DRAW);
					break;
			}
			
			if (srm.isAuthenticated() && vc.dataLoaded){
				srm.userService.getCurrentUser(vm.loadCurrentUserResult);
				srm.opponentService.getAllOpponents(vm.loadOpponentsResult);
			}
			
			
			
		}
		
		public function loadReplay():void
		{
			if (!activated || !currentGameData) return;
			
			gameService.getGameMoves(currentGameData.gameKey, gameMovesResult);
			AlertManager.displayLoadWindow("Loading Replay...");
		}
		
		public function nudge():void
		{
			if (!activated || !currentGameData) return;
			
			
			gameService.nudge(currentGameData.gameKey, declineDrawResult);
			ActionContentManager.startLoading();
		}
		
		protected function gameMovesResult(event:ResultEvent):void
		{
			AlertManager.closeLoadWindow();
			
			try{
				
				previousMoves = srm.parseCustomGameObjects((event.resultObj as MovesWrapper).gameMoves); 
				maxMoveIndex = (previousMoves) ? previousMoves.length : 0;
				
				actionState = REPLAY_ACTION_STATE;
				titleImage = ImageManager.ReplayIcon;
				titleLabel = "Replay";
				cycleToBeginning();
				startReplay();
			}
			catch (e:Error){
				AlertManager.displayNotificaitonWindow("Error Parsing Game Moves");
				vc.log("Error parsing game moves :"+e.getStackTrace());
				init(currentGameData);
			}
			
		}
		
		public function startReplay():void
		{
			if (!activated) return;
			
			isReplayPlaying = true;
			playNextMove();
		}
	
		protected function playNextMove():void
		{
			pieceMoving = false;
			
			setTimeout(function ():void{
				if (activated && isReplayPlaying && currentMoveIndex < maxMoveIndex){
					pieceMoving = true;
					gameBoard.playNextMove(previousMoves[currentMoveIndex], playNextMove);
					currentMoveIndex++;
				}
				else{
					isReplayPlaying = false;
				}
			},300);
		}
			
			
		public function pauseReplay():void
		{
			isReplayPlaying = false;
			if (pieceMoving){
				gameBoard.cycleNextMove(previousMoves[currentMoveIndex-1] as ICustomGameObject);
			}
		}
		
		public function cyclePrevious():void
		{
			if (isReplayPlaying){
				pauseReplay();
			}
			
			isReplayPlaying = false;
			if (currentMoveIndex > 0){
				currentMoveIndex--;
				gameBoard.cyclePreviousMove(previousMoves[currentMoveIndex] as ICustomGameObject);
			}
		}
		
		public function cycleNext():void
		{
			if (isReplayPlaying){
				pauseReplay();
			}
			
			isReplayPlaying = false;
			if (currentMoveIndex < maxMoveIndex){
				gameBoard.cycleNextMove(previousMoves[currentMoveIndex] as ICustomGameObject);
				currentMoveIndex++;
			}
		}
		
		public function cycleToBeginning():void
		{
			isReplayPlaying = false;
			currentMoveIndex = 0;
			gameBoard.initializeGame(gameBoard.createInitialGameState(), currentGameData.player, null, false);
		}
		
		public function cycleToEnd():void
		{
			isReplayPlaying = false;
			currentMoveIndex = maxMoveIndex;
			gameBoard.initializeGame(srm.parseCustomGameObject(currentGameData.currentGameState), currentGameData.player, null, false);
		}
		
		protected function createGameResultHandler(event:ResultEvent):void{
			AlertManager.closeLoadWindow();
			init(event.resultObj as GameData);
		}
		
		protected function createGameFaultHandler(event:FaultEvent):void
		{
			AlertManager.closeLoadWindow();
			ActionContentManager.stopLoading();
			
			switch(event.faultCode)
			{
				case FaultEvent.TOO_MANY_GAMES:
					AlertManager.displayNotificaitonWindow("You have reached the maximum allowable number of active games.");
					break;
				
				case FaultEvent.TOO_MANY_GAMES_PER_OPPONENT:
					AlertManager.displayNotificaitonWindow("You already have an active game with this opponent.");
					break;
				
				case FaultEvent.OPPONENT_TOO_MANY_GAMES:
					AlertManager.displayNotificaitonWindow("Your opponent has reached the maximum allowable number of active games.");
					break;
				
				default:
					srm.defaultFaultHandler(event);
					break;
			}
			
		}
		
		
		
	}

}

class SingletonEnforcer{}