package com.aristobot.chess.pieces
{
	import com.aristobot.chess.data.PieceVO;
	import com.aristobot.chess.data.PositionVO;
	
	public class Knight extends ChessPiece
	{
		[Embed (source="/chess_assets/images/white_knight.png")]
		protected static const white:Class;
		
		[Embed (source="/chess_assets/images/black_knight.png")]
		protected static const black:Class;
		
		public function Knight(data:PieceVO):void
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
			
			if (isValidMove(position.row+2, position.col+1)){
				_validMoves.push(new PositionVO(position.row+2, position.col+1));
			}
			
			if (isValidMove(position.row+2, position.col-1)){
				validMoves.push(new PositionVO(position.row+2, position.col-1));
			}
			
			if (isValidMove(position.row-2, position.col+1)){
				validMoves.push(new PositionVO(position.row-2, position.col+1));
			}
			
			if (isValidMove(position.row-2, position.col-1)){
				validMoves.push(new PositionVO(position.row-2, position.col-1));
			}
			
			if (isValidMove(position.row+1, position.col+2)){
				validMoves.push(new PositionVO(position.row+1, position.col+2));
			}
			
			if (isValidMove(position.row+1, position.col-2)){
				validMoves.push(new PositionVO(position.row+1, position.col-2));
			}
			
			if (isValidMove(position.row-1, position.col+2)){
				validMoves.push(new PositionVO(position.row-1, position.col+2));
			}
			
			if (isValidMove(position.row-1, position.col-2)){
				validMoves.push(new PositionVO(position.row-1, position.col-2));
			}
		
		}

	
	}
}