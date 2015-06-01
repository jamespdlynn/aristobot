package com.aristobot.flexmobile.model
{
	import com.aristobot.as3srserrvice.events.FaultEvent;
	import com.aristobot.as3srserrvice.events.ResultEvent;
	import com.aristobot.as3srserrvice.model.ServiceModel;
	import com.aristobot.as3srserrvice.model.Status;
	import com.aristobot.data.DeviceData;
	import com.aristobot.data.GameData;
	import com.aristobot.data.LogData;
	import com.aristobot.data.PushNotification;
	import com.aristobot.data.RegistrationData;
	import com.aristobot.data.Tokens;
	import com.aristobot.flexmobile.components.IGameBoard;
	import com.aristobot.flexmobile.components.windows.RateWindow;
	import com.aristobot.flexmobile.views.Game;
	import com.aristobot.flexmobile.views.GamesList;
	import com.aristobot.flexmobile.views.MessageView;
	import com.aristobot.flexmobile.views.MessagesList;
	import com.aristobot.flexmobile.views.Register;
	import com.aristobot.flexmobile.views.SelectIcon;
	import com.aristobot.flexmobile.views.SignIn;
	import com.aristobot.flexmobile.views.UserProfile;
	
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.KeyboardEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import spark.components.List;
	import spark.components.ViewNavigator;
	import spark.components.ViewNavigatorApplication;
	import spark.transitions.CrossFadeViewTransition;
	import spark.transitions.ViewTransitionBase;

	public class ViewController
	{
		private static var instance:ViewController;
		
		private static const ACTIVE_FRAME_RATE:Number = 16;
		private static const INACTIVE_FRAME_RATE:Number = 1;
		
		protected var srm:ServiceModel;
		protected var vm:ViewModel;
		protected var gm:GameModel;
		
		protected var _deviceManager:DeviceManager;
		public function get deviceManager():DeviceManager{
			return _deviceManager;
		}
		
		protected var _application:ViewNavigatorApplication;
		public function get application():ViewNavigatorApplication{
			return _application;
		}
		
		protected var _navigator:ViewNavigator;
		public function get navigator():ViewNavigator{
			return _navigator;
		}
		
		protected var _activated:Boolean = true;
		public function get activated():Boolean{
			return _activated;
		}
		
		protected var _dataLoaded:Boolean;
		public function get dataLoaded():Boolean{
			return _dataLoaded;
		}
		
		protected var _scale:Number = 1;
		public function get scale():Number{
			return _scale;
		}
		
		protected var _isTablet:Boolean;
		public function get isTablet():Boolean{
			return _isTablet;
		}
							
		protected var registering:Boolean;
		
		protected var numItemsLoading:int;
																				
		protected var invokedGameKey:String;
		protected var invokedGameData:GameData;
		
		protected var _defaultServiceURL:String;
		public function get defaultServiceURL():String{
			return _defaultServiceURL;
		}
		protected var _testServiceURL:String
		public function get testServiceURL():String{
			return _testServiceURL;
		}
		
		protected var currentFrame:int;
		protected var resetFrame:int;


		public function ViewController(enforcer:SingletonEnforcer)
		{
			if (instance){
				throw new Error("Only one instance of Class can be instantiated");
			}
		}
		
		public static function getInstance():ViewController
		{
			if (!instance){
				instance = new ViewController(new SingletonEnforcer());
			}
			
			return instance;
		}
		
		public function get applicationDPI():Number
		{
			return (FlexGlobals.topLevelApplication as ViewNavigatorApplication).applicationDPI;
		}
		
		public function setUp(application:ViewNavigatorApplication, apiKey:String, appIcon:Class, gameBoard:IGameBoard, defaultServiceURL:String = ServiceModel.SERVICE_PRODUCTION_URL, testServiceURL:String = ServiceModel.SERVICE_DEVELOPMENT_URL, isDebug:Boolean = false):void
		{							
			srm = ServiceModel.getInstance();
			vm = ViewModel.getInstance();
			gm = GameModel.getInstance();
												
			_application = application;
			_application.addEventListener(FlexEvent.APPLICATION_COMPLETE, function(event:FlexEvent):void{
				application.stage.frameRate = ACTIVE_FRAME_RATE;
				application.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler, false, 0, true);
				scaleApp();
				AlertManager.turnOnAutoDisplay();
			}, false, 0, true);
			
			_navigator = application.navigator;
			
			_defaultServiceURL = defaultServiceURL;
			_testServiceURL = testServiceURL;
			
			_deviceManager = new DeviceManager();
			
			var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = descriptor.namespaceDeclarations()[0];
				
			vm.applicationName = descriptor.ns::name;
			vm.currentVersion = descriptor.ns::versionNumber;
			vm.applicationDPI = application.applicationDPI;
			vm.appIcon = appIcon;
			vm.addEventListener(ViewModel.GAMES_CHANGED, gamesChanged, false, 0, true);
			
			if (!vm.debugEnabled){
				vm.debugEnabled = isDebug;
			}			
			
			if (vm.deviceType != DeviceData.OTHER){
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, activate, false, 0, true);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, deactivate, false, 0, true);
				NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke, false, 0, true);
			}

			gm.gameBoard = gameBoard;
			
			ActionContentManager.setUp();
			srm.setUp(apiKey, defaultFaultHandler);
			autologin();
		}
		
		protected function scaleApp():void{
		
			var width:Number = (vm.deviceType == DeviceData.OTHER) ? application.width : Capabilities.screenResolutionX;
			var height:Number = (vm.deviceType == DeviceData.OTHER) ? application.height : Capabilities.screenResolutionY;
			
			if (width > 800 || height > 1600){
				_scale = (width/height == 0.75) ? width/768 : width/720;
			}
			else if (width < 480){
				_scale = width/480;
			}

			navigator.contentGroup.scaleX = scale;
			navigator.contentGroup.scaleY = scale;
			
			navigator.actionBar.scaleX = scale;
			navigator.actionBar.scaleY = scale;
		}
		
		
		
		protected function activate(event:Event):void
		{
			_activated = true;
			
			if (application.stage){
				application.stage.frameRate = ACTIVE_FRAME_RATE;
			}
				
			
			if (!registering){
				if (!srm.isAuthenticated() || !dataLoaded){
					autologin();
				}
				else if (invokedGameKey){
					if (GameData.isValidGameKey(invokedGameKey)){
						AlertManager.displayLoadWindow("Loading Game...");
						srm.gameService.getGame(invokedGameKey, invokedGameLoadResult, defaultFaultHandler);
					}
					else{
						displayInvokedView();
					}
					invokedGameKey = null;
				}
			}
			
				
			NativeApplication.nativeApplication.executeInBackground = true;
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			
		}		
		
		protected function deactivate(event:Event):void
		{			
			if (application.stage){
				application.stage.frameRate = INACTIVE_FRAME_RATE;
			}
						
			if (srm.isAuthenticated()){
				var currentTime:Number = new Date().time;
				var expirationTime:Number = srm.sessionExpirationDateTime;
				
				currentFrame = 0;
				resetFrame = Math.floor((expirationTime-currentTime)/(1000*INACTIVE_FRAME_RATE));
				application.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true)
			}
			
			NativeApplication.nativeApplication.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_activated = false;	
			
			deviceManager.setBadgeNumber();
		}
		
		private function onEnterFrame(event:Event):void{
			if (_activated){
				application.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				return;
			}
			
			if (currentFrame > resetFrame){
				vm.resetData();
				srm.unAuthenticate();
				
				application.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				NativeApplication.nativeApplication.executeInBackground = false;
			}
			else if (currentFrame == resetFrame-2){
				ActionContentManager.stopLoading();
				AlertManager.closeAllWindows();
				resetViews();
			}
			
			
			currentFrame++;
		}
		
		private function onKeyDown(event:KeyboardEvent):void{
			if (activated && AlertManager.hasWindowOpen() && (event.keyCode == Keyboard.BACK || event.keyCode == Keyboard.MENU)){
				event.preventDefault();
				event.stopImmediatePropagation();
			}
		}
		
		private function onInvoke(event:InvokeEvent):void
		{
			if (event.arguments.length > 0){
				invokedGameKey = event.arguments[0];
			}
		}
		
		protected function resetViews():void
		{
			var emptyTransition:ViewTransitionBase = new ViewTransitionBase();
			if (navigator.activeView is Game && !vm.currentOpponent){
				navigator.popView(emptyTransition);
			}
			else if (!(navigator.activeView is GamesList)){
				navigator.popToFirstView(emptyTransition);
			}	
		}
		
		public function autologin(event:Event = null):void
		{
			if (!activated || srm.authenticationService.isRunning || numItemsLoading > 0) return;
			
			srm.serviceRootURL = vm.debugEnabled && vm.useTestServices ? testServiceURL : defaultServiceURL;
			
			srm.unAuthenticate();
			
			AlertManager.closeAllWindows();
			resetViews();
			
			registering = false;
			_dataLoaded = false;
			
			if (vm.refreshToken && vm.refreshToken.length){						
				AlertManager.displayLoadWindow("Authenticating...", 1);
				srm.authenticationService.autoLogin(vm.refreshToken, authenticationResultHandler, setUpFaultHandler);
			}
			else 
			{
				var data:DeviceData = new DeviceData();
				data.deviceId = vm.deviceId;
				data.deviceType = vm.deviceType;
				data.os = Capabilities.os;
				data.cpuArchitecture = Capabilities.cpuArchitecture;
				data.screenDPI = Capabilities.screenDPI;
								
				AlertManager.displayLoadWindow("Connecting...", 1);
				srm.authenticationService.connect(data, connectResultHandler, setUpFaultHandler);
			}
		}
		
		
		protected function connectResultHandler(event:ResultEvent):void
		{			
			var data:RegistrationData = event.resultObj as RegistrationData;
			vm.deviceId = data.deviceId;
			
			registering = true;
						
			AlertManager.closeLoadWindow(1);
				
			vm.setIcons(data.defaultIcons);
			vm.applicationData = data.appData;
					
			navigator.popAll();
			
			if (data.registeredUsername){
				navigator.pushView(SignIn, data.registeredUsername, null ,new CrossFadeViewTransition());
			}
			else{
				navigator.pushView(Register, null, null ,new CrossFadeViewTransition());
			}
			
			checkNewerVersionExists(data.appData.currentVersion);
			
			if (vm.pushNotificationsEnabled){
				deviceManager.registerPushNotifications();
			}	
		}	
		
		
		public function authenticationResultHandler(event:ResultEvent):void
		{
			
			if (!srm.isAuthenticated()){
				throw new Error("Something went wrong during authentication");
			}
			
			registering = false;
			
			var tokens:Tokens = event.resultObj as Tokens;
			vm.applicationData = tokens.appData;
			vm.refreshToken = tokens.refreshToken;
			
			if (!vm.pushNotificationToken && vm.pushNotificationsEnabled){
				deviceManager.registerPushNotifications();
			}
			
			if (!checkNewerVersionExists(vm.applicationData.currentVersion)){
				loadAllData();
			}
			
		}
		
		public function loadAllData(event:Event = null):void
		{		
			if (!srm.isAuthenticated()){
				autologin();
				return;
			}
			
			_dataLoaded = false;
			
			numItemsLoading = 3;
			
			vm.addEventListener(ViewModel.CURRENT_USER_CHANGED, checkAllDataLoaded, false, 0, true);
			vm.addEventListener(ViewModel.OPPONENTS_CHANGED, checkAllDataLoaded, false, 0, true);
			vm.addEventListener(ViewModel.GAMES_CHANGED, checkAllDataLoaded, false, 0, true);
			
			if (!invokedGameKey && gm.currentGameData && navigator.activeView is Game){
				invokedGameKey = gm.currentGameData.gameKey;
			}
			
			if (invokedGameKey && GameData.isValidGameKey(invokedGameKey)){
				numItemsLoading++;
				srm.gameService.getGame(invokedGameKey, invokedGameLoadResult, invokedGameLoadFault);
				invokedGameKey = null;
			}
			
			srm.userService.getCurrentUser(vm.loadCurrentUserResult, setUpFaultHandler);
			srm.gameService.getAllGames(vm.loadGamesResult,setUpFaultHandler);
			srm.opponentService.getAllOpponents(vm.loadOpponentsResult,setUpFaultHandler);
			
			AlertManager.displayLoadWindow("Loading Data...", 1);
			ActionContentManager.startLoading();
		}
		
		protected function invokedGameLoadResult(event:ResultEvent):void
		{
			invokedGameData = event.resultObj as GameData;
			
			if (numItemsLoading > 0){
				checkAllDataLoaded();
			}
			else{
				AlertManager.closeLoadWindow();
				displayInvokedGame();
			}
		}
		
		protected function invokedGameLoadFault(event:FaultEvent):void
		{
			if (navigator.activeView is Game){
				navigator.popView();
			}
			
			if (numItemsLoading > 0){
				checkAllDataLoaded();
			}
		}
		
		protected function gamesChanged(event:Event):void
		{
			event.stopPropagation();
			
			if (!vm.gameList) return;
			
			var length:int = vm.gameList.length;
			for (var i:int = 0; i < length; i++)
			{
				var gameData:GameData = vm.gameList.getItemAt(i).dataObj as GameData;
				
				if (gameData && gameData.player && (gameData.player.isTurn || gameData.player.playerStatus == Status.PLAYER_INVITED)){
					vm.markProfileOptionAlert(vm.gamesOption, true);
					return;
				}
			}
			
			vm.markProfileOptionAlert(vm.gamesOption, false);
		}

		protected function checkAllDataLoaded(event:Event=null):void
		{
			numItemsLoading--;
			
			if (numItemsLoading <= 0)
			{
				_dataLoaded = true;
				
				vm.removeEventListener(ViewModel.CURRENT_USER_CHANGED, checkAllDataLoaded);
				vm.removeEventListener(ViewModel.OPPONENTS_CHANGED, checkAllDataLoaded);
				vm.removeEventListener(ViewModel.GAMES_CHANGED, checkAllDataLoaded);
				vm.removeEventListener(ViewModel.ICONS_CHANGED, checkAllDataLoaded);
				
				ActionContentManager.stopLoading();
				
				setTimeout(function():void
				{
					AlertManager.closeLoadWindow(1);
					
					if (new Date().time >= vm.nextRateDate && vm.applicationData && vm.applicationData.updateURL){	
						AlertManager.displayCustomWindow(new RateWindow());
					}
										
					if (!navigator.activeView || navigator.activeView is Register || navigator.activeView is SignIn)
					{
						navigator.popAll();
						navigator.pushView(UserProfile, null, null, new CrossFadeViewTransition());
					}
					
					deviceManager.setBadgeNumber();
					
					if (invokedGameData){
						displayInvokedGame();
					}
					else if (invokedGameKey){
						displayInvokedView();
					}					
					
				},1000);	
			}
		}
		
		protected function displayInvokedGame():void
		{
			if (invokedGameData && dataLoaded)
			{
				var displayGameResult:Boolean = false;
				
				if (invokedGameData.player.playerStatus == Status.PLAYER_INVITED){
					navigator.popToFirstView();
					navigator.pushView(GamesList);
				}
				else
				{				
					if (!(navigator.activeView is GamesList) && !(navigator.activeView is Game)){
						navigator.popToFirstView();
					}
					
					displayGameResult = (invokedGameData.gameStatus == Status.GAME_FINISHED && (!gm.currentGameData || gm.currentGameData.gameKey != invokedGameData.gameKey || gm.currentGameData.gameStatus != Status.GAME_FINISHED));
					gm.init(invokedGameData);
				}
				
				if (displayGameResult){
					setTimeout(function():void{
						gm.displayGameResult(invokedGameData);
						invokedGameData = null;
					}, 800);
				}
				else{
					invokedGameData = null;
				}
			}			
		}
		
		protected function displayInvokedView(){
			switch (invokedGameKey)
			{
				case PushNotification.GAME_PARAMS:
					navigator.popToFirstView();
					navigator.pushView(GamesList);
					break;
				case PushNotification.ICON_PARAMS:
					navigator.popToFirstView();
					navigator.pushView(SelectIcon);
					break;
				case PushNotification.MESSAGE_PARAMS:
					navigator.popToFirstView();
					navigator.pushView(MessagesList);
					break;
			}
			
			invokedGameKey = null;
		}
		
	
		public function logout(event:Event = null):void
		{		
			AlertManager.closeAllWindows();
			AlertManager.displayLoadWindow("Logging out...");
			srm.authenticationService.logout(completeLogout, defaultFaultHandler);
			
			navigator.popAll(new CrossFadeViewTransition());
		}
		
		protected function completeLogout(event:ResultEvent=null):void
		{ 			
			deviceManager.unregisterPushNotifications();
			
			AlertManager.closeLoadWindow();	
			ActionContentManager.stopLoading();
			
			vm.resetData();
			vm.refreshToken = null;
			vm.lastIconCount = NaN;
			srm.unAuthenticate();
			
			deviceManager.setBadgeNumber();
						
			autologin();
		}
		

				
		protected function setUpFaultHandler(event:FaultEvent):void
		{
			resetServices();
			
			if (navigator.activeView){
				navigator.activeView.enabled = true;
			}
			
			
			switch(event.faultCode)
			{
				case FaultEvent.INVALID_DEVICE_ID:
					vm.deviceId = null;
					autologin();
					break;
				
				case FaultEvent.INVALID_ACCESS_TOKEN:
				case FaultEvent.AUTO_LOGIN_FAILED:
					completeLogout();
					break;
				
				//In an unable to connect scenario we want to either retry auto login or exit the application altogether
				case FaultEvent.CONNECTION_ERROR:
				case FaultEvent.CONNECTION_TIME_OUT:
					AlertManager.displayConfirmWindow(event.message, ["Retry","Exit"], retryHandler, exitApplication);
					break;
				
				case FaultEvent.DEPRECATED_VERSION_NUMBER:
					AlertManager.displayNotificaitonWindow("This version of the application is no longer valid. Please install the latest available version.", exitApplication);
					break;
				
				case FaultEvent.SERVER_ERROR:
					AlertManager.displayConfirmWindow("Oops! It seems an error occured while making a request to the server. " +
													  "If you continue to see this message please contact us immediately (info@aristobotgames.com)."
													 , ["Retry","Exit"], retryHandler, exitApplication);
					break;
				
				default:
					AlertManager.displayConfirmWindow(event.message, ["Retry","Exit"], retryHandler, exitApplication);
					break;
			}
			
		}
		
		
		protected function defaultFaultHandler(event:FaultEvent):void
		{
			invokedGameKey = null;
			resetServices();
			
			switch (event.faultCode)
			{
				case FaultEvent.INVALID_ACCESS_TOKEN:
					autologin();
					break;
					
				case FaultEvent.CONNECTION_ERROR:
				case FaultEvent.CONNECTION_TIME_OUT:
					AlertManager.displayConfirmWindow(event.message, ["Retry","Exit"], loadAllData, exitApplication);
					break;
				
				case FaultEvent.SERVER_ERROR:
					AlertManager.displayNotificaitonWindow("Oops! It seems an error occured while making a request to the server. " +
						"If you continue to see this message please contact us immediately (info@aristobotgames.com).", loadAllData);
					break;
				
				default:
					AlertManager.displayNotificaitonWindow(event.message, loadAllData);
					break;
			}	
			
		}
		
		protected function retryHandler(event:Event):void
		{
			if (vm.debugEnabled){
				AlertManager.displaySettingsWindow();
			}
			else{
				autologin();
			}
		}
		
		protected function resetServices():void
		{
			AlertManager.closeLoadWindow(1);
			ActionContentManager.stopLoading();
			
			srm.resetServices();
			gm.cancelCalls();
			
			if (numItemsLoading > 0)
			{
				vm.removeEventListener(ViewModel.CURRENT_USER_CHANGED, checkAllDataLoaded);
				vm.removeEventListener(ViewModel.OPPONENTS_CHANGED, checkAllDataLoaded);
				vm.removeEventListener(ViewModel.GAMES_CHANGED, checkAllDataLoaded);
				vm.removeEventListener(ViewModel.ICONS_CHANGED, checkAllDataLoaded);
				
				numItemsLoading = 0;
			}		
		}


		protected function uncaughtErrorHandler(event:UncaughtErrorEvent):void
		{
			AlertManager.closeAllWindows();
			
			AlertManager.displayNotificaitonWindow("Oops! "+vm.applicationName + " has encountered a problem and must exit.", exitApplication);
			setTimeout(exitApplication, 3000);
			
			if (!vm.debugEnabled)
			{
				var errorStr:String = "Uncaught Error: "+event.errorID;
				if (event.error && event.error is Error){
					errorStr += " -- "+event.error.message + " -- "+event.error.getStackTrace();
				}
				
				log(errorStr);
			}
		}
		
		public function log(error:String):void
		{
			
			try{
				trace(error);
				
				var data:LogData = new LogData();
				data.version = vm.currentVersion;
				data.view = navigator.activeView.name;
				data.deviceId = deviceManager.getDeviceData().deviceId;
				data.errorMessage = error;
				
				srm.logService.log(data);
			}
			catch (e:Error){
				trace("Error logging: " + e.message);
			}
		}
		
		public function resetList(list:List):void
		{
			if (list){
				list.enabled = true;
				setTimeout(function():void{list.selectedIndex = -1},24);
			}
		}
		
		protected function checkNewerVersionExists(latestVersion:String):Boolean
		{
			if (vm.lastSeenVersion == null || isVersionGreater(vm.currentVersion, vm.lastSeenVersion)){
				vm.lastSeenVersion = vm.currentVersion;
			}
									
			if (isVersionGreater(latestVersion,vm.lastSeenVersion)){
				vm.lastSeenVersion = latestVersion;
				AlertManager.displayConfirmWindow("A new version of "+vm.applicationName+" is available!", ["Get it Now!","No Thanks"], acceptNewApp, declineNewApp);
				return true;
			}
			
			return false;
		}
		
		protected function isVersionGreater(version1:String, version2:String):Boolean
		{
			try{
				var version1Split:Array = version1.split(".");
				var version2Split:Array = version2.split(".");
				
				for (var i:int = 0; i < version1Split.length; i++)
				{
					if (i >= version2Split.length || parseInt(version1Split[i]) > parseInt(version2Split[i])){
						return true;
					}
					if (parseInt(version1Split[i]) < parseInt(version2Split[i])){
						return false;
					}
				}
			}
			catch (e:Error){
				log("Error parsing version numbers");
			}
			
			return false;
		}
				
		protected function acceptNewApp(event:Event):void
		{
			if (vm.applicationData.updateURL && vm.applicationData.updateURL.length){
				navigateToURL(new URLRequest(vm.applicationData.updateURL));
				exitApplication();
			}
			else{
				AlertManager.displayNotificaitonWindow("Please contact Aristobot Games (info@aristbotgames.com) for information about retrieving this newest release.", declineNewApp);
			}
			
		}
		
		protected function declineNewApp(event:Event):void
		{			
			if (srm.isAuthenticated()){
				loadAllData();
			}
		}
		
		public function exitApplication(event:Event=null):void
		{			
			if (vm.deviceType != DeviceData.IOS){
				NativeApplication.nativeApplication.exit();
			}
			else{
				var crashingBitmaps:Array = []
				
				do {
					var bm:BitmapData = new BitmapData ( 2048, 2048, true, Math.floor( Math.random() * uint.MAX_VALUE ) );
					crashingBitmaps.push( bm );
				} while ( true );

			}
		}
	
	}
}

class SingletonEnforcer{}