package com.aristobot.checkers.data
{
	import com.aristobot.data.ICustomGameObject;

	public class GameState implements ICustomGameObject
	{
		public var pieces:Vector.<Piece>;
		public var isInCheck:Boolean;		
		public var boardColor:uint;
		
		public function marshall():XML
		{
			var rootXML:XML = <com.aristobot.checkers.GameState/>;
			rootXML.bc = boardColor.toString(8);
			rootXML.ps = <ps/>;
			
			for each (var piece:Piece in pieces){
				rootXML.ps.appendChild(piece.marshall(<p/>));
			}
			
			return rootXML;
		}
		
		public function unmarshall(rootXML:XML):void
		{
			boardColor = parseInt(rootXML.bc, 8);
			isInCheck = rootXML.inc == "1";
			
			pieces = new Vector.<Piece>(40);			
			for each (var pieceXML:XML in rootXML.ps.*)
			{
				var pieceVO:Piece = new Piece();
				pieceVO.unmarshall(pieceXML);
				pieces.push(pieceVO);
			}
			
	
		}
	}
}