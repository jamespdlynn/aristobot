package com.aristobot.admin.windows
{
	
	import com.aristobot.admin.skins.AlertWindowSkin;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	
	import spark.components.SkinnablePopUpContainer;
	
	[Style(name="backgroundColor", inherit="inherit", type="uint")]
	[Style(name="borderColor", inherit="inherit", type="uint")]
	[Style(name="borderThickness", inherit="inherit", type="uint")]
	[Style(name="padding", inherit="inherit", type="uint")]
	[Style(name="cornerRadius", inherit="inherit", type="uint")]
	public class AlertWindow extends SkinnablePopUpContainer
	{
	
		[Bindable]
		[SkinPart(required="false")]
		public var closeButton:DisplayObject;
		
		public static const CLOSE_CLICKED:String = "closeClicked";
				
		protected var _closeEnabled:Boolean = false;
		public function get closeEnabled():Boolean{
			return _closeEnabled;
		}
		public function set closeEnabled(value:Boolean):void{
			_closeEnabled = value;
			if (closeButton) closeButton.visible = _closeEnabled;
		}

		public function AlertWindow()
		{
			super();
			
			setStyle("skinClass",AlertWindowSkin);
			maxWidth = FlexGlobals.topLevelApplication.width*0.9;
			cacheAsBitmap=true;
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			
			super.partAdded(partName, instance);
			
			if (instance == closeButton){
				closeButton.visible = _closeEnabled;
				closeButton.addEventListener(MouseEvent.CLICK, closeClickHandler, false, 0, true);
			}
		}
		
		protected function closeClickHandler(event:MouseEvent):void
		{
			dispatchEvent(new Event(CLOSE_CLICKED));
			close();
		}
		
	}
}