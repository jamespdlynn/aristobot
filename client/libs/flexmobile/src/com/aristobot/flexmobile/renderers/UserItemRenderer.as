package com.aristobot.flexmobile.renderers
{
	import com.aristobot.data.ApplicationUser;
	import com.aristobot.data.Opponent;
	import com.aristobot.data.User;
	import com.aristobot.flexmobile.components.RatingsDisplay;
	import com.aristobot.flexmobile.components.RecordDisplay;
	import com.aristobot.flexmobile.data.IconListData;
	
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	
	import mx.core.FlexTextField;
	import mx.core.mx_internal;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.supportClasses.StyleableTextField;
	
	use namespace mx_internal;
	
	[Style(name="dateStyleName", type="String", inherit="no")]
	[Style(name="recordStyleName", type="String", inherit="no")]
	
	public class UserItemRenderer extends ListDataItemRenderer
	{
		
		protected var dateText:String;
		protected var dateDisplay:StyleableTextField;
		protected var dateChanged:Boolean;
		
		protected var rankDisplay:FlexTextField;
		protected var rankDisplayNeedsAssignment:Boolean;
		
		protected var recordDisplay:RecordDisplay;
		
		protected var user:User;
		protected var userChanged:Boolean;
		
		protected var _useRatingsDisplay:Boolean = false;
		public function set useRatingsDisplay(value:Boolean):void{
			_useRatingsDisplay = value;
		}
		
		
		override public function set data(value:Object):void
		{
			var listData:IconListData = value as IconListData;
			
			var newDateText:String = (listData) ? listData.subLabel : null;
			var newUser:User = (listData) ? listData.dataObj as User : null;
			
			dateChanged = dateText != newDateText;
			userChanged = user != newUser;
			
			dateText = newDateText;
			user = newUser;
			
			super.data = listData;
		}
		
		override public function styleChanged(styleName:String):void
		{
			var allStyles:Boolean = !styleName || styleName == "styleName";
			var styleDecl:CSSStyleDeclaration;
			super.styleChanged(styleName);
			
			if (allStyles || styleName == "dateStyleName")
			{
				if (dateDisplay)
				{
					var dateStyleName:String = getStyle("dateStyleName");
					if (dateStyleName)
					{
						styleDecl = styleManager.getMergedStyleDeclaration("." + dateStyleName);
						
						if (styleDecl)
						{
							dateDisplay.styleDeclaration = styleDecl;
							dateDisplay.styleChanged("dateStyleName");
						}
					}
	
				}
			}
			
			if (allStyles || styleName == "recordStyleName")
			{
				
				if (recordDisplay)
				{
					var recordStyleName:String = getStyle("recordStyleName");
					if (recordStyleName)
					{
						styleDecl = styleManager.getMergedStyleDeclaration("." + recordStyleName);
						
						if (styleDecl){
							recordDisplay.styleDeclaration = styleDecl;
							recordDisplay.styleChanged("recordStyleName");
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
					destroyDateDisplay();
				}
				
				
				if (dateDisplay){
					dateDisplay.text = dateText;
				}
				
				invalidateSize();
				invalidateDisplayList();
			}
			
			if (userChanged)
			{
				if (hasApp() && !recordDisplay){
					createRecordDisplay();
				}
				else if (!hasApp() && recordDisplay){
					destroyRecordDisplay();
				}
				
				if (recordDisplay)
				{
					if (user is Opponent){
						recordDisplay.opponent =  user as Opponent;
					}
					if (user is ApplicationUser){
						recordDisplay.user = user as ApplicationUser;
					}
				}
				
				if (rankDisplay && hasRank()){
					rankDisplay.text = user.icon.rank.toString();
				}
				
				if (rankDisplayNeedsAssignment){
					addChild(rankDisplay);
					rankDisplayNeedsAssignment = false;
				}
				
				this.alpha = (!user || user.hasApplication) ? 1 : 0.5;
				
			}
			
			
		}
		
		private function hasRank():Boolean{
			return user && user.icon && user.icon.rank > 0;
		}
		
		private function hasApp():Boolean{
			return user && user.hasApplication;
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
		
		

		protected function destroyDateDisplay():void
		{
			removeChild(dateDisplay);
			dateDisplay = null;
		}
				
		protected function createRecordDisplay():void
		{
			recordDisplay = (_useRatingsDisplay) ? new RatingsDisplay() : new RecordDisplay();
			
			var recordStyleName:String = getStyle("recordStyleName");
			if (recordStyleName)
			{
				var styleDecl:CSSStyleDeclaration =
					styleManager.getMergedStyleDeclaration("." + recordStyleName);
				
				if (styleDecl)
					recordDisplay.styleDeclaration = styleDecl;
			}
						
			addChild(recordDisplay);
		}
		
		protected function destroyRecordDisplay():void
		{
			removeChild(recordDisplay);
			recordDisplay = null;
		}
		
		override protected function createDecoratorDisplay():void
		{
			super.createDecoratorDisplay();
			decoratorDisplay.contentLoader = iconContentLoader;
			
			if (hasRank() && !rankDisplay)
			{
				rankDisplay = new FlexTextField();
				rankDisplay.selectable = false;
				rankDisplay.multiline = false;
				rankDisplay.wordWrap = false;
				
				rankDisplayNeedsAssignment = true;
			}
		}

		
		override protected function destroyDecoratorDisplay():void
		{
			super.destroyDecoratorDisplay();
			
			if (rankDisplay){
				removeChild(rankDisplay);
				rankDisplay = null;
			}
			
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
			
			if (recordDisplay)
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
			
			var recordWidth:Number = 0;
			var recordHeight:Number = 0;
			
			if (recordDisplay)
			{
				recordWidth = getElementPreferredWidth(recordDisplay);
				recordHeight = getElementPreferredHeight(recordDisplay);
				
				myMeasuredWidth += recordWidth;
				myMeasuredMinWidth += recordHeight;
				myMeasuredHeight = Math.max(myMeasuredHeight, recordHeight);
				myMeasuredMinHeight = Math.max(myMeasuredHeight, recordHeight);
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
				var messageDisplayEstimatedWidth:Number = oldUnscaledWidth - paddingAndGapWidth - myIconWidth - recordWidth;
				
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
			var recordWidth:Number = 0;
			var recordHeight:Number = 0;
			
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
			var iconDisplayY:Number = 0;
			
			if (iconDisplay)
			{
				setElementSize(iconDisplay, this.iconWidth, this.iconHeight);
				
				iconWidth = iconDisplay.getLayoutBoundsWidth();
				iconHeight = iconDisplay.getLayoutBoundsHeight();
				
				iconDisplayY = Math.round(vAlign * (viewHeight - iconHeight)) + paddingTop;
				setElementPosition(iconDisplay, paddingLeft, iconDisplayY);
			}
			
			if (decoratorDisplay)
			{
				decoratorWidth = getElementPreferredWidth(decoratorDisplay);
				decoratorHeight = getElementPreferredHeight(decoratorDisplay);
				
				setElementSize(decoratorDisplay, decoratorWidth, decoratorHeight);
				
				var decoratorX:Number = paddingLeft-4;
				var decoratorY:Number = iconDisplayY + iconHeight - decoratorHeight+8;
				setElementPosition(decoratorDisplay, decoratorX, decoratorY);
				
				if (rankDisplay)
				{				
					var size:Number = Math.ceil(decoratorWidth/2);
					size += (rankDisplay.text && rankDisplay.text.length > 1) ? 1 : 2;
					
					var tf:TextFormat = new TextFormat();
					tf.size = size;
					tf.bold = true;
					tf.color = 0xFFFFFF;
					
					rankDisplay.setTextFormat(tf);
					rankDisplay.filters = [new DropShadowFilter(1, -45, 0x000000, 1, 4, 4, 2)];
						
					rankDisplay.x = Math.round(decoratorX + (decoratorWidth/2) - (rankDisplay.textWidth/2)-2);
					rankDisplay.y = Math.round(decoratorY + (decoratorHeight/2) - (rankDisplay.textHeight/2)-1);
				}
			}
			
			
			
			if (recordDisplay)
			{
				recordWidth = getElementPreferredWidth(recordDisplay);
				recordHeight = getElementPreferredHeight(recordDisplay);
				
				setElementSize(recordDisplay, recordWidth, recordHeight);
				
				var recordY:Number = Math.round(0.5 * (viewHeight - recordHeight)) + paddingTop;
				setElementPosition(recordDisplay, unscaledWidth - paddingRight - recordWidth, recordY);
			}

			var labelComponentsViewWidth:Number = viewWidth - iconWidth - recordWidth;
			
			if (iconDisplay)
				labelComponentsViewWidth -= horizontalGap;
			if (recordDisplay)
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