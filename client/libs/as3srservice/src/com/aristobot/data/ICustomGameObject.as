package com.aristobot.data
{
	public interface ICustomGameObject
	{
		function marshall():XML
		function unmarshall(rootXML:XML):void
	}
}