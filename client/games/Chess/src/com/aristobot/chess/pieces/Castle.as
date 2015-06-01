package com.aristobot.chess.pieces
{
	import com.aristobot.chess.data.PieceVO;
	import com.aristobot.chess.data.PositionVO;
	
	public class Castle extends ChessPiece
	{
		[Embed (source="/chess_assets/images/white_castle.png")]
		public static const white:Class;
		
		[Embed (source="/chess_assets/images/black_castle.png")]
		protected static const black:Class;
		
		public function Castle(data:PieceVO):void
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
		}
	}
}
