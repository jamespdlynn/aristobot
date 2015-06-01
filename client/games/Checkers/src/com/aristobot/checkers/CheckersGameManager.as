package com.aristobot.checkers
{
	import com.aristobot.checkers.components.CheckersPiece;
	import com.aristobot.checkers.data.Jump;
	import com.aristobot.checkers.data.Move;
	import com.aristobot.checkers.data.Piece;
	import com.aristobot.checkers.data.Position;

	public class CheckersGameManager
	{
		private var _boardData:Vector.<CheckersPiece>;
		
		private var _boardPieces:Vector.<Vector.<CheckersPiece>>;
		public function get boardPieces():Vector.<Vector.<CheckersPiece>>{
			return _boardPieces;
		}

		private var _playerCapturedPieces:Vector.<CheckersPiece>;
		public function get playerCapturedPieces():Vector.<CheckersPiece>{
			return _playerCapturedPieces;
		}
		
		private var _opponentCapturedPieces:Vector.<CheckersPiece>;
		public function get opponentCapturedPieces():Vector.<CheckersPiece>{
			return _opponentCapturedPieces;
		}
		
		private var _opponentCapturedPieces:Vector.<CheckersPiece>;
		public function get opponentCapturedPieces():Vector.<CheckersPiece>{
			return _opponentCapturedPieces;
		}
		
		private var _isFirstPlayer:Boolean;
		public function get isFirstPlayer():Boolean{
			return _isFirstPlayer;
		}
		public function set isFirstPlayer(value:Boolean):void{
			_isFirstPlayer = value;
		}
		
		private var _initialized:Boolean;
		public function get initialized():Boolean{
			return _initialized;
		}
		
		private var _currentMove:Move;
		public function get currentMove():Move{
			return _currentMove;
		}
		
		private var _currentPiece:CheckersPiece;

		private var _mustCapture:Boolean;

				
		public function CheckersGameManager(isFirstPlayer:Boolean):void
		{
			_isFirstPlayer = isFirstPlayer;
		}
				
		public function createBoard(boardData:Vector.<Piece>):void
		{
			_initialized = false;
			_mustCapture = false;
			_boardData = boardData;
			
			_boardPieces = new Vector.<Vector.<CheckersPiece>>(8);
			_opponentCapturedPieces = new Vector.<CheckersPiece>;
			_playerCapturedPieces = new Vector.<Piece>;
			
			for (var i:int = 0; i < 8; i++){
				boardPieces[i] = new Vector.<Piece>(8);
			}
			
			for each (var pieceData:Piece in boardData)
			{
				var checkersPiece:CheckersPiece = new CheckersPiece(pieceData);
				
				if (!pieceData.isCaptured){
					boardPieces[pieceData.row][pieceData.col] = pieceData;
				}
				else if (pieceData.isRed == isFirstPlayer){
					opponentCapturedPieces.push(checkersPiece)
				}
				else{
					playerCapturedPieces.push(checkersPiece);
				}
			}
		}
		
		public function createPreviousBoard(boardData:Vector.<Piece>, move:Move):Vector.<Piece>
		{
			var newBoardData:Vector.<Piece> = new Vector.<Piece>();
			
			for each (var pieceData:Piece in boardData)
			{				
				var newPieceData:Piece = pieceData.clone();
				
				if (newPieceData.id == move.pieceId){
					newPieceData.position = move.oldPosition;
					if (move.transformed){
						newPieceData.isKing = false;
					}
				}
				else if (newPieceData.isCaptured && move.hasCapturedPieceId(newPieceData.id){
					newPieceData.isCaptured = false;
				}
					
				newBoardData.push(newPieceData);
			}
			
			createBoard(newBoardData);
			
			return newBoardData;
		}
		
		public function createNextBoard(boardData:Vector.<Piece>, move:Move):Vector.<Piece>
		{				
			var newBoardData:Vector.<Piece> = new Vector.<Piece>();
			
			for each (var pieceData:Piece in boardData)
			{				
				var newPieceData:Piece = pieceData.clone();
				
				if (newPieceData.id == move.pieceId)
				{
					newPieceData.position = move.getNewPosition();
					
					if (move.transformed){
						newPieceData.isKing = true;
					}
				}
				else if (!newPieceData.isCaptured && move.hasCapturedPieceId(newPieceData.id){
					newPieceData.isCaptured = true;
				}
					
				newBoardData.push(newPieceData);
			}
			
			createBoard(newBoardData);
			
			return newBoardData;
		}
		
		public function initializeCheckersBoard():void
		{
			if (_initialized) return;
			
			if (!_boardPieces){
				throw new Error("Must create board first");
			}
						
			for (var row:int = 0; row < 8; row++)
			{
				for (var col:int = (row+1)%2; col < 8; col+=2)
				{
					var checkersPiece:CheckersPiece = boardPieces[row][col];
					
					if (checkersPiece && checkersPiece.isRed == isFirstPlayer){
						checkersPiece.initialize(boardPieces, _mustCapture);
						
						if (!_mustCapture && checkersPiece.canCapture){
							_mustCapture = true;
						}
					}
				}
			}
			
			_initialized = true;
		}
		
		public function beginMove(piece:CheckersPiece):Boolean{
			
			if (!_initialized){
				throw new Error("Must initalize game board first");
			}
	
			if (!piece.hasValidJumps() || (mustCapture && !piece.canCapture){
				return false;
			}
				
			_currentPiece = piece;
			_currentMove = new Move(piece.id, piece.position);
			
			return true;
			
		}
		
		public function updateBoard(jump:Jump):Boolean
		{
			if (!_currentMove){
				throw new Error("Must begin move first");
			}
			
			_currentMove.jumps.push();			
			_currentPiece.updatePosition(jump.position);
			
			if (jump.capturedPieceId){
				findPieceById(jump.capturedPieceId).updateCaptured();
				_currentPiece.initialize(_boardPieces);
				
				if (_currentPiece.canCapture){
					return false;
				}
			}
			
			return true;
			
		}
		
		protected function findPieceById(id):CheckersPiece{
			for (var row:int = 0; row < 8; row++)
			{
				for (var col:int = (row+1)%2; col < 8; col+=2){
					var piece =_boardPieces[row][col];
					if (piece && piece.id == id){
						return piece;
					}
				}
			}
			return null
		}
	
		

		
		
	}
}