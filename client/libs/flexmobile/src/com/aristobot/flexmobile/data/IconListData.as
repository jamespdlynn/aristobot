package com.aristobot.flexmobile.data
{
	[Bindable]
	public class IconListData
	{
		public var label:String;
		public var icon:Object;
		public var key:String;
		public var message:String;
		public var subLabel:String;
		public var rank:int;
		public var decorator:Object;
		public var dataObj:Object;
		
		public function IconListData(key:String=null, label:String=null, icon:Object=null, message:String=null, subLabel:String = null, decorator:Object = null, data:Object=null)
		{
			this.key = key;
			this.label = label;
			this.icon = icon;
			this.message = message;
			this.subLabel = subLabel;
			this.decorator = decorator;
			this.dataObj = data;
		}
		
	}
}