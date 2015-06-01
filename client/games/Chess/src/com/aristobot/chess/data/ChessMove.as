package com.aristobot.chess.data
{
	import com.aristobot.data.ICustomGameObject;
	
	import mx.geom.Transform;

	public class ChessMove implements ICustomGameObject
	{
		public function ChessMove(oldPosition:PositionVO=null, newPosition:PositionVO=null, pieceTaken:PieceVO=null, subsequentMove:ChessMove=null, transformation:TransformationVO = null)
		{
			this.oldPosition = oldPosition
			this.newPosition = newPosition;
			this.capturedPiece = pieceTaken;
			this.subsequentMove = subsequentMove;
			this.transformation = transformation;
		}
		
		public var oldPosition:PositionVO;
		public var newPosition:PositionVO;
		public var capturedPiece:PieceVO;
		public var subsequentMove:ChessMove;
		public var transformation:TransformationVO;
		public var isCheck:Boolean;

		public function marshall():XML
		{
			var rootXML:XML = <com.aristobot.chess.data.ChessMove/>;
			
			rootXML.op.r = oldPosition.row;
			rootXML.op.c = oldPosition.col;

			rootXML.np.r = newPosition.row;
			rootXML.np.c = newPosition.col;
		
			rootXML.cp = (capturedPiece) ? capturedPiece.id : -1;
			
			if (subsequentMove){
				rootXML.sm = new XML("<sm/>");
				rootXML.sm.appendChild(subsequentMove.marshall());
			}
			
			if (transformation){
				rootXML.transformation = transformation.marshall(<t/>);
			}
			
			rootXML.ic = isCheck ? 1 : 0;
			
			return rootXML;
		}
		
		public function unmarshall(rootXML:XML):void
		{
			oldPosition = new PositionVO(rootXML.op.r, rootXML.op.c);
			newPosition = new PositionVO(rootXML.np.r, rootXML.np.c);
			
			if (rootXML.cp >= 0){
				capturedPiece = new PieceVO(rootXML.cp);
			}
			
			if (rootXML.sm.hasComplexContent()){
				subsequentMove = new ChessMove();
				subsequentMove.unmarshall(rootXML.sm.children()[0]);
			}
			
			if (rootXML.t.hasComplexContent()){
				transformation = new TransformationVO();
				transformation.unmarshall(rootXML.t[0]);
			}
			
			isCheck = rootXML.ic == 1;
		}
	}
}