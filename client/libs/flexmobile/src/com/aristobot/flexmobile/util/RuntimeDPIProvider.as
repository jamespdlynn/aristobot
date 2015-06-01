package com.aristobot.flexmobile.util
{
	import flash.system.Capabilities;
	
	import mx.core.DPIClassification;
	import mx.core.RuntimeDPIProvider;
	
	public class RuntimeDPIProvider extends mx.core.RuntimeDPIProvider
	{
		override public function get runtimeDPI():Number
		{
			var os:String = Capabilities.os.toLowerCase().split(" ")[0];
			if (os == "windows" || os == "mac"){
				return (super.runtimeDPI != DPIClassification.DPI_160) ? super.runtimeDPI : DPIClassification.DPI_240;
			}
			else if (Capabilities.screenResolutionX >= 600)
			{
				return DPIClassification.DPI_320;
			}
			
			return DPIClassification.DPI_240;

		}
	}
}
