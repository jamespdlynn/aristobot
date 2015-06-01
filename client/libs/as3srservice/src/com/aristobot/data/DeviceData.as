package com.aristobot.data
{
	[Bindable]
	public class DeviceData
	{
		public static const ANDROID:String = "android";
		public static const IOS:String = "ios";
		public static const OTHER:String = "other";
		
		public var deviceId:String;
		public var deviceType:String;
		public var os:String;
		public var cpuArchitecture:String;
		public var screenDPI:int;
		
	}
}