package com.aristobot.as3srserrvice.model
{
	public class ResponseHandlers
	{
		public var resultHandler:Function;
		public var faultHandler:Function;
		
		public function ResponseHandlers(resultHandler:Function, faultHandler:Function)
		{
			this.resultHandler = resultHandler;
			this.faultHandler = faultHandler;
		}
	}
}