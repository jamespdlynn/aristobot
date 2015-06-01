package com.aristobot.flexmobile.model
{
	import com.aristobot.as3srserrvice.events.ResultEvent;
	import com.aristobot.as3srserrvice.model.Status;
	import com.aristobot.data.ApplicationData;
	import com.aristobot.data.ApplicationUser;
	import com.aristobot.data.GameData;
	import com.aristobot.data.GamesWrapper;
	import com.aristobot.data.Opponent;
	import com.aristobot.data.OpponentsWrapper;
	import com.aristobot.data.PushNotificationToken;
	import com.aristobot.data.SystemMessage;
	import com.aristobot.data.UserIcon;
	import com.aristobot.flexmobile.data.IconListData;
	import com.aristobot.flexmobile.events.GameEvent;
	import com.aristobot.flexmobile.util.DateUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.formatters.DateFormatter;
	
	import spark.core.ContentCache;
	import spark.managers.PersistenceManager;

	public class ViewModel extends EventDispatcher
	{
		private static var instance:ViewModel;
		
		
		public static const OPPONENTS_CHANGED:String = "opponentsChanged";
		public static const GAMES_CHANGED:String = "gamesChanged";
		public static const CURRENT_USER_CHANGED:String = "currentUserChanged";
		public static const ICONS_CHANGED:String = "iconsChanged";
		public static const ALL_DATA_LOADED:String = "allDataLoaded";
		public static const PROFILE_OPTIONS_CHANGED:String = "profileOptionsChanged";
		public static const CURRENT_OPPONENT_CHANGED:String = "currentOpponentChanged";
		public static const LEADER_BOARD_DATA_CHANGED:String = "leaderBoardDataChanged";
		
		public static const RATE_DATE_INTERVAL:Number = 7 * 24 * 60 * 60 * 1000;
		
		private var persistenceManager:PersistenceManager;
						
		private var _debugEnabled:Boolean;
		public function get debugEnabled():Boolean{
			return _debugEnabled;
		}
		public function set debugEnabled(value:Boolean):void{
			_debugEnabled = value;
		}
		
		private var _useTestServices:Boolean;
		public function get useTestServices():Boolean{
			return _useTestServices;
		}
		public function set useTestServices(value:Boolean):void{
			_useTestServices = value;
			persistenceManager.setProperty("useTestServices",value);			
		}

		private var _applicationDPI:Number;
		public function get applicationDPI():Number{
			return _applicationDPI;
		}
		public function set applicationDPI(value:Number):void{
			_applicationDPI = value;
		}
		
		private var _deviceId:String;
		public function get deviceId():String{
			return _deviceId;
		}
		public function set deviceId(value:String):void{
			_deviceId = value;
			persistenceManager.setProperty("deviceId",value);
			persistenceManager.save();
		}
		
		private var _deviceType:String;
		public function get deviceType():String{
			return _deviceType;
		}
		public function set deviceType(value:String):void{
			_deviceType = value;
		}
		
		private var _applicationData:ApplicationData;
		public function get applicationData():ApplicationData{
			return _applicationData;
		}
		public function set applicationData(value:ApplicationData):void{
			_applicationData = value;
		}
		
		private var _currentVersion:String;
		public function get currentVersion():String{
			return _currentVersion;
		}
		public function set currentVersion(value:String):void{
			_currentVersion = value;
		}
		
		private var _applicationName:String;
		public function get applicationName():String{
			return _applicationName;
		}
		public function set applicationName(value:String):void{
			_applicationName = value;
		}
		
		private var _lastUpdatedUser:Number;
		public function get lastUpdatedUser():Number{
			return _lastUpdatedUser;
		}
		public function set lastUpdatedUser(value:Number):void{
			_lastUpdatedUser = value;
		}
		
		
		private var _lastSeenVersion:String;
		public function get lastSeenVersion():String{
			return _lastSeenVersion;
		}
		public function set lastSeenVersion(value:String):void{
			_lastSeenVersion = value;
			persistenceManager.setProperty("lastSeenVersion",value);
			persistenceManager.save();
		}
		
		private var _lastIconCount:int;
		public function get lastIconCount():int{
			return _lastIconCount;
		}
		public function set lastIconCount(value:int):void{
			_lastIconCount = value;
			persistenceManager.setProperty("lastIconCount",value);
			persistenceManager.save();
		}
		
		private var _refreshToken:String;
		public function get refreshToken():String{
			return _refreshToken;
		}
		public function set refreshToken(value:String):void{
			_refreshToken = value;
			persistenceManager.setProperty("refreshToken",value);
			persistenceManager.save();
		}
		
		private var _pushNotificationsEnabled:Boolean;
		public function get pushNotificationsEnabled():Boolean{
			return _pushNotificationsEnabled;
		}
		public function set pushNotificationsEnabled(value:Boolean):void{
			_pushNotificationsEnabled = value;
			persistenceManager.setProperty("pushNotificationsEnabled",value);
			persistenceManager.save();
		}
		
		private var _pushNotificationToken:PushNotificationToken;
		public function get pushNotificationToken():PushNotificationToken{
			return _pushNotificationToken;
		}
		public function set pushNotificationToken(value:PushNotificationToken):void{
			_pushNotificationToken = value;
			persistenceManager.setProperty("pushNotificationToken",value);
			persistenceManager.save();
		}
		
		
		private var _soundEnabled:Boolean = true;
		public function get soundEnabled():Boolean{
			return _soundEnabled;
		}
		public function set soundEnabled(value:Boolean):void{
			_soundEnabled = value;
			persistenceManager.setProperty("soundEnabled",value);
			persistenceManager.save();
			
			dispatchEvent(new Event(PROFILE_OPTIONS_CHANGED));
		}
		
		private var _nextRateDate:Number;
		public function get nextRateDate():Number{
			return _nextRateDate;
		}
		public function set nextRateDate(value:Number):void{
			_nextRateDate = value;
			persistenceManager.setProperty("nextRateDate",value);
			persistenceManager.save();
		}
		
		private var _profileOptions:ArrayList;
		[Bindable (event="profileOptionsChanged")]
		public function get profileOptions():ArrayList{
			return _profileOptions;
		}
				
		private var _opponentList:ArrayList;
		[Bindable (event="opponentsChanged")]
		public function get opponentList():ArrayList{
			return _opponentList;
		}
				
		private var _gameList:ArrayList;
		[Bindable (event="gamesChanged")]
		public function get gameList():ArrayList{
			return _gameList;
		}
			
		private var _currentUser:ApplicationUser;
		[Bindable (event="currentUserChanged")]
		public function get currentUser():ApplicationUser{
			return _currentUser;
		}
		
		private var _messageList:ArrayList;
		[Bindable (event="currentUserChanged")]
		public function get messageList():ArrayList{
			return _messageList;
		}
		
		private var _icons:ArrayList;
		[Bindable (event="iconsChanged")]
		public function get icons():ArrayList{
			return _icons;
		}
		
		private var _currentOpponent:Opponent;
		[Bindable (event="currentOpponentChanged")]
		public function get currentOpponent():Opponent{
			return _currentOpponent;
		}
	
		
		private var _expiredOpponentGameList:ArrayList;
		[Bindable (event="gamesChanged")]
		public function get expiredOpponentGameList():ArrayList{
			return _expiredOpponentGameList;
		}
		
		private var _iconCache:ContentCache;
		[Bindable (event="iconsChanged")]
		public function get iconCache():ContentCache{
			return _iconCache;
		}
		
		private var _appIcon:Class;
		public function get appIcon():Class{
			return _appIcon;
		}
		public function set appIcon(value:Class):void{
			_appIcon = value;
			gamesOption.icon = _appIcon;
			opponentGamesOption.icon = _appIcon;
		}
		
		[Bindable (event='currentUserChanged')]
		public function get userIcon():UserIcon{
			if (currentUser){
				return currentUser.icon;
			}
			return null;
		}

		public function set userIcon(icon:UserIcon):void{
			
			if (!_currentUser) return;
			
			if (icon.iconURL){
				iconCache.load(icon.iconURL,"userIcon");
			}
			
			if (_currentUser.icon){
				icon.badgeURL = _currentUser.icon.badgeURL;
				icon.rank = _currentUser.icon.rank;
			}
			
			_currentUser.icon = icon;
			iconsOption.icon = icon.iconURL;
			
			dispatchEvent(new Event(CURRENT_USER_CHANGED));
		}
		
		private var _leaderBoardData:ArrayList;
		[Bindable (event='leaderBoardDataChanged')]
		public function get leaderBoardData():ArrayList{
			return _leaderBoardData;
		}
	
		public var gamesOption:IconListData = new IconListData("*gamesOption*", "Games");
		public var opponentsOption:IconListData = new IconListData("*opponentsOption*", "Opponents", ImageManager.OpponentsIcon);
		public var messagesOption:IconListData = new IconListData("*messagesOption*", "Messages", ImageManager.MessagesIcon);
		public var iconsOption:IconListData = new IconListData("*iconsOption*", "My Icons");
		public var inviteAFriendOption:IconListData = new IconListData("*inviteOption*", "Invite a Friend", ImageManager.InviteIcon);
		public var leaderboardOption:IconListData = new IconListData("*leaderboardOption*", "Leaderboard", ImageManager.VictoryIcon);
		
		public var opponentGamesOption:IconListData = new IconListData("*opponentGamesOption*", "Game History");
		public var conversationOption:IconListData = new IconListData("*chatOption*", "Chat", ImageManager.ChatIcon);
		
		public var newGameOption:IconListData = new IconListData("*newGame*", "New Game", ImageManager.AddIcon);
		public var currentGameOption:IconListData = new IconListData("*currentGame*", "Current Game", ImageManager.GoIcon);
						
		private var faultHandler:Function;
		private var dateFormatter:DateFormatter;
		
		private var hasAwaitingGames:Boolean;
		
		
		
		public function ViewModel(enforcer:SingletonEnforcer)
		{
			persistenceManager = new PersistenceManager();
			
			_useTestServices = persistenceManager.getProperty("useTestServices") != null && persistenceManager.getProperty("useTestServices");
			_deviceId = persistenceManager.getProperty("deviceId") as String;
			_refreshToken = persistenceManager.getProperty("refreshToken") as String;
			_pushNotificationToken = persistenceManager.getProperty("pushNotificationToken") as PushNotificationToken;
			_pushNotificationsEnabled = persistenceManager.getProperty("pushNotificationsEnabled") == null || persistenceManager.getProperty("pushNotificationsEnabled") as Boolean;
			_soundEnabled = persistenceManager.getProperty("soundEnabled") == null || persistenceManager.getProperty("soundEnabled") as Boolean;
			_lastSeenVersion = persistenceManager.getProperty("lastSeenVersion") as String;
			_lastIconCount = persistenceManager.getProperty("lastIconCount") as int;
			_nextRateDate = persistenceManager.getProperty("nextRateDate") as Number;
			if (!_nextRateDate){
				nextRateDate = new Date().time + RATE_DATE_INTERVAL;
			}
			
			_iconCache = new ContentCache();
			_iconCache.enableCaching = true;
			_iconCache.enableQueueing = true;
			_iconCache.prioritize("userIcon");
			_iconCache.maxCacheEntries = 60;
			
			dateFormatter = new DateFormatter();
			dateFormatter.formatString = "M/D/YYYY L:NN A";
			
			_profileOptions = new ArrayList([gamesOption, opponentsOption, iconsOption,  messagesOption, leaderboardOption, inviteAFriendOption]);
		}
		
		public static function getInstance():ViewModel
		{
			if (!instance){
				instance = new ViewModel(new SingletonEnforcer());
			}
			return instance;
		}
		

		public function resetData():void
		{					
			resetProfileOptions();

			resetIcons();
			resetGames();
			resetOpponents();	
			resetCurrentOpponent();
			resetCurrentUser();
			
			resetLeaderBoardData();
			
			iconCache.removeAllCacheEntries();
		}
		
		public function resetProfileOptions():void
		{
			gamesOption.decorator = null;
			iconsOption.decorator = null;
			
			dispatchEvent(new Event(PROFILE_OPTIONS_CHANGED));
		}
		
		public function resetCurrentUser():void
		{
			_currentUser = null;
			_messageList = null;
			userIcon = null;
			//dispatchEvent(new Event(CURRENT_USER_CHANGED));
		}
		
		public function resetIcons():void
		{
			_icons = null;
			dispatchEvent(new Event(ICONS_CHANGED));
		}
		
		public function resetGames():void
		{
			_gameList = null;
			//dispatchEvent(new Event(GAMES_CHANGED));
		}
		
	
		public function resetOpponents():void
		{
			_opponentList = null;
			dispatchEvent(new Event(OPPONENTS_CHANGED));
		}
		
		
		
		public function resetCurrentOpponent():void
		{
			_currentOpponent = null;
			_expiredOpponentGameList = null;
			
			dispatchEvent(new Event(CURRENT_OPPONENT_CHANGED));
		}
				

		public function loadCurrentUserResult(event:ResultEvent):void
		{
			_currentUser = event.resultObj as ApplicationUser;
			userIcon = _currentUser.icon;
			
			if (_currentUser.messages){
				setMessages(_currentUser.messages);
				
				if (_currentUser.hasUnreadPriorityMessages){
					messagesOption.decorator = ImageManager.AlertIcon;
				}
			}
			
			if (_currentUser.icons){
				setIcons(_currentUser.icons);
				
				if (!isNaN(lastIconCount) && lastIconCount < _currentUser.icons.length){
					markProfileOptionAlert(iconsOption, true);
				}
				
				lastIconCount = _currentUser.icons.length;
			}
			
			if (_currentUser.isDebug && !debugEnabled){
				debugEnabled = true;
			}

			lastUpdatedUser = new Date().time;
		}
		
		public function loadGamesResult(event:ResultEvent):void
		{
			var list:Array = (event.resultObj is GamesWrapper) ? event.resultObj.games as Array : [event.resultObj];
			
			_gameList = new ArrayList();
			for each (var addedGameData:GameData in list){ 
				_gameList.addItem(createGameListData(addedGameData));
			}
			
			
			dispatchEvent(new Event(GAMES_CHANGED));
			
		}
		
		public function updateGamesResult(event:ResultEvent):void
		{
			var list:Array = (event.resultObj is GamesWrapper) ? event.resultObj.games as Array : [event.resultObj];
			var updatedList:ArrayList = new ArrayList(list);
			
			for (var i:int = 0; i < _gameList.length; i++)
			{
				var listData:IconListData = _gameList.getItemAt(i) as IconListData;
				var found:Boolean = false;
				
				for (var j:int = 0; j < updatedList.length; j++)
				{
					
					var updatedGameData:GameData = updatedList.getItemAt(j) as GameData;
					if (updatedGameData.gameKey == listData.key)
					{
						
						_gameList.setItemAt(createGameListData(updatedGameData),i);
						dispatchEvent(new GameEvent(GameEvent.GAME_DATA_UPDATE, updatedGameData));
						
						updatedList.removeItemAt(j);
						found = true;
						break;
					}
				}
				
				if (!found){
					gameList.removeItemAt(i);
					i--;
				}
			}
			
			for (i=0; i < updatedList.length; i++){ 
				var addedGameData:GameData = updatedList.getItemAt(i) as GameData;
				_gameList.addItemAt(createGameListData(addedGameData), 0);
			}
			
			dispatchEvent(new Event(GAMES_CHANGED));
			
		}
		
		public function updateGame(updatedGameData:GameData):void
		{
			for (var i:int = 0; i < _gameList.length; i++)
			{				
				var listData:IconListData = _gameList.getItemAt(i) as IconListData;
				
				if (listData.key == updatedGameData.gameKey)
				{
					_gameList.setItemAt(createGameListData(updatedGameData), i);
					dispatchEvent(new GameEvent(GameEvent.GAME_DATA_UPDATE, updatedGameData));
					dispatchEvent(new Event(GAMES_CHANGED));
					break;
				}
			}
				
			if (i == _gameList.length && updatedGameData.gameStatus != Status.GAME_FINISHED){
				_gameList.addItemAt(createGameListData(updatedGameData), 0);
				dispatchEvent(new Event(GAMES_CHANGED));
			}
			
		
		}

		public function loadOpponentsResult(event:ResultEvent):void
		{			
			var list:Array = (event.resultObj is OpponentsWrapper) ? event.resultObj.opponents as Array : [event.resultObj];
			
			_opponentList = new ArrayList();
			for each (var opponent:Opponent in list)
			{
				var opponentListData:IconListData = createOpponentListData(opponent);
				_opponentList.addItem(opponentListData);
			}
			
			dispatchEvent(new Event(OPPONENTS_CHANGED));
			
		}
		
		public function updateOpponent(opponent:Opponent):Boolean
		{
			var  i:int = 0;
			for each (var listData:IconListData in _gameList)
			{				
				if (listData.key == opponent.username){
					_opponentList.setItemAt(createOpponentListData(opponent), i);
					break;
				}
				i++;
			}
			if (i == _gameList.length){
				_opponentList.addItemAt(createOpponentListData(opponent), 0);
			}
			
			dispatchEvent(new Event(OPPONENTS_CHANGED));
			return true;
		}
		
		public function setMessages(list:Array):void
		{
			_messageList = new ArrayList();
			for each (var message:SystemMessage in _currentUser.messages){
				_messageList.addItem(createMessageListData(message));
				
				if (message.icon && message.icon.iconURL){
					iconCache.load(message.icon.iconURL);
				}
			}
		}

		
		public function setIcons(list:Array, preload:Boolean=false):void
		{
			
			_icons = new ArrayList();
			
			for each (var icon:UserIcon in list)
			{
				if (preload && icon.iconURL){
					iconCache.load(icon.iconURL);
				}
				
				_icons.addItem(icon);
			}
			
			dispatchEvent(new Event(ICONS_CHANGED));
		}
		
		public function loadExpiredOpponentGamesResult(event:ResultEvent):void
		{
			var list:Array = (event.resultObj is GamesWrapper) ? event.resultObj.games as Array : [event.resultObj];
			
			_expiredOpponentGameList = new ArrayList();
			for each (var addedGameData:GameData in list){ 
				_expiredOpponentGameList.addItem(createGameListData(addedGameData));
			}
			
			dispatchEvent(new Event(GAMES_CHANGED));
		}
		
		public function createGameListData(gameData:GameData):IconListData
		{
			var listData:IconListData = new IconListData();
			listData.key = gameData.gameKey;
			listData.label = gameData.opposingPlayer.username;
			listData.icon =  gameData.opposingPlayer.icon;
			listData.message = (gameData.player.playerStatus == Status.PLAYER_INVITED) ? gameData.opposingPlayer.username+" has invited you to a new game." : gameData.lastActionMessage;
			
			switch (gameData.gameStatus)
			{
				case Status.GAME_INITIALIZING:
					listData.subLabel = "Awaiting invitation respsonse.";
					break;
				
				case Status.GAME_RUNNING:
					listData.subLabel = (gameData.lastUpdatedDate != null) ? "Last move "+DateUtil.timeAgo(gameData.lastUpdatedDate)+ " ago." : null;
					break;
				
				case Status.GAME_FINISHED:
					listData.subLabel = (gameData.lastUpdatedDate != null) ? "Game ended "+DateUtil.timeAgo(gameData.lastUpdatedDate)+ " ago." : null;
					break;
			}
			
			switch (gameData.player.playerStatus)
			{
				case (Status.PLAYER_PLAYING):
					listData.decorator = (gameData.player.isTurn) ? ImageManager.YourTurnStatusIcon : ImageManager.AwaitingTurnStatusIcon;
					break;
				
				case (Status.PLAYER_WON):
					listData.decorator = ImageManager.VictoryStatusIcon;
					break;
				
				case (Status.PLAYER_LOST):
					listData.decorator = ImageManager.DefeatStatusIcon;
					break;
				
				case (Status.PLAYER_TIED):
					listData.decorator = ImageManager.DrawStatusIcon;
					break;	
				
				case (Status.PLAYER_INVITED):
					listData.decorator = ImageManager.NewGameStatusIcon;
					break;
			}
			
			
			listData.dataObj = gameData;
			
			return listData;
		}
		
		public function createOpponentListData(opponent:Opponent):IconListData
		{
			var listData:IconListData = new IconListData();
			listData.key = opponent.username;
			listData.label = opponent.username;
			listData.icon = (opponent.icon) ? opponent.icon.iconURL : null;
			listData.subLabel = (opponent.lastPlayedAgainstDate != null) ? "Last game "+DateUtil.timeAgo(opponent.lastPlayedAgainstDate) + " ago" : null;
			listData.decorator = (opponent.icon) ? opponent.icon.badgeURL : null;
			listData.dataObj = opponent;
			
			if (gameList){
				for each (var gameListData:IconListData in gameList.source){ 
					var gameData:GameData = gameListData.dataObj as GameData;
					if (gameData && gameData.gameStatus == Status.GAME_RUNNING && gameData.opposingPlayer.username == opponent.username){
						listData.subLabel = "Currently playing";
						break;
					}
				}
			}
			
			
			if (listData.icon){
				iconCache.load(listData.icon);
			}
			
			if (listData.decorator){
				iconCache.load(listData.decorator);
			}
			
			
			
			return listData;
		}
		
		public function createUserList(list:Array):ArrayList{
			
			var userList:ArrayList  = new ArrayList();
			
			for each (var user:ApplicationUser in list){
				var userListData:IconListData = createUserListData(user);
				userList.addItem(userListData);
			}
			
			return userList;
		}
		
		public function createUserListData(user:ApplicationUser):IconListData{
			var listData:IconListData = new IconListData();
			listData.key = user.username;
			listData.label = user.username;
			listData.icon = (user.icon) ? user.icon.iconURL : null;
			listData.decorator = (user.icon) ? user.icon.badgeURL : null;
			listData.rank = (user.icon) ? user.icon.rank : NaN;
			listData.dataObj = user;
			
			if (listData.icon){
				iconCache.load(listData.icon);
			}
			
			if (listData.decorator){
				iconCache.load(listData.decorator);
			}
			
			
			return listData;
		}
		
		public function createMessageListData(message:SystemMessage):IconListData
		{
			var listData:IconListData = new IconListData();
			listData.key = message.messageKey;
			listData.message = message.subject;
			listData.icon =  (message.icon) ? message.icon.iconURL : null;
			listData.decorator = (message.isPriority && !message.isRead) ? ImageManager.AlertIcon : null;	
			listData.dataObj = message;
			
			return listData;
		}
		
		
		

		public function removeGame(gameData:GameData):void
		{
			for (var i:int = 0; i < _gameList.length; i++)
			{
				var listData:IconListData = _gameList.getItemAt(i) as IconListData;
				if (listData.key == gameData.gameKey){
					_gameList.removeItemAt(i);
					dispatchEvent(new Event(GAMES_CHANGED));
					break;
				}
			}
		}
	
		
		public function removeOpponent(opponent:Opponent):void
		{
			for (var i:int = 0; i < _opponentList.length; i++)
			{
				var listData:IconListData = _opponentList.getItemAt(i) as IconListData;
				if (listData.key == opponent.username){
					_gameList.removeItemAt(i);
					dispatchEvent(new Event(OPPONENTS_CHANGED));
					break;
				}
			}
		}
		
		public function markProfileOptionAlert(value:IconListData, hasAlert:Boolean):void
		{
			value.decorator = (hasAlert) ? ImageManager.AlertIcon : null;
			dispatchEvent(new Event(PROFILE_OPTIONS_CHANGED));
		}
		
		public function setProfileOptionIcon(value:IconListData, icon:Class):void
		{
			value.icon = icon;
			dispatchEvent(new Event(PROFILE_OPTIONS_CHANGED));
		}
		
		public function setCurrentOpponent(value:Opponent):void
		{
			_currentOpponent = value;
			
			
			dispatchEvent(new Event(CURRENT_OPPONENT_CHANGED));
		}
		
		public function setLeaderBoardData(value:Array):void
		{
			_leaderBoardData = createUserList(value);
			dispatchEvent(new Event(LEADER_BOARD_DATA_CHANGED));
		}
		
		public function resetLeaderBoardData():void
		{
			_leaderBoardData = null;
			dispatchEvent(new Event(LEADER_BOARD_DATA_CHANGED));
		}
		
		
		
	}

}

class SingletonEnforcer{}