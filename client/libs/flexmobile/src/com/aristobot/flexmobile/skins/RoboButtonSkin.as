package com.aristobot.flexmobile.skins
{
	import spark.skins.mobile.ButtonSkin;
	
	public class RoboButtonSkin extends ButtonSkin
	{
		
		private var updateIcon:Boolean;
		
		public function RoboButtonSkin()
		{
			super();
		}
		
		override protected function setIcon(icon:Object):void{
			
			if (icon){
				updateIcon = true;	
			}
			
			super.setIcon(icon);
		}
			
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			
			if (updateIcon){
				for(var i:int = 0; i < this.numChildren; i++){
					var child:* = this.getChildAt(i);
					
					if (child.hasOwnProperty("smoothing")){
						child.smoothing = true;
					}else if (child.hasOwnProperty("smooth")){
						child.smooth = true;
					}
				}
				
				updateIcon = false;
			}
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);

		}
	}
}