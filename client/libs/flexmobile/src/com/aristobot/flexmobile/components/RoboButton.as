package com.aristobot.flexmobile.components
{
	import com.aristobot.flexmobile.model.SoundManager;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.primitives.BitmapImage;
	
	public class RoboButton extends Button
	{
		
		
		public function RoboButton()
		{
			super();
			minWidth = 80;
			height = 65;
		}
		
		override protected function clickHandler(event:MouseEvent):void
		{
			super.clickHandler(event);
			SoundManager.playSound(SoundManager.CLICK);
		}
		
		
	}

}