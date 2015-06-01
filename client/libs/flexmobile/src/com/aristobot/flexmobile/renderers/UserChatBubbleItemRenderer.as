package com.aristobot.flexmobile.renderers
{
	public class UserChatBubbleItemRenderer extends ChatBubbleItemRenderer
	{
		override public function set data(value:Object):void
		{
			super.data = value; 
			visible = chatMessage && chatMessage.isCurrentUser;
		}
	}
}