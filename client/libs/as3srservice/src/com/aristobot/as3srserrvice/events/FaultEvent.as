package com.aristobot.as3srserrvice.events
{
	import flash.events.Event;

	public class FaultEvent extends Event
	{
		public static const FAULT:String = "fault";
		public static const UNHANLED_FAULT:String = "unhandledFault";
		
		public static const CONNECTION_ERROR:String = "000";
		public static const CONNECTION_TIME_OUT:String = "001";
		public static const SERVICE_NOT_FOUND:String = "002";
		public static const BAD_REQUEST:String = "003";
		public static const UNABLE_TO_PARSE_RESULT:String = "004";
		public static const UPLOAD_FAILED:String = "006";
		
		public static const SERVER_ERROR:String = "100";
		
		public static const INVALID_API_KEY:String = "200";
		public static const INVALID_ACCESS_TOKEN:String = "201";
		public static const INVALID_WRITE_ACCESS:String = "202";
		public static const LOGIN_FAILED:String = "203";
		public static const AUTO_LOGIN_FAILED:String = "204";
		public static const DEPRECATED_VERSION_NUMBER:String = "205";
		public static const INVALID_DEVICE_ID:String = "206";
		public static const INVALID_DEVICE_TYPE:String = "207";
		
		public static const REGISTRATION_ERROR:String = "300";
		public static const UPDATE_ERROR:String = "301";
		public static const INVALID_USER_NAME:String = "302";
		public static const INVALID_PASSWORD:String = "303";
		public static const INVALID_EMAIL_ADDRESS:String = "304";
		public static const INVALID_ICON_ID:String = "305";
		public static const DUPLICATE_USER_NAME:String = "306";
		public static const DUPLICATE_EMAIL_ADDRESS:String = "307";
		
		public static const INVALID_OPPONENT:String = "400";
		public static const UNABLE_TO_FIND_OPPONENT_USERNAME:String = "401";
		public static const UNABLE_TO_FIND_OPPONENT_EMAIL:String = "402";
		public static const DUPLICATE_OPPONENT:String = "403";
		public static const UNABLE_TO_FIND_RANDOM_OPPONENT:String = "404";
		
		public static const UNABLE_TO_FIND_GAME:String = "500";
		public static const INVALID_INVITEE_NUMBER:String = "501";
		public static const INVALID_INVITEE_OPPONENT:String = "502";
		public static const TOO_MANY_GAMES:String = "503";
		public static const TOO_MANY_GAMES_PER_OPPONENT:String = "504";
		public static const ALREADY_PLAYING:String = "505";
		public static const GAME_INITIALIZING:String = "506";
		public static const GAME_ENDED:String = "507";
		public static const NOT_PLAYING:String = "508";
		public static const NOT_TURN:String = "509";
		public static const INVALID_WINNER:String = "510";
		public static const CANNOT_RESIGN_AT_THIS_TIME:String = "511";
		public static const CANNOT_REQUEST_DRAW_AT_THIS_TIME:String = "512";
		public static const NOT_CREATOR:String = "513";
		public static const TOO_MANY_PLAYERS:String = "514";
		public static const NO_DRAW_REQUESTED:String = "515";
		public static const INVALID_GAME_DATA:String = "516";
		public static const GAME_LOCKED:String = "517";
		public static const OPPONENT_TOO_MANY_GAMES:String = "518";
		
		public static const ICON_ALREADY_EXISTS:String = "600";
		public static const INVALID_ICON_KEY:String = "601";
		public static const INVALID_ICON_NAME:String = "602";
		public static const INVALID_ICON_LEVEL:String = "603";
		public static const INVALID_ICON_DEVICE_TYPE:String = "604";
		public static const ICON_NOT_ON_SERVER:String = "605";
		public static const ICON_BELONGS_TO_USER:String = "606";

		public var faultCode:String;
		public var message:String;
		
		public function FaultEvent(type:String, faultCode:String, message:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.faultCode = faultCode;
			this.message = message;
			
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new FaultEvent(type, faultCode, message, bubbles, cancelable);
		}
	}
}