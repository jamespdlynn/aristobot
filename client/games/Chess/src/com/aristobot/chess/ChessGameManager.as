package com.aristobot.chess
{
	import com.aristobot.chess.data.ChessMove;
	import com.aristobot.chess.data.PieceVO;
	import com.aristobot.chess.data.PositionVO;
	import com.aristobot.chess.pieces.Bishop;
	import com.aristobot.chess.pieces.ChessPiece;
	import com.aristobot.chess.pieces.King;
	import com.aristobot.chess.pieces.Knight;
	import com.aristobot.chess.pieces.Pawn;

	public class ChessGameManager
	{
		public static const CHECK_STATUS:String = "check";
		public static const CHECK_MATE_STATUS:String = "checkMate";
		public static const STALE_MATE_STATUS:String = "staleMate";
		
		private var _boardPieces:Vector.<Vector.<ChessPiece>>;
		public function get boardPieces():Vector.<Vector.<ChessPiece>>{
			return _boardPieces;
		}

		private var _playerCapturedPieces:Vector.<ChessPiece>;
		public function get playerCapturedPieces():Vector.<ChessPiece>{
			return _playerCapturedPieces;
		}
		
		private var _opponentCapturedPieces:Vector.<ChessPiece>;
		public function get opponentCapturedPieces():Vector.<ChessPiece>{
			return _opponentCapturedPieces;
		}

		protected var _playerKing:King;
		public function get playerKing():King{
			return _playerKing;
		}
		protected var _opponentKing:King;
		public function get opponentKing():King{
			return _opponentKing;
		}
		
		protected var _isFirstPlayer:Boolean;
		public function get isFirstPlayer():Boolean{
			return _isFirstPlayer;
		}
		public function set isFirstPlayer(value:Boolean):void{
			_isFirstPlayer = value;
		}
		
		protected var _initialized:Boolean;
		public function get initialized():Boolean{
			return _initialized;
		}
		
		public function ChessGameManager(isFirstPlayer:Boolean):void
		{
			_isFirstPlayer = isFirstPlayer;
			
		}
		
		public function createPreviousBoard(boardData:Vector.<PieceVO>, move:ChessMove):Vector.<PieceVO>
		{
			var newBoardData:Vector.<PieceVO> = new Vector.<PieceVO>();
			
			for each (var pieceData:PieceVO in boardData)
			{				
				var newPieceData:PieceVO = pieceData.clone();
				
				if (!newPieceData.captured)
				{
					if (newPieceData.position.equals(move.newPosition))
					{
						newPieceData.position = move.oldPosition;
						
						if (move.transformation){
							newPieceData.type = move.transformation.oldType;
						}
					}
					else if (move.subsequentMove && newPieceData.position.equals(move.subsequentMove.newPosition)){
						newPieceData.position= move.subsequentMove.oldPosition;
					}
				}
				else if (move.capturedPiece && move.capturedPiece.id == newPieceData.id){
					newPieceData.captured = false;
				}
				
				newBoardData.push(newPieceData);
			}
			
			createBoard(newBoardData);
			
			return newBoardData;
		}
		
		public function createNextBoard(boardData:Vector.<PieceVO>, move:ChessMove):Vector.<PieceVO>
		{				
			var newBoardData:Vector.<PieceVO> = new Vector.<PieceVO>();
			
			for each (var pieceData:PieceVO in boardData)
			{				
				var newPieceData:PieceVO = pieceData.clone();
				
				if (!newPieceData.captured)
				{
					if (newPieceData.position.equals(move.oldPosition))
					{
						newPieceData.position = move.newPosition;
						
						if (move.transformation){
							newPieceData.type = move.transformation.newType;
						}
						
					}
					else if(move.capturedPiece && move.capturedPiece.id == newPieceData.id){
						newPieceData.captured = true;
					}
					else if (move.subsequentMove && newPieceData.position.equals(move.subsequentMove.oldPosition)){
						newPieceData.position= move.subsequentMove.newPosition;
					}
				}
				
				newBoardData.push(newPieceData);
			}
			
			createBoard(newBoardData);
			
			return newBoardData;
		}
		
		public function createBoard(boardData:Vector.<PieceVO>):void
		{
			_initialized = false;
			
			_boardPieces = new Vector.<Vector.<ChessPiece>>;
			_opponentCapturedPieces = new Vector.<ChessPiece>;
			_playerCapturedPieces = new Vector.<ChessPiece>;
			
			for (var i:int = 0; i < 8; i++){
				boardPieces[i] = new Vector.<ChessPiece>(8);
			}
			
			for each (var pieceData:PieceVO in boardData)
			{
				var chessPiece:ChessPiece = ChessPiece.generate(pieceData);
				
				//We want to negate any enpassant flags on our own pieces
				if (pieceData.enPassant && chessPiece.isWhite == isFirstPlayer){
					pieceData.enPassant = false;
				}
				
				if (!pieceData.captured)
				{
					boardPieces[pieceData.row][pieceData.col] = chessPiece;
					
					if (chessPiece is King){
						(chessPiece.isWhite == isFirstPlayer) ? _playerKing = chessPiece as King : _opponentKing = chessPiece as King;
					}	
				}
				else if (pieceData.isWhite == isFirstPlayer){
					opponentCapturedPieces.push(chessPiece)
				}
				else{
					playerCapturedPieces.push(chessPiece);
				}
			}
		}
		
		public function initializeChessBoard():void
		{
			if (_initialized) return;
			
			if (!_boardPieces){
				throw new Error("Must create board First");
			}
						
			for (var row:int = 0; row < 8; row++)
			{
				for (var col:int = 0; col < 8; col++)
				{
					var chessPiece:ChessPiece = boardPieces[row][col];
					
					if (chessPiece){
						var king:King = (chessPiece.isWhite == isFirstPlayer) ? playerKing : opponentKing;
						chessPiece.initialize(boardPieces, king);
					}
				}
			}
			
			_initialized = true;
		}
		
		public function updateBoard(move:ChessMove):void
		{
			if (!_initialized){
				throw new Error("Must initalize game board first");
			}

			if (move.capturedPiece){
				boardPieces[move.capturedPiece.row][move.capturedPiece.col].updateCaptured();
				boardPieces[move.capturedPiece.row][move.capturedPiece.col] = null;
			}
		
			var piece:ChessPiece =  boardPieces[move.oldPosition.row][move.oldPosition.col];
			piece.updatePosition(move.newPosition);
			
			if (move.transformation){
				piece.updateType(move.transformation.newType);
				piece = ChessPiece.generate(piece.clonedData);
				piece.initialize(boardPieces, playerKing);
			}
			
			boardPieces[move.oldPosition.row][move.oldPosition.col] = null;
			boardPieces[move.newPosition.row][move.newPosition.col] = piece;
			
			if (move.subsequentMove)
			{
				var subsequentPiece:ChessPiece = boardPieces[move.subsequentMove.oldPosition.row][move.subsequentMove.oldPosition.col]; 
				subsequentPiece.updatePosition(move.subsequentMove.newPosition);
				
				boardPieces[move.subsequentMove.oldPosition.row][move.subsequentMove.oldPosition.col] = null;
				boardPieces[move.subsequentMove.newPosition.row][move.subsequentMove.newPosition.col] = subsequentPiece;
			}
		}
		
		public function getOpponentCheckStatus():String
		{
			if (!_initialized){
				throw new Error("Must initalize game board first");
			}
			
			if (opponentHasMoves()){
				
				if (isCheckmatePossible()){
					return opponentKing.isInCheck() ? CHECK_STATUS : null;
				}else{
					return STALE_MATE_STATUS;
				}
				
			}
			else{
				return opponentKing.isInCheck() ? CHECK_MATE_STATUS : STALE_MATE_STATUS;
			}
			
			return null;
		}		
		
		protected function opponentHasMoves():Boolean
		{
			
			for (var row:int = 0; row < 8; row++)
			{
				for (var col:int = 0; col < 8; col++)
				{
					var chessPiece:ChessPiece = boardPieces[row][col];
					
					if (chessPiece && chessPiece.isWhite != isFirstPlayer)
					{
						chessPiece.generateValidMoves();
						
						for each (var movePosition:PositionVO in chessPiece.validMoves){
							if (!chessPiece.moveResultsInCheck(movePosition.row, movePosition.col)){
								return true;
							}
						}
					}
				}	
			}
			
			return false;
		}
		
		protected function isCheckmatePossible():Boolean
		{
			
			var otherWhitePiece:ChessPiece;
			var otherBlackPiece:ChessPiece;
			
			for (var row:int = 0; row < 8; row++)
			{
				for (var col:int = 0; col < 8; col++)
				{
					var chessPiece:ChessPiece = boardPieces[row][col];
					
					//Ignore kings
					if (chessPiece && !(chessPiece is King)){
						
						//If chess piece exists that isn't a bishop or a knight: then checkmate still possible
						if (!(chessPiece is Bishop) && !(chessPiece is Knight)){
							return true;
						}
					
						if (chessPiece.isWhite){
							if (otherWhitePiece) return true; //If white has more than one knight or bishop: checkmate still possible
							otherWhitePiece = chessPiece;
						}else{
							if (otherBlackPiece) return true; //If black has more than one knight or bishop: checkmate still possible
							otherBlackPiece = chessPiece;
						}
					}
				}
			}
						
			//If king vs king or king+bishop vs king or king+knight vs. king: checkmate not possible 
			if (!otherWhitePiece || !otherBlackPiece){
				return false;
			}
			
			//If king+bishop vs king+bishop and both bishops on the same colour square: checkmate not possible
			if (otherWhitePiece is Bishop && otherBlackPiece is Bishop && otherWhitePiece.position.isEven() == otherBlackPiece.position.isEven()){
				return false;
			}
			
			return true;

		}
		
		
		
	}
}