package com.aristobot.data
{
	public class RoboDate
	{
		public var dateString:String;
		
		public var timeAgo:Number;
		
		[Transient]
		public function get date():Date
		{
			return new Date(dateString);
		}
		public function set date(value:Date):void{
			dateString = value.toDateString();
			timeAgo = new Date().date - value.date;
		}
		
		[Transient]
		public function updateTimeAgo():void{
			timeAgo = new Date().date - date.date;
		}
	}
}