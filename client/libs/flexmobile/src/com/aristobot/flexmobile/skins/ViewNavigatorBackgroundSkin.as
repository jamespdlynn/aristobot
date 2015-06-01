package com.aristobot.flexmobile.skins
{
	import mx.graphics.BitmapFillMode;
	
	import spark.components.Image;
	import spark.skins.mobile.ViewNavigatorSkin;
	
	public class ViewNavigatorBackgroundSkin extends ViewNavigatorSkin
	{
		
		public var backgroundImage:Image;
		

		public function ViewNavigatorBackgroundSkin()
		{
			super();
		}
		
		override protected function createChildren():void{
			
			
			backgroundImage = new Image();
			backgroundImage.source = "Background.png";
			backgroundImage.fillMode = BitmapFillMode.REPEAT;
			
			addChild(backgroundImage);
			
			
			super.createChildren();
			
		}
		
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
		{
			
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			if (backgroundImage.includeInLayout){
				backgroundImage.setLayoutBoundsSize(contentGroup.getLayoutBoundsWidth(), contentGroup.getLayoutBoundsHeight());
				backgroundImage.setLayoutBoundsPosition(contentGroup.getLayoutBoundsX(), contentGroup.getLayoutBoundsY());
			}
		}

	}
}