package com.aristobot.chess.pieces
{
	import com.aristobot.chess.data.ChessMove;
	import com.aristobot.chess.data.PieceVO;
	import com.aristobot.chess.data.PositionVO;
	
	public class Pawn extends ChessPiece
	{		
		
		[Embed (source="/chess_assets/images/white_pawn.png")]
		protected static const white:Class;
		
		[Embed (source="/chess_assets/images/black_pawn.png")]
		protected static const black:Class;
		
		public function Pawn(data:PieceVO):void
		{
			super(data);
		}
		
		override public function initialize(board:Vector.<Vector.<ChessPiece>>, king:King):void
		{
			super.initialize(board, king);
			
		}
		
		override public function get imageSource():Class
		{
			return (isWhite) ? white : black;
		}
	
		
		override public function generateValidMoves():void
		{
			_validMoves = new Vector.<PositionVO>;
			
			var oneStep:int = (isWhite) ? -1 : 1;
			var twoStep:int = (isWhite) ? -2: 2;
				
			if (isValidMove(position.row+oneStep, position.col)){
				validMoves.push(new PositionVO(position.row+oneStep, position.col));
			}
			
			if (isValidMove(position.row+twoStep, position.col)){
				validMoves.push(new PositionVO(position.row+twoStep, position.col));
			}
			
			if (isValidMove(position.row+oneStep, position.col-1)){
				validMoves.push(new PositionVO(position.row+oneStep, position.col-1));
			}
			
			if (isValidMove(position.row+oneStep, position.col+1)){
				validMoves.push(new PositionVO(position.row+oneStep, position.col+1));
			}
								
		}
		
		override protected function isValidMove(row:int, col:int):Boolean
		{
			if (!isValidPosition(row, col)) return false;
			
			var oneStep:int = (isWhite) ? -1 : 1;
			var twoStep:int = (isWhite) ? -2: 2;
			
			if (col == position.col)
			{
				if (row == position.row+oneStep && !containsPiece(row, col)){
					return true;
				}
				else if (row == position.row+twoStep && !hasMoved  && !containsPiece(row,col) && !containsPiece(position.row+oneStep, col)){
					return true;
				}
			}
			else if ((col == position.col+1 || col == position.col-1) && row == position.row+oneStep)
			{	
				if (containsOpponentPiece(row,col)){
					return true;
				}
				else if (containsOpponentPiece(position.row, col))
				{
					var piece:ChessPiece = board[position.row][col];
					if (piece is Pawn && (piece as Pawn).canBeTakenEnPassant()){
						return true;
					}
				}
			}
			
			
			return false;
		}
		
		override public function getMove(row:int, col:int):ChessMove
		{
			var move:ChessMove = super.getMove(row, col);
			
			if (move && !move.capturedPiece && col != position.col){				
				move.capturedPiece = board[position.row][col].clonedData;
			}
			
			return move;
		}
		
		override public function updatePosition(value:PositionVO):void
		{
			data.enPassant = Math.abs(value.row - position.row) == 2;
			super.updatePosition(value);
		}
		
		public function canBeTakenEnPassant():Boolean
		{
			return data.enPassant;
		}
		
			
		
	}
}