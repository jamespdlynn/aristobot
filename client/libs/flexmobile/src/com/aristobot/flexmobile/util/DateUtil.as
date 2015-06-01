package com.aristobot.flexmobile.util
{
	import com.aristobot.data.RoboDate;

	public class DateUtil
	{
		
		public static function timeAgo(date:RoboDate):String
		{
			var timeDifference:Number = date.timeAgo;
			
			var minuteDifference:Number = Math.ceil(timeDifference/1000/60);
			var hourDiffrence:Number = Math.floor(minuteDifference/60);
			var dayDifference:Number = Math.floor(hourDiffrence/24);
			var weekDifference:Number = Math.floor(dayDifference/7);
			var monthDifference:Number = Math.floor(dayDifference/30);
			
			if (monthDifference > 0){
				return (monthDifference + (monthDifference != 1 ? " months" : " month"));
			}
			
			if (weekDifference > 0){
				return (weekDifference + (weekDifference != 1 ? " weeks" : " week"));
			}
						
			if (dayDifference > 0){
				return (dayDifference + (dayDifference != 1 ? " days" : " day"));
			}
	
			if (hourDiffrence > 0){
				return (hourDiffrence + (hourDiffrence != 1 ? " hours" : " hour"));
			}
			
			return (minuteDifference + (minuteDifference != 1 ? " minutes" : " minute"));
		}
	}
}