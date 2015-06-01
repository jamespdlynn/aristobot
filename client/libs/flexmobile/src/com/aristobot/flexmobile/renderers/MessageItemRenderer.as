package com.aristobot.flexmobile.renderers
{
	import com.aristobot.data.SystemMessage;
	import com.aristobot.flexmobile.data.IconListData;
	
	import mx.core.mx_internal;
		
	use namespace mx_internal;
	
	public class MessageItemRenderer extends ListDataItemRenderer
	{		
		
		override public function set data(value:Object):void
		{
			var listData:IconListData = value as IconListData;
			if (listData && (listData.dataObj as SystemMessage).isRead){
				alpha = 0.7;
			}
			super.data = listData;
			
		}
		
	
	}
	
}