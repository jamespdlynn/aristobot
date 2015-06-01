package com.aristobot.flexmobile.renderers
{
	
	import com.aristobot.flexmobile.data.ModifiedChatMessage;
	import com.aristobot.flexmobile.model.ViewController;
	
	import flash.display.GradientType;
	
	import mx.core.DPIClassification;
	import mx.core.mx_internal;
	import mx.formatters.DateFormatter;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.LabelItemRenderer;
	import spark.components.supportClasses.StyleableTextField;
	
	use namespace mx_internal;

	[Style(name="dateStyleName", type="String", inherit="no")]
	
	public class ChatBubbleItemRenderer extends LabelItemRenderer
	{
			
		protected var originalUnscaledWidth:Number;
		protected var radius:Number = 14;
		
		protected var dateText:String;
		protected var dateDisplay:StyleableTextField;
		protected var dateChanged:Boolean;
		
		protected var messageText:String;
		protected var messageDisplay:StyleableTextField;
		private var messageChanged:Boolean;
		
		protected var dateFormatter:DateFormatter;
		
		protected var scale:Number = ViewController.getInstance().scale;
		
		mx_internal var oldUnscaledWidth:Number;
				
		public function ChatBubbleItemRenderer()
		{
			//TODO: implement function
			super();
			
			switch (applicationDPI)
			{
					
				case DPIClassification.DPI_320:
				{
					originalUnscaledWidth = 480;
					break;
				}
					
				case DPIClassification.DPI_240:
				{
					originalUnscaledWidth = 360;
					break;
				}
				case DPIClassification.DPI_160:
				
				{
					originalUnscaledWidth = 456;
					break;
				} 
			}
			
		}


		protected var chatMessage:ModifiedChatMessage;
		
		/**
		 * @private
		 *
		 * Override this setter to respond to data changes
		 */
		override public function set data(value:Object):void
		{
			chatMessage = value as ModifiedChatMessage;
			oldUnscaledWidth = originalUnscaledWidth;

			dateText = (chatMessage) ? chatMessage.dateText : null;
			messageText = (chatMessage) ? chatMessage.message : null;
			
			dateChanged = true;
			messageChanged = true;
			
			label = null;
			invalidateProperties();
		} 
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (dateChanged)
			{
				dateChanged = false;
				// let's see if we need to create or remove it
				if (dateText && dateText.length && !dateDisplay){
					createDateDisplay();
				}
				else if ((!dateText || !dateText.length) && dateDisplay){
					destroyDateDipslay();
				}
				
				if (dateDisplay){
					dateDisplay.text = chatMessage.dateText;
				}
				
				invalidateSize();
				invalidateDisplayList();
			}
			
			if (messageChanged)
			{
				if (messageText && messageText.length && !messageDisplay){
					createMessageDisplay();
				}
				else if (!messageText && messageDisplay)
				{
					destroyMessageDisplay();
				}
				
				if (messageDisplay){
					messageDisplay.text = messageText;
				}
				
				
				invalidateSize();
				invalidateDisplayList();
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
		
		protected function createMessageDisplay():void
		{
			messageDisplay = StyleableTextField(createInFontContext(StyleableTextField));
			messageDisplay.styleName = this;
			messageDisplay.editable = false;
			messageDisplay.selectable = false;
			messageDisplay.multiline = true;
			messageDisplay.wordWrap = true;
			
			var messageStyleName:String = getStyle("messageStyleName");
			if (messageStyleName)
			{
				var styleDecl:CSSStyleDeclaration =
					styleManager.getMergedStyleDeclaration("." + messageStyleName);
				
				if (styleDecl)
					messageDisplay.styleDeclaration = styleDecl;
			}
			
			addChild(messageDisplay);
		}
		
		/**
		 *  @private
		 *  Destroys the messageDisplay component.
		 * 
		 *  @langversion 3.0
		 *  @playerversion AIR 2.5
		 *  @productversion Flex 4.5
		 */ 
		protected function destroyMessageDisplay():void
		{
			removeChild(messageDisplay);
			messageDisplay = null;
		}
		
		/**
		 * @private
		 * 
		 * Override this method to change how the item renderer 
		 * sizes itself. For performance reasons, do not call 
		 * super.measure() unless you need to.
		 */ 
		override protected function measure():void
		{
			oldUnscaledWidth = Math.round((stage.width/scale) * 0.66);
			// don't call super.measure() because there's no need to do the work that's
			// in there--we do it all in here.
			//super.measure();
			
			// start them at 0, then go through icon, label, and decorator
			// and add to these
			var myMeasuredWidth:Number = 0;
			var myMeasuredHeight:Number = 0;
			var myMeasuredMinWidth:Number = 0;
			var myMeasuredMinHeight:Number = 0;
			
			
			var paddingAndGapWidth:Number = getStyle("paddingLeft") + getStyle("paddingRight")+radius;
			
			var hasDate:Boolean = dateDisplay && dateDisplay.text != "";
			var hasMessage:Boolean = messageDisplay && messageDisplay.text != "";
			
			var paddingHeight:Number = getStyle("paddingTop") + getStyle("paddingBottom");

			
			var dateWidth:Number = 0;
			var dateHeight:Number = 0;
			
			var messageWidth:Number = 0;
			var messageHeight:Number = 0;
			
			if (hasDate)
			{
				if (dateDisplay.isTruncated)
					dateDisplay.text = dateText;
				
				
				dateWidth = getElementPreferredWidth(dateDisplay);
				dateHeight = getElementPreferredHeight(dateDisplay);
			}
			
			if (hasMessage)
			{
				// now we need to measure messageDisplay's height.  Unfortunately, this is tricky and 
				// is dependent on messageDisplay's width.  
				// Use the old unscaledWidth width as an estimte for the new one.  
				// If we are wrong, we'll find out in updateDisplayList()
				
				var messageDisplayEstimatedWidth:Number = oldUnscaledWidth - paddingAndGapWidth;
				
				setElementSize(messageDisplay, messageDisplayEstimatedWidth, NaN);
				
				messageWidth = getElementPreferredWidth(messageDisplay);
				messageHeight = getElementPreferredHeight(messageDisplay);
			}
			
			myMeasuredWidth += Math.max(messageWidth,dateWidth);
			myMeasuredHeight = Math.max(myMeasuredHeight, messageHeight);
			
			myMeasuredWidth += paddingAndGapWidth;
			myMeasuredMinWidth += paddingAndGapWidth;
			
			// verticalGap handled in label and message
			myMeasuredHeight += paddingHeight+dateHeight+5;
			myMeasuredMinHeight += paddingHeight;
			
			// now set the local variables to the member variables.
			measuredWidth = myMeasuredWidth
			measuredHeight = myMeasuredHeight;
			
			measuredMinWidth = myMeasuredMinWidth;
			measuredMinHeight = myMeasuredMinHeight;      		
		}
		
		/**
		 * @private
		 * 
		 * Override this method to change how the background is drawn for 
		 * item renderer.  For performance reasons, do not call 
		 * super.drawBackground() if you do not need to.
		 */
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (!visible) return;
			
			var hasDate:Boolean = dateDisplay && dateDisplay.text != "";
			
			var y:int = hasDate ? getElementPreferredHeight(dateDisplay)+5 : 0;
			
			var halfRadius:Number = Math.floor(radius/2);
			
			graphics.lineStyle(2, 0x00000, 0.4);

			if (chatMessage.isCurrentUser)
			{
				graphics.beginGradientFill(GradientType.LINEAR, [0x6fd7f9, 0x61cdef], [1,1],[0,1]);
				
				graphics.moveTo(radius, y);
				graphics.lineTo(unscaledWidth-(2*radius), y);
				graphics.curveTo(unscaledWidth-radius,y, unscaledWidth-radius, radius+y);
				
				graphics.lineTo(unscaledWidth-radius, unscaledHeight-(3*halfRadius));
				graphics.curveTo(unscaledWidth-radius, unscaledHeight-halfRadius, unscaledWidth, unscaledHeight);
				graphics.curveTo(unscaledWidth-halfRadius, unscaledHeight, unscaledWidth-(3*halfRadius), unscaledHeight-(halfRadius/3));
				graphics.curveTo(unscaledWidth-(2*radius), unscaledHeight, unscaledWidth-(5*halfRadius), unscaledHeight);
				
				graphics.lineTo(radius, unscaledHeight);
				graphics.curveTo(0, unscaledHeight, 0, unscaledHeight-radius);

				graphics.lineTo(0, radius+y);
				graphics.curveTo(0, y, radius, y);
				
				graphics.endFill();
			}
			else
			{
				graphics.beginGradientFill(GradientType.LINEAR, [0x9DC44E, 0xC8DB52], [1,1],[0,1]);
				
				graphics.moveTo(radius*2, y);
				graphics.lineTo(unscaledWidth-radius, y);
				graphics.curveTo(unscaledWidth,y, unscaledWidth, radius+y);
				
				graphics.lineTo(unscaledWidth, unscaledHeight-radius);
				
				graphics.curveTo(unscaledWidth,unscaledHeight, unscaledWidth-radius, unscaledHeight);
	
				graphics.lineTo(5*halfRadius, unscaledHeight);
				
				graphics.curveTo(2*radius, unscaledHeight, 3*halfRadius, unscaledHeight-(halfRadius/3));
				graphics.curveTo(halfRadius, unscaledHeight, 0, unscaledHeight);
				graphics.curveTo(radius, unscaledHeight-halfRadius, radius, unscaledHeight-(3*halfRadius));
				
				graphics.lineTo(radius, radius+y);
				graphics.curveTo(radius, y, radius*2, y);
				
				graphics.endFill();
			}
			
			var startX:int = (chatMessage.isCurrentUser) ? 5 : radius+5;
			graphics.lineStyle(0, 0, 0);
			graphics.beginFill(0xFFFFFF,0.4);
			graphics.drawRoundRect(startX, y+2, unscaledWidth-radius-10, 15, radius, radius);
			graphics.endFill();
			
		}
		
		/**
		 * @private
		 *  
		 * Override this method to change how the background is drawn for this 
		 * item renderer. For performance reasons, do not call 
		 * super.layoutContents() if you do not need to.
		 */
		override protected function layoutContents(unscaledWidth:Number, 
												   unscaledHeight:Number):void
		{
			
			var hasMessage:Boolean = messageDisplay && messageDisplay.text != "";
			var hasDate:Boolean = dateDisplay && dateDisplay.text != "";
			
			var paddingLeft:Number   = getStyle("paddingLeft");
			var paddingRight:Number  = getStyle("paddingRight");
			var paddingTop:Number    = getStyle("paddingTop");
			var paddingBottom:Number = getStyle("paddingBottom");
			var horizontalGap:Number = getStyle("horizontalGap");
			var verticalAlign:String = getStyle("verticalAlign");
			
			if (chatMessage.isCurrentUser){
				paddingRight+= radius;
			}
			else{
				paddingLeft+= radius;
			}
			
			var vAlign:Number;
			if (verticalAlign == "top")
				vAlign = 0;
			else if (verticalAlign == "bottom")
				vAlign = 1;
			else 
				vAlign = 0.5;
			
			var viewWidth:Number  = unscaledWidth  - paddingLeft - paddingRight;
			var viewHeight:Number = unscaledHeight - paddingTop  - paddingBottom;
			
			
			// Figure out how much space we have for label and message as well as the 
			// starting left position
			var labelComponentsViewWidth:Number = viewWidth;
			
			// calculte the natural height for the label
			var dateTextHeight:Number = 0;
			
			
			if (hasMessage){
				messageDisplay.commitStyles();
			}
			if (hasDate){
				dateDisplay.commitStyles();
				dateTextHeight = getElementPreferredHeight(dateDisplay);
			}

			var dateWidth:Number = 0;
			var dateHeight:Number = 0;
			var messageWidth:Number = 0;
			var messageHeight:Number = 0;
						
			
			if (hasDate)
			{
				dateWidth = getElementPreferredWidth(dateDisplay);
				dateHeight = dateTextHeight;
				
				if (dateWidth == 0)
					setElementSize(dateDisplay, NaN, 0);
				else
					setElementSize(dateDisplay, dateWidth, dateHeight);
				
				dateDisplay.truncateToFit();
			}
			
			
			if (hasMessage)
			{
				// handle message...because the text is multi-line, measuring and layout 
				// can be somewhat tricky
				messageWidth = Math.max(labelComponentsViewWidth, 0);
				
				// We get called with unscaledWidth = 0 a few times...
				// rather than deal with this case normally, 
				// we can just special-case it later to do something smarter
				if (messageWidth == 0)
				{
					// if unscaledWidth is 0, we want to make sure messageDisplay is invisible.
					// we could set messageDisplay's width to 0, but that would cause an extra 
					// layout pass because of the text reflow logic.  Because of that, we 
					// can just set its height to 0.
					setElementSize(messageDisplay, NaN, 0);
				}
				else
				{
					// grab old textDisplay height before resizing it
					var oldPreferredMessageHeight:Number = getElementPreferredHeight(messageDisplay);
					
					// keep track of oldUnscaledWidth so we have a good guess as to the width 
					// of the messageDisplay on the next measure() pass
					oldUnscaledWidth = unscaledWidth;
					
					// set the width of messageDisplay to messageWidth.
					// set the height to oldMessageHeight.  If the height's actually wrong, 
					// we'll invalidateSize() and go through this layout pass again anyways
					setElementSize(messageDisplay, messageWidth, oldPreferredMessageHeight);
					
					// grab new messageDisplay height after the messageDisplay has taken its final width
					var newPreferredMessageHeight:Number = getElementPreferredHeight(messageDisplay);
					
					// if the resize caused the messageDisplay's height to change (because of 
					// text reflow), then we need to remeasure ourselves with our new width
					if (oldPreferredMessageHeight != newPreferredMessageHeight)
						invalidateSize();
					
					messageHeight = newPreferredMessageHeight;
				}
				
				// since it's multi-line, no need to truncate
				//if (messageDisplay.isTruncated)
				//    messageDisplay.text = messageText;
				//messageDisplay.truncateToFit();
			}
			
			// Position the text components now that we know all heights so we can respect verticalAlign style
			
			var totalHeight:Number = 0;
			var labelComponentsX:Number = 0;
			var labelComponentsY:Number = 0; 
			
			// Heights used in our alignment calculations.  We only care about the "real" ascent 
			var dateAlignmentHeight:Number = 0; 
			var messageAlignmentHeight:Number = 0; 
			
			if (hasMessage)
				messageAlignmentHeight = getElementPreferredHeight(messageDisplay);
			
			totalHeight = messageAlignmentHeight;          
			labelComponentsY = Math.round(vAlign * (viewHeight - totalHeight)) + paddingTop;
			
			if (dateDisplay)
			{
				var dateX:Number = ((unscaledWidth - dateWidth)/2) +(paddingLeft-paddingRight);
				var dateY:Number = 0;
				setElementPosition(dateDisplay, dateX, dateY);
			}
			if (messageDisplay)
			{
				var messageX:Number =  chatMessage.isCurrentUser ? unscaledWidth - paddingRight - messageWidth: paddingLeft;
				var messageY:Number = labelComponentsY + dateHeight - 2;
				setElementPosition(messageDisplay, messageX, messageY);
			}		
		}
		
	}
}