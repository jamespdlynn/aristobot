package com.aristobot.admin.managers
{
	import com.aristobot.admin.windows.AlertWindow;
	import com.aristobot.admin.windows.ConfirmWindow;
	import com.aristobot.admin.windows.LoadWindow;
	import com.aristobot.admin.windows.NotificationWindow;
	
	import flash.display.DisplayObjectContainer;
	
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import spark.events.PopUpEvent;

	public class AlertManager
	{
		private static var windowContainer:DisplayObjectContainer;
		private static var windowQueue:ArrayList;
				
		public static var cancelLoadFunction:Function;
		
		{
			windowContainer = FlexGlobals.topLevelApplication as DisplayObjectContainer;
			windowQueue = new ArrayList();
		}

		public static function displayNotificaitonWindow(alert:String,callback:Function=null, closeEnabled:Boolean=false, s:Boolean=false):void
		{

			var window:NotificationWindow = new NotificationWindow();
			window.label = alert;
			window.closeEnabled = closeEnabled;
			
			if (callback != null){
				window.addEventListener(NotificationWindow.OK, callback, false, 0, true);
			}
			
			openWindow(window);

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
			
			openWindow(window);
		}
		
		public static function displayCustomWindow(window:AlertWindow):void
		{
			openWindow(window);
		}
		
		protected static function openWindow(window:AlertWindow):void
		{
			windowQueue.addItem(window);
			window.open(windowContainer, true);
			window.addEventListener(PopUpEvent.CLOSE, onWindowClose, false, 0, true); 
			PopUpManager.centerPopUp(window);
		}
		
		protected static function onWindowClose(event:PopUpEvent):void
		{
			windowQueue.removeItem(event.target);
		}
		

		public static function closeAllWindows():void
		{
			for each (var window:AlertWindow in windowQueue.source){
				window.close();
			}			
		}
		
	}
}