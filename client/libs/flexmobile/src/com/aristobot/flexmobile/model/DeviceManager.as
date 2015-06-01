package com.aristobot.flexmobile.model
{
	import com.aristobot.as3srserrvice.events.FaultEvent;
	import com.aristobot.as3srserrvice.events.ResultEvent;
	import com.aristobot.as3srserrvice.model.ServiceModel;
	import com.aristobot.as3srserrvice.model.Status;
	import com.aristobot.data.DeviceData;
	import com.aristobot.data.GameData;
	import com.aristobot.data.PushNotificationToken;
	import com.aristobot.flexmobile.views.Game;
	import com.aristobot.pushnotifications.PushNotification;
	import com.aristobot.pushnotifications.events.PushNotificationEvent;
	
	import flash.desktop.NativeApplication;
	import flash.system.Capabilities;
	import flash.utils.getDefinitionByName;

	public class DeviceManager
	{
		protected var vm:ViewModel = ViewModel.getInstance();
		protected var vc:ViewController = ViewController.getInstance();
		protected var srm:ServiceModel = ServiceModel.getInstance();
		
		protected var pn:PushNotification;
		
		protected static const SENDER_ID:String = "93210277076";
				
		public function DeviceManager()
		{			
			pn = new PushNotification();
			pn.addEventListener(PushNotificationEvent.REGISTERED, registrationResult, false, 0, true);
			pn.addEventListener(PushNotificationEvent.NOTIFICATION_RECEIVED, notificationReceived, false, 0, true);
			pn.addEventListener(PushNotificationEvent.ERROR, registrationError, false, 0, true);
						
			var manufacturer:String = Capabilities.manufacturer.toLowerCase();
			if (manufacturer.indexOf("android") >= 0)
			{
				vm.deviceType = DeviceData.ANDROID;
			
				if (!vm.deviceId){
					vm.deviceId = pn.getDeviceId();
				}
			}
			else if (manufacturer.indexOf("ios") >= 0)
			{
				vm.deviceType = DeviceData.IOS;
				
				if (!vm.deviceId)
				{
					try 
					{
						vNetworkInterfaces = getDefinitionByName("com.adobe.nativeExtensions.Networkinfo.NetworkInfo")["networkInfo"]["findInterfaces"]();
						for each (var iosInterface:Object in vNetworkInterfaces)
						{
							if (iosInterface.name == "en0"){
								vm.deviceId = iosInterface.hardwareAddress;
								break;
							}
						}
					}
					catch (e:Error){
						vc.log("Error setting up push notification manager: "+e.getStackTrace());
					}
				}
			}
			
			else
			{
				vm.deviceType = DeviceData.OTHER;
				
				if (!vm.deviceId)
				{
					try{
	
						var vNetworkInterfaces:Object = getDefinitionByName("flash.net.NetworkInfo")["networkInfo"]["findInterfaces"]();
						for each (var otherInterface:Object in vNetworkInterfaces)
						{
							if (otherInterface.hardwareAddress && otherInterface.hardwareAddress.length > 0){
								vm.deviceId = otherInterface.hardwareAddress;
								break;
							}
						}
					}
					catch (e:Error){
						vc.log("Error retrieving device id: "+e.getStackTrace());
					}
				}
			}
		}
		
		public function enableSound():void
		{
			vm.soundEnabled = true;
		}
		
		public function disableSound():void
		{
			vm.soundEnabled = false;
		}
			

		public function notificationsSupported():Boolean
		{
			return vm.deviceType != DeviceData.OTHER;
		}
		
		public function registerPushNotifications():void
		{
			pn.register(SENDER_ID);
		}	
		
		public function unregisterPushNotifications():void
		{
			vm.pushNotificationToken = null;
			
			if (srm.isAuthenticated()){
				srm.authenticationService.deletePushNotificationToken(pushNotificationUpdateResult, pushNotificationUpdateError);
				ActionContentManager.startLoading();
			}

			pn.unregister();
		}
					
		protected function registrationResult(event:PushNotificationEvent):void
		{
			if (event.registrationId && event.registrationId.length)
			{
				var pnToken:PushNotificationToken = new PushNotificationToken();
				pnToken.token = event.registrationId;
				
				if (vm.deviceType == DeviceData.IOS){
					var descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
					var ns:Namespace = descriptor.namespaceDeclarations()[0];
					var entitlements:String = descriptor.ns::iPhone.ns::Entitlements;
					
					pnToken.isProduction = entitlements && entitlements.indexOf("production") >= 0;
				}
				
				vm.pushNotificationToken = pnToken;
				vm.pushNotificationsEnabled = true;
				
				if (srm.isAuthenticated()){
					ActionContentManager.startLoading()
					srm.authenticationService.setPushNotificationToken(vm.pushNotificationToken, pushNotificationUpdateResult, pushNotificationUpdateError);
				}
			}
			
		}
		
		protected function notificationReceived(event:PushNotificationEvent):void
		{
			if (!vc.activated && event.message){
				pn.notify(event.message, event.params);
			}else if(!(vc.navigator.activeView is Game)){
				SoundManager.playSound(SoundManager.ALERT);
			}
			
			if (srm.isAuthenticated() && vc.dataLoaded){
				srm.gameService.getAllGames(vm.updateGamesResult);
			}
		}
		
		protected function registrationError(event:PushNotificationEvent):void
		{
			AlertManager.displayNotificaitonWindow("Unable to register Push Notifications");
			vc.log("Push Notifications Registration Error :"+event.errorCode);
			vm.pushNotificationToken = null;
			vm.pushNotificationsEnabled = false;
		}
		
		protected function pushNotificationUpdateResult(event:ResultEvent):void
		{
			ActionContentManager.stopLoading();
		}
		
		protected function pushNotificationUpdateError(event:FaultEvent):void
		{
			vm.pushNotificationToken = null;
			ActionContentManager.stopLoading();
		}
		
		public function getDeviceData():DeviceData
		{
			var data:DeviceData = new DeviceData();
			data.deviceId = vm.deviceId;
			data.deviceType = vm.deviceType;
			data.os = Capabilities.os;
			data.cpuArchitecture = Capabilities.cpuArchitecture;
			data.screenDPI = Capabilities.screenDPI;
			
			return data;
		}
		
		public function setBadgeNumber():void
		{
			if (vm.deviceType != DeviceData.IOS){
				return;
			}
			
			var numGames:int = 0;
			
			if (srm.isAuthenticated() && vm.gameList){
				var length:int = vm.gameList.length;
				
				for (var i:int = 0; i < length; i++)
				{
					var gameData:GameData = vm.gameList.getItemAt(i).dataObj as GameData;
					
					if (gameData && gameData.player && (gameData.player.isTurn || gameData.player.playerStatus == Status.PLAYER_INVITED)){
						numGames++;
					}
				}
			}
			
			pn.setBadgeNumberValue(numGames);
		}
	}
}