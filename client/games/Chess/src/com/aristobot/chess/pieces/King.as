package com.aristobot.chess.pieces
{
	import com.aristobot.chess.data.ChessMove;
	import com.aristobot.chess.data.PieceVO;
	import com.aristobot.chess.data.PositionVO;
	
	public class King extends ChessPiece
	{		
		
		[Embed (source="/chess_assets/images/white_king.png")]
		protected static const white:Class;
		
		[Embed (source="/chess_assets/images/black_king.png")]
		protected static const black:Class;
		
		
				
		public function King(data:PieceVO):void
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
			
			for (var r:int=position.row-1; r <= position.row+1; r++){
				for (var c:int=position.col-1; c <= position.col+1; c++){
					if (isValidMove(r,c)){
						_validMoves.push(new PositionVO(r,c));
					}
				}
			}
		}


		override public function getMove(row:int, col:int):ChessMove
		{
			var move:ChessMove = super.getMove(row, col);

			if (!move && canCastle(row, col))
			{
				var newPosition:PositionVO = new PositionVO(row, col);
				move = new ChessMove(position, newPosition);
				
				var castleCol:int = (col > position.col) ? col+1 : col-2;
				var castleNewCol:int = (col > position.col) ? col-1: col+1;
				
				move.subsequentMove = new ChessMove();
				move.subsequentMove.oldPosition = new PositionVO(row, castleCol);
				move.subsequentMove.newPosition = new PositionVO(row, castleNewCol);
			}
			
			return move;
		}
		
		protected function canCastle(row:int, col:int):Boolean
		{
			if (hasMoved || !isValidPosition(row,col) || row != position.row ||isInCheck(true)) return false;
			
			if (col < board[row].length-1 && board[row][col+1] != null && board[row][col+1] is Castle && !board[row][col+1].hasMoved)
			{
				for (var c:int = position.col+1; c <= col; c++){
					if  (containsPiece(row, c) || moveResultsInCheck(row, c, true)){
						return false;
					}
				}
				return true;
			}
			
			if (col > 1 && board[row][col-2] != null && board[row][col-2] is Castle && !board[row][col-2].hasMoved)
			{
				for (var c2:int = position.col-1; c2 >= col; c2--){
					if  (containsPiece(row, c2) || moveResultsInCheck(row, c2, true)){
						return false;
					}
				}
				return true;
			}
			
			return false;
		}
		

		public function isInCheck(alert:Boolean=false):Boolean
		{			
			for (var row:int = 0; row < 8; row++)
			{
				for (var col:int = 0; col < 8; col++)
				{
					var opponentPiece:ChessPiece = board[row][col];
					
					if (opponentPiece && opponentPiece.isWhite != isWhite)
					{
						opponentPiece.generateValidMoves();
												
						for each (var movePosition:PositionVO in opponentPiece.validMoves)
						{
							if (movePosition.equals(position))
							{
								if (alert){
									flashRed(3);
									opponentPiece.flashRed(3);
								}
								return true;
							}
						}
					}
				}
			}
			
			return false;
		}
		
		
	
		
		
	}
}