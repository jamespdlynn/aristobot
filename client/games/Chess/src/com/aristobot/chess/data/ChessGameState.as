package com.aristobot.chess.data
{
	import com.aristobot.data.ICustomGameObject;

	public class ChessGameState implements ICustomGameObject
	{
		public var pieces:Vector.<PieceVO>;
		public var isInCheck:Boolean;		
		public var boardColor:uint;
		
		public function marshall():XML
		{
			var rootXML:XML = <com.aristobot.chess.data.ChessGameState/>;
			rootXML.bc = boardColor.toString(8);
			rootXML.inc = (isInCheck) ? 1 : 0;
			rootXML.ps = <ps/>;
			
			for each (var piece:PieceVO in pieces){
				rootXML.ps.appendChild(piece.marshall(<p/>));
			}
			
			return rootXML;
		}
		
		public function unmarshall(rootXML:XML):void
		{
			boardColor = parseInt(rootXML.bc, 8);
			isInCheck = rootXML.inc == "1";
			
			pieces = new Vector.<PieceVO>(32);
			var i:int = 0;
			
			for each (var pieceXML:XML in rootXML.ps.*)
			{
				var pieceVO:PieceVO = new PieceVO();
				pieceVO.unmarshall(pieceXML);
				pieces[i] = pieceVO;
				i++;
			}
			
	
		}
	}
}