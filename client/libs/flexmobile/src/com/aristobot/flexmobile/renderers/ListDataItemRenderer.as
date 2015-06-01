package com.aristobot.flexmobile.renderers
{
	import com.aristobot.data.UserIcon;
	import com.aristobot.flexmobile.data.IconListData;
	import com.aristobot.flexmobile.model.ImageManager;
	import com.aristobot.flexmobile.model.ViewModel;
	
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	import mx.core.mx_internal;
	import mx.graphics.BitmapFillMode;
	
	import spark.components.IconItemRenderer;
	
	use namespace mx_internal;

	public class ListDataItemRenderer extends IconItemRenderer
	{				
		public function ListDataItemRenderer()
		{
			super();
			
			labelField = "label";
			messageField = "message";			
			iconFunction = function():*{
				if (data.icon is UserIcon){
					return (data.icon as UserIcon).iconURL;
				}
				
				return data.icon;
			}

			iconPlaceholder = ImageManager.DefaultUserIcon;
			iconContentLoader= ViewModel.getInstance().iconCache;	
			
			
			iconFillMode = BitmapFillMode.CLIP;
			iconWidth = 72;
			iconHeight = 72;
									
			setStyle("alternatingItemColors",null);
		}
		
		

		override public function set data(value:Object):void
		{
			var listData:IconListData = value as IconListData;
			decorator = (listData != null) ? listData.decorator : null;			
			super.data = listData;
		}
		
		override protected function drawBackground(unscaledWidth:Number, 
										  unscaledHeight:Number):void
		{
			// figure out backgroundColor
			var backgroundColor:*;
			var downColor:* = getStyle("downColor");
			var drawBackground:Boolean = true;
			var opaqueBackgroundColor:* = undefined;
			
			if (down && downColor !== undefined)
			{
				backgroundColor = downColor;
			}
			else if (selected)
			{
				backgroundColor = getStyle("selectionColor");
			}
			else if (showsCaret)
			{
				backgroundColor = getStyle("selectionColor");
			}
			else
			{
				var alternatingColors:Array;
				var alternatingColorsStyle:Object = getStyle("alternatingItemColors");
				
				if (alternatingColorsStyle)
					alternatingColors = (alternatingColorsStyle is Array) ? (alternatingColorsStyle as Array) : [alternatingColorsStyle];
				
				if (alternatingColors && alternatingColors.length > 0)
				{
					// translate these colors into uints
					styleManager.getColorNames(alternatingColors);
					
					backgroundColor = alternatingColors[itemIndex % alternatingColors.length];
				}
				else
				{
					// don't draw background if it is the contentBackgroundColor. The
					// list skin handles the background drawing for us. 
					drawBackground = false;
				}
				
			} 
			
			// draw backgroundColor
			// the reason why we draw it in the case of drawBackground == 0 is for
			// mouse hit testing purposes
			graphics.beginFill(backgroundColor, drawBackground ? 1 : 0);
			graphics.lineStyle();
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill();
			
			var colors:Array = [0xFFFFFF, backgroundColor ];
			var alphas:Array = [.1, .2];
			var ratios:Array = [0, 127];
			var matrix:Matrix = new Matrix();
			
			// gradient overlay
			matrix.createGradientBox(unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0 );
			graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill();
			
			// Draw the separator for the item renderer
			drawBorder(unscaledWidth, unscaledHeight);
			
			opaqueBackground = opaqueBackgroundColor;
		}
		
		override protected function createIconDisplay():void
		{
			super.createIconDisplay();
			iconDisplay.smooth = true;
		}
		
		override protected function createDecoratorDisplay():void
		{
			super.createDecoratorDisplay();
			decoratorDisplay.smooth = true;
		}
		
	}
		
	
	
}