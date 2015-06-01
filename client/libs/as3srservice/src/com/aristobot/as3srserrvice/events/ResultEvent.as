package com.aristobot.as3srserrvice.events
{
	import flash.events.Event;
	
	public class ResultEvent extends Event
	{
		public static const RESULT:String = "result";
		public static const AUTHENTICATED:String = "authenticated";
		public static const DEVICE_REGISTERED:String = "deviceRegistered";
		public static const UPDATED:String = "updated";
		
		public var resultObj:Object;
		
		public function ResultEvent(type:String, resultObj:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.resultObj = resultObj;
			
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new ResultEvent(type, resultObj, bubbles, cancelable);
		}
	}
}