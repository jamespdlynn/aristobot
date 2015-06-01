package com.aristobot.flexmobile.components
{
	import com.aristobot.data.ApplicationUser;
	import com.aristobot.data.Opponent;
	
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	import mx.core.UIComponent;

	public class RatingsDisplay extends RecordDisplay
	{
		
		public function RatingsDisplay()
		{
			super();
		}
		
		override protected function createChildren():void
		{			
			var amountFontSize:int = getStyle("amountFontSize");
			var labelFontSize:int = getStyle("labelFontSize");
			
			
			winItem = new RecordDisplayItem(amountFontSize, labelFontSize, 0xC0C0C0);
			winItem.label = "ELO Rating";
			winItem.filters = [new GlowFilter(0xFFFFFF, 1, 4, 4, 2, 1, true), new DropShadowFilter(6, 45, 0.7)];
			
			super.createChildren();
		}
		
		override protected function commitProperties():void
		{
			if (dataChanged)
			{
				dataChanged = false;
				
				if (!_user){
					winItem.amount = 0;
					
					if ( contains(winItem)){
						removeChild(winItem);
					}
				}
				else{
					winItem.amount = _user.rating;
					
					if (!contains(winItem)){
						addChild(winItem);
					}
				}
				
				invalidateSize();
				invalidateDisplayList();
			}
			
			super.commitProperties();
		}
		
		
		override protected function measure():void
		{
			var paddingLeft:Number = getStyle("paddingLeft");
			var paddingRight:Number = getStyle("paddingRight");
			
			measuredWidth = winItem.getExplicitOrMeasuredWidth() + paddingLeft + paddingRight;
			measuredHeight = winItem.getExplicitOrMeasuredHeight();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var paddingLeft:Number = getStyle("paddingLeft");
			
			winItem.x = paddingLeft;
			winItem.y = 0;
	
		}
	}
}