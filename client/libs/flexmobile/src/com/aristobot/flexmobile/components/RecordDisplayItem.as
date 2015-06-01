package com.aristobot.flexmobile.components
{
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.core.UITextFormat;
	import mx.core.mx_internal;
	import mx.styles.CSSStyleDeclaration;
	import mx.utils.StringUtil;
	
	import spark.components.supportClasses.StyleableTextField;
	import spark.primitives.Line;
	
	public class RecordDisplayItem extends UIComponent
	{
		protected var amountText:String = "0";
		protected var labelText:String = "";
		
		protected var amountDisplay:StyleableTextField;
		protected var labelDisplay:StyleableTextField;
		
		protected var dataChanged:Boolean;
		
		protected var _amountFontSize:int;
		protected var _labelFontSize:int;
		protected var _color:int;
		protected var _multiLine:Boolean;
		
		private static var _cachedAmountFormat:UITextFormat;
		private static var _cachedLabelFormat:UITextFormat;
		
		public function RecordDisplayItem(amountFontSize:int, labelFontSize:int, color:uint, multiLine:Boolean=false)
		{
			super();
			_color = color;
			_amountFontSize = amountFontSize;
			_labelFontSize = labelFontSize;
			_multiLine =  multiLine;
		}
		
		public function set label(value:String):void
		{
			labelText = value;
			invalidateProperties();
			
			dataChanged = true;
		}
		
		public function set amount(value:int):void
		{
			amountText = value.toString();
			invalidateProperties();
			
			dataChanged =true;
		}
		
		public function set multiLine(value:Boolean):void
		{
			_multiLine = value;
			invalidateSize();
			invalidateProperties();
		}
		
		public function set color(value:uint):void
		{
			_color = value;
		}
		
		public function set amountFontSize(value:uint):void
		{
			setStyle("amountFontSize",value);
		}
		
		override protected function createChildren():void
		{
			if (!amountDisplay)
			{
				amountDisplay = StyleableTextField(createInFontContext(StyleableTextField));
				amountDisplay.styleName = this;
				amountDisplay.editable = false;
				amountDisplay.selectable = false;
				amountDisplay.multiline = false;
				amountDisplay.wordWrap = false;

				addChild(amountDisplay);
				amountDisplay.text = amountText;
			}
			if (!labelDisplay)
			{
				labelDisplay = StyleableTextField(createInFontContext(StyleableTextField));
				labelDisplay.styleName = this;
				labelDisplay.editable = false;
				labelDisplay.selectable = false;
				labelDisplay.multiline = true;
				labelDisplay.wordWrap = true;
				
				addChild(labelDisplay);
				labelDisplay.text = labelText;
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (dataChanged)
			{
				dataChanged = false;
				
				amountDisplay.text = amountText;
				labelDisplay.text = labelText;
				
				invalidateSize();
				invalidateDisplayList();
			}
			
		}
		
		override protected function measure():void
		{
			var amountLineMetrics:TextLineMetrics = cachedAmountFormat.measureText(amountText);
			
			var myMeasuredWidth:Number = amountLineMetrics.width * 1.2;
			var myMeasuredHeight:Number = amountLineMetrics.height;
			
			var split:Array = (_multiLine) ? labelText.split(" ") : [labelText];
			
			for each (var labelSplit:String in split)
			{
				
				var labelLineMetrics:TextLineMetrics = cachedLabelFormat.measureText(labelSplit);
				myMeasuredWidth = Math.max(labelLineMetrics.width*1.2, myMeasuredWidth);
				myMeasuredHeight += labelLineMetrics.height;
			}
	
			
			measuredWidth = myMeasuredWidth;
			measuredHeight = myMeasuredHeight;
			
		}
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var amountLineMetrics:TextLineMetrics = cachedAmountFormat.measureText(amountText);
			var amountHeight:Number = amountLineMetrics.height;
			
			amountDisplay.x = 0;
			amountDisplay.y = 0;
			amountDisplay.width = getExplicitOrMeasuredWidth();
			
			labelDisplay.x = 0;
			labelDisplay.y = amountHeight;
			labelDisplay.width = getExplicitOrMeasuredWidth();
			
			labelDisplay.commitStyles();
			amountDisplay.commitStyles();
			
			amountDisplay.setTextFormat(cachedAmountFormat);
			labelDisplay.setTextFormat(cachedLabelFormat);
			
		}
		
		override public function styleChanged(styleName:String):void
		{
			var allStyles:Boolean = !styleName || styleName == "styleName";
			
			super.styleChanged(styleName);
			
			if (amountDisplay){
				_cachedAmountFormat = null;
				amountDisplay.styleChanged(styleName);
			}
			
			if (labelDisplay){
				_cachedLabelFormat = null;
				labelDisplay.styleChanged(styleName);
			}
			
			
		}
		
		private function get cachedAmountFormat():UITextFormat
		{
			if (!_cachedAmountFormat){
				_cachedAmountFormat = textFormat;
			}
			
			_cachedAmountFormat.bold = true;
			_cachedAmountFormat.size = _amountFontSize;
			_cachedAmountFormat.color = _color;
			
			return _cachedAmountFormat;
		}
		
		private function get cachedLabelFormat():UITextFormat
		{
			if (!_cachedLabelFormat){
				_cachedLabelFormat = textFormat;
			}
			
			_cachedLabelFormat.size = _labelFontSize;
			_cachedLabelFormat.color = _color;
			
			return _cachedLabelFormat;
		}
		
		private function get textFormat():UITextFormat
		{
			var font:String = StringUtil.trimArrayElements(getStyle("fontFamily"), ",");
			var _textFormat:UITextFormat = new UITextFormat(systemManager, font);
			_textFormat.moduleFactory = moduleFactory;
			
			// Not all flex4 textAlign values are valid so convert to a valid one.
			var align:String = getStyle("textAlign");
			if (align == "start") 
				align = TextFormatAlign.CENTER;
			else if (align == "end")
				align = TextFormatAlign.RIGHT;
			_textFormat.align = align; 
			_textFormat.bold = getStyle("fontWeight") == "bold";
			_textFormat.font = font;
			_textFormat.indent = getStyle("textIndex");
			_textFormat.italic = getStyle("fontStyle") == "italic";
			_textFormat.kerning = getStyle("kerning");
			_textFormat.leading = getStyle("leading");
			_textFormat.leftMargin = getStyle("paddingLeft"); // FIXME (rfrishbe): should these be in here...?
			_textFormat.letterSpacing = getStyle("letterSpacing")
			_textFormat.rightMargin = getStyle("paddingRight");
			_textFormat.underline =
				getStyle("textDecoration") == "underline";
			
			_textFormat.antiAliasType = getStyle("fontAntiAliasType");
			_textFormat.gridFitType = getStyle("fontGridFitType");
			_textFormat.sharpness = getStyle("fontSharpness");
			_textFormat.thickness = getStyle("fontThickness");
			
			return _textFormat;
		}
		
		
	}
}