package com.aristobot.flexmobile.renderers
{
	import com.aristobot.data.UserIcon;
	import com.aristobot.flexmobile.components.IconRank;
	import com.aristobot.flexmobile.data.IconListData;
	
	import flash.display.DisplayObject;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	
	import mx.core.FlexTextField;
	import mx.core.mx_internal;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.supportClasses.StyleableTextField;
	import spark.core.DisplayObjectSharingMode;
	import spark.core.IGraphicElement;
	import spark.core.ISharedDisplayObject;
	import spark.primitives.BitmapImage;
	
	use namespace mx_internal;
	
	[Style(name="dateStyleName", type="String", inherit="no")]
	
	public class GameItemRenderer extends ListDataItemRenderer
	{
		
		
		protected var dateText:String;
		protected var dateDisplay:StyleableTextField;
		protected var dateChanged:Boolean;
		protected var statusChanged:Boolean;
		protected var badgeChanged:Boolean;
		
		protected var badgeDisplay:BitmapImage;
		protected var rankDisplay:FlexTextField;
		
		protected var badgeNeedsValidateProperties:Boolean = false;
		protected var badgeNeedsValidateSize:Boolean = false;
		protected var badgeNeedsDisplayObjectAssignment:Boolean = false;
		
		
		override public function set data(value:Object):void
		{	
			var listData:IconListData = value as IconListData;

			dateText = (listData != null) ? listData.subLabel : null;
			
			dateChanged = true;
			statusChanged = true;
			badgeChanged = true;
			
			super.data = listData;
		}
		
		override public function styleChanged(styleName:String):void
		{
			var allStyles:Boolean = !styleName || styleName == "styleName";
			
			super.styleChanged(styleName);
			
			if (allStyles || styleName == "dateStyleName")
			{
				if (dateDisplay)
				{
					var dateStyleName:String = getStyle("dateStyleName");
					if (dateStyleName)
					{
						var styleDecl:CSSStyleDeclaration =
							styleManager.getMergedStyleDeclaration("." + dateStyleName);
						
						if (styleDecl)
						{
							dateDisplay.styleDeclaration = styleDecl;
							dateDisplay.styleChanged("dateStyleName");
						}
					}
				}
				
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (dateChanged)
			{
				dateChanged = false;
								// let's see if we need to create or remove it
				if ((dateText && dateText.length) && !dateDisplay){
					createDateDisplay();
					
				}
				else if ((!dateText || !dateText.length) && dateDisplay){
					destroyDateDipslay();
				}
				
				if (dateDisplay){
					dateDisplay.text = dateText;
				}
				
				invalidateSize();
				invalidateDisplayList();
			}
				
			if (badgeChanged){
				
				badgeChanged = false;
				var hasRank:Boolean = data && data.icon && data.icon is UserIcon && data.icon.rank > 0;
				
				if (!badgeDisplay && hasRank){
					createBadgeDisplay();
					
					
				}
				else if(badgeDisplay && !hasRank){
					destroyBadgeDisplay();
				}
				
				if (badgeDisplay){
					badgeDisplay.source = data.icon.badgeURL;
					rankDisplay.text = data.icon.rank.toString();
				}	
			
				invalidateSize();
				invalidateDisplayList();
			}
			
			if (badgeNeedsDisplayObjectAssignment)
			{
				badgeNeedsDisplayObjectAssignment = false;
				assignDisplayObject(badgeDisplay);
			}
			
			cacheAsBitmap = true;		
		}
		
		private function assignDisplayObject(bitmapImage:BitmapImage):void
		{
			if (bitmapImage)
			{
				// try using this display object first
				if (bitmapImage.setSharedDisplayObject(this))
				{
					bitmapImage.displayObjectSharingMode = DisplayObjectSharingMode.USES_SHARED_OBJECT;
				}
				else
				{
					// if we can't use this as the display object, then let's see if 
					// the icon already has and owns a display object
					var ownsDisplayObject:Boolean = (bitmapImage.displayObjectSharingMode != DisplayObjectSharingMode.USES_SHARED_OBJECT);
					
					// If the element doesn't have a DisplayObject or it doesn't own
					// the DisplayObject it currently has, then create a new one
					var displayObject:DisplayObject = bitmapImage.displayObject;
					if (!ownsDisplayObject || !displayObject)
						displayObject = bitmapImage.createDisplayObject();
					
					// Add the display object as a child
					// Check displayObject for null, some graphic elements
					// may choose not to create a DisplayObject during this pass.
					if (displayObject)
						addChild(displayObject);
					
					bitmapImage.displayObjectSharingMode = DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT;
				}
			}        
		}
		

		protected function createDateDisplay():void
		{
			dateDisplay = StyleableTextField(createInFontContext(StyleableTextField));
			dateDisplay.styleName = this;
			dateDisplay.editable = false;
			dateDisplay.selectable = false;
			dateDisplay.multiline = false;
			dateDisplay.wordWrap = false;
			
			var dateStyleName:String = getStyle("dateStyleName");
			if (dateStyleName)
			{
				var styleDecl:CSSStyleDeclaration =
					styleManager.getMergedStyleDeclaration("." + dateStyleName);
				
				if (styleDecl)
					dateDisplay.styleDeclaration = styleDecl;
			}
			
			addChild(dateDisplay);
		}
		
		

		protected function destroyDateDipslay():void
		{
			removeChild(dateDisplay);
			dateDisplay = null;
		}
		
		protected function createBadgeDisplay():void
		{
			badgeDisplay = new iconDisplayClass();
			
			badgeDisplay.contentLoader = iconContentLoader;
			badgeDisplay.fillMode = iconFillMode;
			badgeDisplay.scaleMode = iconScaleMode;
			badgeDisplay.smooth = true;
			
			badgeDisplay.parentChanged(this);
			
			rankDisplay = new FlexTextField();
			rankDisplay.selectable = false;
			rankDisplay.multiline = false;
			rankDisplay.wordWrap = false;
			
			badgeNeedsDisplayObjectAssignment = true;
			
			addChild(rankDisplay);
			
		}
		
		protected function destroyBadgeDisplay():void
		{
			// need to remove the display object
			var oldDisplayObject:DisplayObject = badgeDisplay.displayObject;
			if (oldDisplayObject)
			{ 
				// If the element created the display object
				if (badgeDisplay.displayObjectSharingMode != DisplayObjectSharingMode.USES_SHARED_OBJECT &&
					oldDisplayObject.parent == this)
				{
					removeChild(oldDisplayObject);
				}
			}
			
			badgeDisplay.parentChanged(null);
			badgeDisplay = null;
			
			removeChild(rankDisplay);
			rankDisplay = null;
		}
		
		
		
		override public function invalidateGraphicElementSharing(element:IGraphicElement):void
		{
			if (element == badgeDisplay)
				badgeNeedsDisplayObjectAssignment = true;
			
			super.invalidateGraphicElementSharing(element);
		}
		
		override public function invalidateGraphicElementProperties(element:IGraphicElement):void
		{
			if (element == badgeDisplay)
				badgeNeedsValidateProperties = true;
			
			super.invalidateGraphicElementProperties(element);
		}
		
		override public function invalidateGraphicElementSize(element:IGraphicElement):void
		{
			
			if (element == badgeDisplay)
				badgeNeedsValidateSize = true;
			
			super.invalidateGraphicElementSize(element);
		}
		
		override public function validateDisplayList():void
		{
			
			if (badgeDisplay && 
				badgeDisplay.displayObject is ISharedDisplayObject && 
				ISharedDisplayObject(badgeDisplay.displayObject).redrawRequested)
			{
				var redrawBadge:Boolean = true;
			}
			
			
			super.validateDisplayList();
						
			if (redrawBadge){
				ISharedDisplayObject(badgeDisplay.displayObject).redrawRequested = false;
				badgeDisplay.validateDisplayList();
			}
		}
		
		override public function validateProperties():void
		{
			super.validateProperties();
			
			
			if (badgeNeedsValidateProperties)
			{
				badgeNeedsValidateProperties = false;
				if (badgeDisplay)
					badgeDisplay.validateProperties();
			}
		}
		
		override public function validateSize(recursive:Boolean=false):void
		{
			if (badgeNeedsValidateSize)
			{
				badgeNeedsValidateSize = false;
				if (badgeDisplay)
					badgeDisplay.validateSize();
			}
			
			
			super.validateSize(recursive);
		}
		
		
		override protected function measure():void
		{
			
			var myMeasuredWidth:Number = 0;
			var myMeasuredHeight:Number = 0;
			var myMeasuredMinWidth:Number = 0;
			var myMeasuredMinHeight:Number = 0;
			
			var numHorizontalSections:int = 0;
			if (iconDisplay)
				numHorizontalSections++;
			
			if (decoratorDisplay)
				numHorizontalSections++;
			
			if (labelDisplay || messageDisplay || dateDisplay)
				numHorizontalSections++;
			
			var paddingAndGapWidth:Number = getStyle("paddingLeft") + getStyle("paddingRight");
			if (numHorizontalSections > 0)
				paddingAndGapWidth += (getStyle("horizontalGap") * (numHorizontalSections - 1));
			
			var hasLabel:Boolean = labelDisplay && labelDisplay.text != "";
			var hasDate:Boolean = dateDisplay && dateDisplay.text != "";
			var hasMessage:Boolean = messageDisplay && messageDisplay.text != "";
			
			var verticalGap:Number =  getStyle("verticalGap");
			
			
			var paddingHeight:Number = getStyle("paddingTop") + getStyle("paddingBottom");
			
			var myIconWidth:Number = 0;
			var myIconHeight:Number = 0;
			if (iconDisplay)
			{
				myIconWidth = (isNaN(iconWidth) ? getElementPreferredWidth(iconDisplay) : iconWidth);
				myIconHeight = (isNaN(iconHeight) ? getElementPreferredHeight(iconDisplay) : iconHeight);
				
				myMeasuredWidth += myIconWidth;
				myMeasuredMinWidth += myIconWidth;
				myMeasuredHeight = Math.max(myMeasuredHeight, myIconHeight);
				myMeasuredMinHeight = Math.max(myMeasuredMinHeight, myIconHeight);
			}
			
			var decoratorWidth:Number = 0;
			var decoratorHeight:Number = 0;
			
			if (decoratorDisplay)
			{
				decoratorWidth = getElementPreferredWidth(decoratorDisplay);
				decoratorHeight = getElementPreferredHeight(decoratorDisplay);
				
				myMeasuredWidth += decoratorWidth;
				myMeasuredMinWidth += decoratorWidth;
				myMeasuredHeight = Math.max(myMeasuredHeight, decoratorHeight);
				myMeasuredMinHeight = Math.max(myMeasuredHeight, decoratorHeight);
			}
			
			var labelWidth:Number = 0;
			var labelHeight:Number = 0;
			var dateWidth:Number = 0;
			var dateHeight:Number = 0;
			var messageWidth:Number = 0;
			var messageHeight:Number = 0;
			
			var labelCount:int = 0;
			
			if (hasLabel)
			{
				if (labelDisplay.isTruncated)
					labelDisplay.text = labelText;
				
				labelWidth = getElementPreferredWidth(labelDisplay);
				labelHeight = getElementPreferredHeight(labelDisplay);
				
				labelCount++;
			}
			
			if (hasDate)
			{
				if (dateDisplay.isTruncated)
					dateDisplay.text = dateText;
				
				dateWidth = getElementPreferredWidth(dateDisplay);
				dateHeight = getElementPreferredHeight(dateDisplay);
				
				labelCount++;
			}
			
			if (hasMessage)
			{
				var messageDisplayEstimatedWidth:Number = oldUnscaledWidth - paddingAndGapWidth - myIconWidth - decoratorWidth;
				
				setElementSize(messageDisplay, messageDisplayEstimatedWidth, NaN);
				
				messageWidth = getElementPreferredWidth(messageDisplay);
				messageHeight = getElementPreferredHeight(messageDisplay);
				
				labelCount++;
			}
			
			verticalGap *= (labelCount-1);
		
			myMeasuredWidth += Math.max(labelWidth, dateWidth, messageWidth);
			myMeasuredHeight = Math.max(myMeasuredHeight, labelHeight + verticalGap + messageHeight + verticalGap );
			
			myMeasuredWidth += paddingAndGapWidth;
			myMeasuredMinWidth += paddingAndGapWidth;
			
			myMeasuredHeight += paddingHeight;
			myMeasuredMinHeight += paddingHeight;
			
			// now set the local variables to the member variables.
			measuredWidth = myMeasuredWidth
			measuredHeight = myMeasuredHeight;
			
			measuredMinWidth = myMeasuredMinWidth;
			measuredMinHeight = myMeasuredMinHeight;
			
			
		}
		
		override protected function layoutContents(unscaledWidth:Number,
												   unscaledHeight:Number):void
		{
			var iconWidth:Number = 0;
			var iconHeight:Number = 0;
			var decoratorWidth:Number = 0;
			var decoratorHeight:Number = 0;
			
			var hasLabel:Boolean = labelDisplay && labelDisplay.text != "";
			var hasMessage:Boolean = messageDisplay && messageDisplay.text != "";
			var hasDate:Boolean = dateDisplay && dateDisplay.text != "";
			
			var paddingLeft:Number   = getStyle("paddingLeft");
			var paddingRight:Number  = getStyle("paddingRight");
			var paddingTop:Number    = getStyle("paddingTop");
			var paddingBottom:Number = getStyle("paddingBottom");
			var horizontalGap:Number = getStyle("horizontalGap");
			var verticalAlign:String = getStyle("verticalAlign");
			var verticalGap:Number   = (hasLabel && (hasDate || hasMessage)) ? getStyle("verticalGap") : 0;
			
			var vAlign:Number;
			if (verticalAlign == "top")
				vAlign = 0;
			else if (verticalAlign == "bottom")
				vAlign = 1;
			else 
				vAlign = 0.5;

			var viewWidth:Number  = unscaledWidth  - paddingLeft - paddingRight;
			var viewHeight:Number = unscaledHeight - paddingTop  - paddingBottom;
						
			if (iconDisplay)
			{
				setElementSize(iconDisplay, this.iconWidth, this.iconHeight);
				
				iconWidth = iconDisplay.getLayoutBoundsWidth();
				iconHeight = iconDisplay.getLayoutBoundsHeight();
				
				var iconDisplayY:Number = Math.round(vAlign * (viewHeight - iconHeight)) + paddingTop;
				setElementPosition(iconDisplay, paddingLeft, iconDisplayY);
				
				
			}
			
			if (badgeDisplay)
			{
				var badgeWidth:Number = getElementPreferredWidth(badgeDisplay);
				var badgeHeight:Number = getElementPreferredHeight(badgeDisplay);
				
				setElementSize(badgeDisplay, badgeWidth, badgeHeight);
				
				var badgeX:Number = paddingLeft-4;
				var badgeY:Number = iconDisplayY + iconHeight - badgeHeight+8;
				
				badgeDisplay.x = badgeX;
				badgeDisplay.y = badgeY;
				
				if (rankDisplay)
				{				
					var size:Number = Math.ceil(badgeWidth/2);
					size += (rankDisplay.text && rankDisplay.text.length > 1) ? 1 : 2;
					
					var tf:TextFormat = new TextFormat();
					tf.size = size;
					tf.bold = true;
					tf.color = 0xFFFFFF;
					
					rankDisplay.setTextFormat(tf);
					rankDisplay.filters = [new DropShadowFilter(1, -45, 0x000000, 1, 4, 4, 2)];
					
					rankDisplay.x = Math.round(badgeX + (badgeWidth/2) - (rankDisplay.textWidth/2)-2);
					rankDisplay.y = Math.round(badgeY + (badgeHeight/2) - (rankDisplay.textHeight/2)-1);
				}
			}
			
			if (decoratorDisplay)
			{
				decoratorWidth = getElementPreferredWidth(decoratorDisplay);
				decoratorHeight = getElementPreferredHeight(decoratorDisplay);
				
				setElementSize(decoratorDisplay, decoratorWidth, decoratorHeight);
				
				var decoratorY:Number = Math.round(0.5 * (viewHeight - decoratorHeight)) + paddingTop;
				setElementPosition(decoratorDisplay, unscaledWidth - paddingRight - decoratorWidth, decoratorY);
			}


			var labelComponentsViewWidth:Number = viewWidth - iconWidth - decoratorWidth;
			
			if (iconDisplay)
				labelComponentsViewWidth -= horizontalGap;
			if (decoratorDisplay)
				labelComponentsViewWidth -= horizontalGap;
			
			var labelComponentsX:Number = paddingLeft;
			if (iconDisplay)
				labelComponentsX += iconWidth + horizontalGap;
			
			var labelTextHeight:Number = 0;
			var dateTextHeight:Number;
			
			if (hasLabel)
			{
				if (labelDisplay.isTruncated)
					labelDisplay.text = labelText;
				
				labelDisplay.commitStyles();
				
				labelTextHeight = getElementPreferredHeight(labelDisplay);
			}
			
			if (hasMessage){				
				messageDisplay.commitStyles();
			}
			
			if (hasDate){
				dateDisplay.commitStyles();
				dateTextHeight = getElementPreferredHeight(dateDisplay);
			}
			
			var labelWidth:Number = 0;
			var labelHeight:Number = 0;
			var messageWidth:Number = 0;
			var messageHeight:Number = 0;
			var dateWidth:Number = 0;
			var dateHeight:Number;
			
			if (hasLabel)
			{
				labelWidth = Math.max(labelComponentsViewWidth, 0);
				labelHeight = labelTextHeight;
				
				if (labelWidth == 0)
					setElementSize(labelDisplay, NaN, 0);
				else
					setElementSize(labelDisplay, labelWidth, labelHeight);
				
				labelDisplay.truncateToFit();
			}
			
			
			if (hasDate)
			{
				dateWidth = Math.max(labelComponentsViewWidth, 0);
				dateHeight = dateTextHeight;
				
				if (dateWidth == 0)
					setElementSize(dateDisplay, NaN, 0);
				else
					setElementSize(dateDisplay, dateWidth, dateHeight);
				
				dateDisplay.truncateToFit();
			}
			
			if (hasMessage)
			{
				messageWidth = Math.max(labelComponentsViewWidth, 0);
			
				if (messageWidth == 0){
					setElementSize(messageDisplay, NaN, 0);
				}
				else
				{
					var oldPreferredMessageHeight:Number = getElementPreferredHeight(messageDisplay);
					
					oldUnscaledWidth = unscaledWidth;

					setElementSize(messageDisplay, messageWidth, oldPreferredMessageHeight);
					
					var newPreferredMessageHeight:Number = getElementPreferredHeight(messageDisplay);
					
					
					if (oldPreferredMessageHeight != newPreferredMessageHeight)
						invalidateSize();
					
					messageHeight = newPreferredMessageHeight;
				}
				
		
			}
		
			
			var totalHeight:Number = 0;
			var labelComponentsY:Number = 0; 
			
			var labelAlignmentHeight:Number = 0; 
			var dateAlignmentHeight:Number = 0; 
			var messageAlignmentHeight:Number = 0; 
			
			
			if (hasLabel)
				labelAlignmentHeight = getElementPreferredHeight(labelDisplay);
			if (hasDate)
				dateAlignmentHeight =  getElementPreferredHeight(dateDisplay);
			if (hasMessage)
				messageAlignmentHeight = getElementPreferredHeight(messageDisplay);
			
			totalHeight = labelAlignmentHeight;
			if (hasDate){
				totalHeight +=dateAlignmentHeight + verticalGap;   
			}
			if(hasMessage){
				totalHeight += messageAlignmentHeight + verticalGap;
			}
			
			labelComponentsY = Math.round(vAlign * (viewHeight - totalHeight)) + paddingTop;
			
			if (labelDisplay)
				setElementPosition(labelDisplay, labelComponentsX, labelComponentsY);
			
			var dateY:Number = labelComponentsY + labelAlignmentHeight + verticalGap;
			var messageY:Number = dateY + dateAlignmentHeight + verticalGap;
			if (dateDisplay){
				setElementPosition(dateDisplay, labelComponentsX, dateY);
			}
			if (messageDisplay){
				setElementPosition(messageDisplay, labelComponentsX, messageY);
			}
		}
		
	}
	
	
}