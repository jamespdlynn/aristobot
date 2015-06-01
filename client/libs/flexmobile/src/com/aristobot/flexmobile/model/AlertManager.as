package com.aristobot.flexmobile.model
{
	import com.aristobot.flexmobile.components.windows.AlertWindow;
	import com.aristobot.flexmobile.components.windows.ConfirmWindow;
	import com.aristobot.flexmobile.components.windows.LoadWindow;
	import com.aristobot.flexmobile.components.windows.NotificationWindow;
	import com.aristobot.flexmobile.components.windows.SettingsWindow;
	
	import flash.display.DisplayObjectContainer;
	
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import spark.events.PopUpEvent;

	public class AlertManager
	{
		private static var windowContainer:DisplayObjectContainer = FlexGlobals.topLevelApplication as DisplayObjectContainer;
		private static var autoDisplay:Boolean = false;
		
		private static var windowQueue:ArrayList = new ArrayList();
		private static var currentWindow:AlertWindow;
	
		private static var loadWindow:LoadWindow;		
		private static var isLoading:Boolean;
		
		private static var settingsWindow:SettingsWindow;
			

		public static function displayNotificaitonWindow(alert:String,callback:Function=null, closeEnabled:Boolean=false):void
		{

			var window:NotificationWindow = new NotificationWindow();
			window.label = alert;
			window.closeEnabled = closeEnabled;
			
			if (callback != null){
				window.addEventListener(NotificationWindow.OK, callback, false, 0, true);
			}
			
			pushWindow(window);

		}
		
		public static function displayConfirmWindow(alert:String, buttonLabels:Array=null, confirmHandler:Function = null, rejectHandler:Function = null, closeEnabled:Boolean=false):void
		{
			
			var window:ConfirmWindow = new ConfirmWindow();
			window.label = alert;
			window.buttonLabels = buttonLabels;
			window.closeEnabled = closeEnabled;
			
			if (confirmHandler != null){
				window.addEventListener(ConfirmWindow.CONFIRM, confirmHandler, false, 0, true);
			}
			
			if (rejectHandler != null){
				window.addEventListener(ConfirmWindow.REJECT, rejectHandler, false, 0, true);
			}
			
			pushWindow(window);
		}
		
		public static function displayCustomWindow(window:AlertWindow):void
		{
			pushWindow(window);
		}
		
		public static function displayLoadWindow(label:String, priority:int=0):void
		{
			
			closeLoadWindow(priority);
			
			if (!loadWindow){
				loadWindow = new LoadWindow();
				loadWindow.label = label;
				loadWindow.priority = priority;
			}

			
			if (!currentWindow){
				currentWindow = loadWindow;
				openCurrentWindow();
			}
			
			isLoading = true;
			
		}
		
		
		public static function closeLoadWindow(priority:int=0):void
		{
			if (loadWindow)
			{
				if (priority < loadWindow.priority){
					return;
				}
				
				if(loadWindow == currentWindow){
					currentWindow = null;
					loadWindow.close();
				}
				
			}				
			
			loadWindow = null;
			isLoading = false;
		}
		
		public static function turnOnAutoDisplay():void
		{
			autoDisplay = true;
			openCurrentWindow();
		}
		
		public static function turnOffAutoDisplay():void
		{				
			autoDisplay = false;
			hideCurrentWindow();
		}
		
		public static function closeAllWindows():void
		{
			windowQueue = new ArrayList();
			closeLoadWindow(10);
			
			if (settingsWindow){
				settingsWindow.close();
			}
			
			if (currentWindow){
				currentWindow.close();
			}
		}
		
	
		private static function pushWindow(newWindow:AlertWindow):void
		{
			if (currentWindow == loadWindow){
				hideCurrentWindow();
				currentWindow = null;
			}
			
			if (!currentWindow){
				currentWindow = newWindow;
				openCurrentWindow();
			}
			else{
				windowQueue.addItem(newWindow);
			}
		}
		
		private static function removeCurrentWindow(event:PopUpEvent=null):void
		{
			currentWindow.removeEventListener(PopUpEvent.CLOSE, removeCurrentWindow);	
			
			
			if (windowQueue.length > 0){
				currentWindow = windowQueue.removeItemAt(0) as AlertWindow;
				openCurrentWindow();
			}
			else if (isLoading){
				currentWindow = loadWindow;
				openCurrentWindow();
			}
			else{
				currentWindow = null;
			}
			
		}	
		
		public static function displaySettingsWindow():void
		{
			if (!settingsWindow || !settingsWindow.isOpen)
			{
				settingsWindow = new SettingsWindow();
				settingsWindow.addEventListener(PopUpEvent.CLOSE, removeSettingsWindow);
				settingsWindow.open(windowContainer,true);
				PopUpManager.centerPopUp(settingsWindow);
			}
			
		}
		
		private static function removeSettingsWindow(event:PopUpEvent):void
		{
			settingsWindow.removeEventListener(PopUpEvent.CLOSE, removeSettingsWindow);
			settingsWindow = null;
		}
		
		private static function openCurrentWindow():void
		{
			if (currentWindow != null && !currentWindow.isOpen && autoDisplay)
			{
				currentWindow.open(windowContainer, true);
				PopUpManager.centerPopUp(currentWindow);
				
				if (currentWindow != loadWindow){
					currentWindow.addEventListener(PopUpEvent.CLOSE, removeCurrentWindow, false, 0, true);
				}
			}
			
		}
		
		private static function hideCurrentWindow():void
		{
			if (currentWindow && currentWindow.isOpen)
			{
				currentWindow.removeEventListener(PopUpEvent.CLOSE, removeCurrentWindow);
				currentWindow.close();
			}
		}
		
		public static function hasWindowOpen():Boolean{
			return (currentWindow || settingsWindow);
		}

		
		
	}
}