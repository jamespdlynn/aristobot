package com.aristobot.as3srserrvice.services
{

	import com.aristobot.data.Opponent;
	import com.aristobot.data.OpponentsWrapper;
	import com.aristobot.data.User;

	public class OpponentService extends RestService
	{

		public function OpponentService(url:String, apiKey:String, accessToken:String)
		{
			super(url, apiKey, null, accessToken);
		}
		
		public function getAllOpponents(resultHandler:Function=null, faultHandler:Function = null):void
		{
			get("/opponents", OpponentsWrapper, resultHandler, faultHandler);
		}
		
		public function getOpponent(opponentUsername:String, resultHandler:Function=null , faultHandler:Function = null):void
		{
			get("/opponents/"+opponentUsername, Opponent, resultHandler, faultHandler);
		}
		
		public function addOpponent(opponentUsername:String, resultHandler:Function = null, faultHandler:Function = null):void
		{
			postText("/opponents/add", opponentUsername, resultHandler, faultHandler);
			parseClass = User;
		}
		
		public function getRandomOpponent(resultHandler:Function = null, faultHandler:Function = null):void
		{
			get("/opponents/random", User, resultHandler, faultHandler);
		}
		
		public function removeOpponent(opponentUsername:String, resultHandler:Function=null , faultHandler:Function = null):void
		{
			postText("/opponents/remove",  opponentUsername, resultHandler, faultHandler);
		}
		

	}
}