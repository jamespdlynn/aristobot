package com.aristobot.flexmobile.components.windows
{
	import com.aristobot.flexmobile.model.SoundManager;
	import com.aristobot.flexmobile.model.ViewController;
	import com.aristobot.flexmobile.skins.AlertWindowSkin;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	
	import spark.components.SkinnablePopUpContainer;
	
	[Style(name="backgroundImage", inherit="inherit", type="Class")]
	[Style(name="borderColor", inherit="inherit", type="uint")]
	[Style(name="borderThickness", inherit="inherit", type="uint")]
	[Style(name="padding", inherit="inherit", type="uint")]
	[Style(name="cornerRadius", inherit="inherit", type="uint")]
	public class AlertWindow extends SkinnablePopUpContainer
	{
	
		[SkinPart(required="false")]
		public var closeButton:DisplayObject;
				
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
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			
			super.partAdded(partName, instance);
			
			if (instance == closeButton){
				closeButton.visible = _closeEnabled;
				closeButton.addEventListener(MouseEvent.CLICK, closeClickHandler, false, 0, true);
			}
		}
		
		override public function open(owner:DisplayObjectContainer, modal:Boolean=false):void{
			maxWidth = owner.width*0.9;
			maxHeight =  owner.height*0.9;
			
			invalidateDisplayList();
			invalidateSize();
			
			super.open(owner, modal);
		}
		
		protected function closeClickHandler(event:MouseEvent):void
		{
			SoundManager.playSound(SoundManager.CLICK);
			close();
		}
		
	}
}