package com.aristobot.admin.components
{
	import flash.events.Event;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.VGroup;

	[Event(name="change", type="flash.events.Event")]
	public class FormItem extends VGroup
	{
		protected var labelGroup:Group;
		protected var formLabel:Label;
		protected var errorLabel:Label;
		
		public function FormItem()
		{
			this.width = 440;
			
			labelGroup = new Group();
			labelGroup.percentWidth = 100;
			
			formLabel = new Label();
			formLabel.styleName = "formLabel";
			
			errorLabel = new Label();
			errorLabel.visible = false;
			errorLabel.styleName = "errorLabel";
			errorLabel.verticalCenter = 0;
			errorLabel.right = 0;
			
			labelGroup.addElement(formLabel);
			labelGroup.addElement(errorLabel);
			
			cacheAsBitmap=true;
			
		}
	
		public function set label(value:String):void
		{
			formLabel.text = value;
		}
		
		override protected function createChildren():void
		{
			this.addElementAt(labelGroup, 0);
			super.createChildren();
		}
		
		
		public function displayError(text:String):void
		{
			errorLabel.text = text;
			errorLabel.visible = true;
		}
		
		
		public function onChange(event:Event):void
		{
			dispatchEvent(new Event(Event.CHANGE));
			errorLabel.visible = false;
		}
	}
}