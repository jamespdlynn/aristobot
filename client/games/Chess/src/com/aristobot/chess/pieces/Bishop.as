package com.aristobot.chess.pieces
{
	import com.aristobot.chess.data.PieceVO;
	import com.aristobot.chess.data.PositionVO;
	
	import spark.components.View;
	
	public class Bishop extends ChessPiece
	{
		[Embed (source="/chess_assets/images/white_bishop.png")]
		protected static const white:Class;
		
		[Embed (source="/chess_assets/images/black_bishop.png")]
		protected static const black:Class;
		
		public function Bishop(data:PieceVO):void
		{
			super(data);
		}
		
		override public function get imageSource():Class
		{
			return (isWhite) ? white : black;
			
			var view:View
		}
		
		override public function generateValidMoves():void
		{
			_validMoves = new Vector.<PositionVO>();
			iterateDiagnallyLeft();
			iterateDiagnallyRight();
						
		}
		
		
		
	}
}