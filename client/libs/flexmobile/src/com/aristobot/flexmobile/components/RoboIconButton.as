package com.aristobot.flexmobile.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.layouts.VerticalAlign;
	import spark.primitives.BitmapImage;
	
	import org.osmf.layout.HorizontalAlign;

	[Event(name="click", type="flash.events.MouseEvent")]
	public class RoboIconButton extends Group
	{
		protected var button:Button;
		protected var group:HGroup;
		protected var labelDisplay:Label;
		protected var iconDisplay:BitmapImage;
		
		protected var _source:Object;
		protected var _iconSize:Number;
		protected var _label:String="";
		protected var _gap:int = 5;
		
		protected var _buttonVisible:Boolean = true;
		public function set buttonVisible(value:Boolean):void{
			_buttonVisible = value;
			if (button) button.visible = _buttonVisible;
			
		}
		
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			button = new RoboButton();
			button.percentWidth = 100;
			button.percentHeight = 100;
			button.alpha = _buttonVisible ? 1 : 0;
			button.styleName = this.styleName;
			
			group = new HGroup();
			group.percentWidth = 100;
			group.gap = _gap;
			group.verticalCenter = 0;
			group.verticalAlign = VerticalAlign.MIDDLE;
			group.horizontalAlign = HorizontalAlign.CENTER;
			group.setStyle("paddingTop", 0);
			group.setStyle("paddingBottom",0);
			group.mouseEnabled = false;
			
			
			iconDisplay = new BitmapImage();
			iconDisplay.smooth = true;
			iconDisplay.source = _source;
			if (_iconSize > 0){
				iconDisplay.width = _iconSize;
				iconDisplay.height = _iconSize;
			}
			group.addElement(iconDisplay);
			
			labelDisplay = new Label();
			labelDisplay.styleName = this.styleName;
			labelDisplay.text = _label;
			labelDisplay.visible = _label.length > 0;
			group.addElement(labelDisplay);
			
			
			addElement(button);
			addElement(group);
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, mouseUpHandler, false, 0, true);
		}
			
		
		public function set label(value:String):void
		{
			_label = value;
			
			if (labelDisplay){
				labelDisplay.text = _label;
				labelDisplay.visible = _label.length > 0;
			}
		}
		
		public function set source(value:Object):void
		{ 
			_source = value;
			
			if (iconDisplay){
				iconDisplay.visible = true;
				iconDisplay.source = _source;
			}
			
		}
		
		public function set iconSize(value:Number):void
		{
			_iconSize = value;
			
			if (iconDisplay && _iconSize > 0){
				iconDisplay.width = _iconSize;
				iconDisplay.height = _iconSize;
			}
			
		}
		
		public function set gap(value:int):void{
			_gap = value;
			
			if (group){
				group.gap = _gap;
			}
		}
		
		protected  function mouseDownHandler(event:Event):void
		{
			group.verticalCenter=1;
		}
		
		protected  function mouseUpHandler(event:Event):void
		{
			group.verticalCenter=0;
		}
		
		
	}
}