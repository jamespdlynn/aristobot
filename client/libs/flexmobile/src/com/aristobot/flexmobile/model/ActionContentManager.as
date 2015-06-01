package com.aristobot.flexmobile.model
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	
	import spark.components.BusyIndicator;
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.ViewNavigatorApplication;
	import spark.primitives.BitmapImage;

	public class ActionContentManager
	{
		private static var spinnerGroup:Group;
		
		private static var profileGroup:Group;
		private static var profileButton:Button;
		private static var settingsIcon:BitmapImage;
				
		private static var application:ViewNavigatorApplication;
		
		private static var iconURL:String;
		
		private static var _isLoading:Boolean;
		public static function isLoading():Boolean{
			return _isLoading;
		}
		
		private static var placeHolder:Group;
		
		private static var contentSize:Number;
		private static var contentHeight:Number;
				
		protected static var vm:ViewModel = ViewModel.getInstance();
		
		protected static var homeTimer:Timer;
		
		public static var bitmapData:BitmapData;
		
		public static function setUp():void
		{
			application = FlexGlobals.topLevelApplication as ViewNavigatorApplication;
			application.actionContent = new Array();
			
			contentSize = (vm.applicationDPI == 320) ? 92 : 84;
			
			profileGroup = new Group();
			
			profileGroup.width = contentSize;
			profileGroup.height = contentSize;
			
			application.actionContent = [profileGroup];

			createSettingsIcon();
		}
		
		public static function startLoading():void
		{
			if (!spinnerGroup){
				createSpinnerGroup();		
			}
			
			if (!_isLoading){
				application.actionContent = [spinnerGroup];
				_isLoading = true;
			}
		}
		
		public static function stopLoading():void
		{
			application.actionContent = [profileGroup];
			_isLoading = false;
		}
		

		private static function createSpinnerGroup():void
		{
			spinnerGroup = new Group();
			spinnerGroup.width = contentSize;
			spinnerGroup.height = contentSize;
			
			var spinner:BusyIndicator = new BusyIndicator();
			spinner.width = contentSize-36;
			spinner.height = contentSize-36;
			spinner.verticalCenter = 0;
			spinner.horizontalCenter = 0;

			spinnerGroup.addElement(spinner);
		}
		
		private static function createSettingsIcon():void
		{
			profileButton = new Button();
			profileButton.width = contentSize;
			profileButton.height = contentSize;
			profileButton.addEventListener(MouseEvent.CLICK, buttonClick, false, 0, true);
			
			settingsIcon = new BitmapImage();
			settingsIcon.width = contentSize-24;
			settingsIcon.height = contentSize-24;
			settingsIcon.verticalCenter = 0;
			settingsIcon.horizontalCenter = 0;
			
			settingsIcon.source = ImageManager.SettingsIcon;

			profileGroup.addEventListener(MouseEvent.MOUSE_DOWN, profileGroupDownHandler, false, 0, true);
			profileGroup.addEventListener(MouseEvent.MOUSE_UP, profileGroupUpHandler, false, 0, true);
			profileGroup.addEventListener(MouseEvent.MOUSE_OUT, profileGroupUpHandler, false, 0, true);
			
			profileGroup.addElement(profileButton);
			profileGroup.addElement(settingsIcon);

		}

		private static function profileGroupDownHandler(event:MouseEvent):void
		{
			settingsIcon.verticalCenter = 1;
		}
		
		private static function profileGroupUpHandler(event:MouseEvent):void
		{
			settingsIcon.verticalCenter = 0;
		}
		
		private static function buttonClick(event:Event):void
		{
			SoundManager.playSound(SoundManager.CLICK);
			AlertManager.displaySettingsWindow();
			
		}
	}
}