package com.aristobot.admin.managers
{
	import flash.events.Event;

	public interface IView
	{
		function init(event:Event=null):void;
		
		function destruct(event:Event=null):void;
	}
}