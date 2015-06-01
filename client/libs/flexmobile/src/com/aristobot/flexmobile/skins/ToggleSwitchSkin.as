package com.aristobot.flexmobile.skins
{
	import mx.core.DPIClassification;
	
	import spark.skins.mobile.ToggleSwitchSkin;
	import spark.skins.mobile160.assets.ToggleSwitch_contentShadow;
	import spark.skins.mobile240.assets.ToggleSwitch_contentShadow;
	import spark.skins.mobile320.assets.ToggleSwitch_contentShadow;
	
	
	public class ToggleSwitchSkin extends spark.skins.mobile.ToggleSwitchSkin
	{
		private var slidingContentOverlayClass:Class;
		
		
		public function ToggleSwitchSkin()
		{
			super();
			
			switch(applicationDPI) 
			{
				case DPIClassification.DPI_320:
				{
					layoutThumbWidth = 94;
					layoutThumbHeight = 56;
					layoutStrokeWeight = 2;
					layoutBorderSize = 2;
					layoutTextShadowOffset = -2;
					layoutInnerPadding = 14;
					layoutOuterPadding = 22;
					slidingContentOverlayClass = spark.skins.mobile320.assets.ToggleSwitch_contentShadow;
					break;
				}
				case DPIClassification.DPI_240:
				{
					layoutThumbWidth = 70;
					layoutThumbHeight = 42;
					layoutStrokeWeight = 2;
					layoutBorderSize = 1;
					layoutTextShadowOffset = -1;
					layoutInnerPadding = 10;
					layoutOuterPadding = 17;
					slidingContentOverlayClass = spark.skins.mobile240.assets.ToggleSwitch_contentShadow;
					break;
				}
			}
			
			layoutCornerEllipseSize = layoutThumbHeight;
			selectedLabel = resourceManager.getString("components","toggleSwitchSelectedLabel");
			unselectedLabel =  resourceManager.getString("components","toggleSwitchUnselectedLabel");
		}
	}
}