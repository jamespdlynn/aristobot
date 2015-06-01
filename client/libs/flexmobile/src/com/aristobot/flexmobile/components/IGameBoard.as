package com.aristobot.flexmobile.components
{
	import com.aristobot.data.ICustomGameObject;
	import com.aristobot.data.Player;
	import com.aristobot.flexmobile.data.GameBoardUpdateData;
	
	import mx.core.IVisualElement;

	public interface IGameBoard extends IVisualElement
	{
		function createInitialGameState():ICustomGameObject;
						
		function initializeGame(customGameState:ICustomGameObject, currentPlayer:Player, previousMove:ICustomGameObject = null, redrawBoard:Boolean=false):void;
		
		function resetGameData():void;
		
		function resetBoard():void;
		
		function run():void;
		
		function cyclePreviousMove(move:ICustomGameObject):void
		
		function cycleNextMove(move:ICustomGameObject):void
			
		function playNextMove(move:ICustomGameObject, moveCompleteHandler:Function):void
		
		function revertTurn():void
			
		function executeTurn():GameBoardUpdateData;
		
		function get playEnabled():Boolean;
		
	}
}