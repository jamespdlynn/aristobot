package com.aristobot.flexmobile.data
{
	public class ModifiedChatMessage
	{
		public function ModifiedChatMessage(message:String, dateText:String, isCurrentUser:Boolean)
		{
			this.message = message;
			this.dateText = dateText;
			this.isCurrentUser = isCurrentUser;
		}
		
		public var message:String;
		public var dateText:String;
		public var isCurrentUser:Boolean;
	}
}