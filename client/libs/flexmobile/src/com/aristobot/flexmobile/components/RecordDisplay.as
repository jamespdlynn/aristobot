package com.aristobot.flexmobile.components
{
	import com.aristobot.data.ApplicationUser;
	import com.aristobot.data.Opponent;
	
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	import mx.core.UIComponent;

	[Style(name="amountFontSize", type="Number", inherit="no")]
	[Style(name="labelFontSize", type="Number", inherit="no")]
	[Style(name="horizontalGap", type="Number", inherit="no")]
	[Style(name="paddingLeft", type="Number", inherit="no")]
	[Style(name="paddingRight", type="Number", inherit="no")]
	public class RecordDisplay extends UIComponent
	{
		protected var winItem:RecordDisplayItem;
		protected var lossItem:RecordDisplayItem;
		protected var drawItem:RecordDisplayItem;
		
		protected var dataChanged:Boolean;
		protected var isOpponent:Boolean;
		
		protected var _user:ApplicationUser;
						
		
		public function RecordDisplay()
		{
			super();
			cacheAsBitmap = true;
		}

		public function set user(value:ApplicationUser):void
		{
			_user = value;
			
			dataChanged = true;
			isOpponent = false;
			
			invalidateProperties();
		}
		
		public function set opponent(value:Opponent):void
		{
			_user = new ApplicationUser();
			_user.wins = value.winsAgainst;
			_user.losses = value.lossesAgainst;
			_user.ties = value.tiesAgainst;
						
			dataChanged = true;
			isOpponent = true;
			
			invalidateProperties();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if (!winItem)
			{
				var amountFontSize:int = getStyle("amountFontSize");
				var labelFontSize:int = getStyle("labelFontSize");
				
				winItem = new RecordDisplayItem(amountFontSize, labelFontSize, 0x41AF0A, true);
				winItem.filters = [new DropShadowFilter(4, 45, 0.5)];
				
				lossItem = new RecordDisplayItem(amountFontSize, labelFontSize, 0xDF1B1B, true);
				lossItem.filters = [new DropShadowFilter(4, 45, 0.5)];
				
				drawItem = new RecordDisplayItem(amountFontSize, labelFontSize, 0xc27b20, true);
				drawItem.filters = [new DropShadowFilter(4, 45, 0.5)];
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (dataChanged)
			{
				dataChanged = false;
				
				if (!_user)
				{
					winItem.amount = 0;
					lossItem.amount = 0;
					drawItem.amount = 0;
					
					if (contains(winItem)){
						removeChild(winItem);
					}
					
					if (contains(lossItem)){
						removeChild(lossItem);
					}
					
					if (contains(drawItem)){
						removeChild(drawItem);
					}
				}
				else
				{
					winItem.label = (isOpponent) ? "Wins vs" : "Wins";
					lossItem.label = (isOpponent) ? "Losses vs" : "Losses";
					drawItem.label = (isOpponent) ? "Draws vs" : "Draws";
					
					winItem.amount = _user.wins;
					lossItem.amount = _user.losses;
					drawItem.amount = _user.ties;
					
					if (!contains(winItem)){
						addChild(winItem);
					}
					if (!contains(lossItem)){
						addChild(lossItem);
					}
					if (!contains(drawItem)){
						addChild(drawItem);
					}
					
				}
				
				

				invalidateSize();
				invalidateDisplayList();
			}
		}
		
		
		override protected function measure():void
		{
			var paddingLeft:Number = getStyle("paddingLeft");
			var paddingRight:Number = getStyle("paddingRight");
			var horizontalGap:Number = getStyle("horizontalGap");
			
			measuredWidth = winItem.getExplicitOrMeasuredWidth() + lossItem.getExplicitOrMeasuredWidth() + drawItem.getExplicitOrMeasuredWidth() + paddingLeft + paddingRight + (horizontalGap*2);
			measuredHeight = Math.max(Math.max(winItem.getExplicitOrMeasuredHeight(), lossItem.getExplicitOrMeasuredHeight()), drawItem.getExplicitOrMeasuredHeight());
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var paddingLeft:Number = getStyle("paddingLeft");
			var horizontalGap:Number = getStyle("horizontalGap");
			
			winItem.x = paddingLeft;
			winItem.y = 0;
		
			lossItem.x = winItem.getExplicitOrMeasuredWidth() + horizontalGap;
			lossItem.y = 0;

			drawItem.x = lossItem.x + lossItem.getExplicitOrMeasuredWidth() + horizontalGap;
			drawItem.y = 0;
	
		}
	}
}