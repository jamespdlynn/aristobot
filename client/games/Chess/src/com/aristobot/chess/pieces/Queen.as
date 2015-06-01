package com.aristobot.chess.pieces
{
	import com.aristobot.chess.data.PieceVO;
	import com.aristobot.chess.data.PositionVO;
	
	public class Queen extends ChessPiece
	{
		[Embed (source="/chess_assets/images/white_queen.png")]
		protected static const white:Class;
		
		[Embed (source="/chess_assets/images/black_queen.png")]
		protected static const black:Class;
		
		public function Queen(data:PieceVO):void
		{
			super(data);
		}
		
		override public function get imageSource():Class
		{
			return (isWhite) ? white : black;
		}
		
		override public function generateValidMoves():void
		{
			_validMoves = new Vector.<PositionVO>();
			iterateVertically();
			iterateHorizontally();
			iterateDiagnallyLeft();
			iterateDiagnallyRight();
		}
		
		
	}
}