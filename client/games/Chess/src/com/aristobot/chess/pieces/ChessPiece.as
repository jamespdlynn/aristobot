package com.aristobot.chess.pieces
{
	import com.aristobot.chess.data.ChessMove;
	import com.aristobot.chess.data.PieceVO;
	import com.aristobot.chess.data.PositionVO;
	
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import mx.graphics.BitmapSmoothingQuality;
	
	import spark.effects.Scale;
	import spark.primitives.BitmapImage;

	public class ChessPiece extends Object
	{
		protected var data:PieceVO;
		
		public function get isWhite():Boolean{return data.isWhite}
		
		public function get position():PositionVO{return data.position};
		
		public function get hasMoved():Boolean{return data.hasMoved}
		
		public function get type():String{return data.type};
		
		public function get formattedType():String{return data.formattedType};
		
		public function get clonedData():PieceVO{
			return data.clone();
		}

		protected var _image:BitmapImage;
		public function get image():BitmapImage{return _image}
		
		protected var _board:Vector.<Vector.<ChessPiece>>;
		public function get board():Vector.<Vector.<ChessPiece>>{return _board}
		
		protected var _validMoves:Vector.<PositionVO>;
		public function get validMoves():Vector.<PositionVO>{return _validMoves}
		
		protected var _king:King;

		protected var _scale:Number;
		
		protected var _imageSize:Number;
		
		protected var _scaleEffect:Scale;
		
		protected var _transformed:Boolean;
		
		protected var _timer:Timer;
		
		public static const FLASH_TIME:Number = 220;
		
		public function ChessPiece(data:PieceVO):void
		{
			this.data = data;
					
			_image = new BitmapImage();
			_image.smoothingQuality = BitmapSmoothingQuality.HIGH;
			_image.smooth = true;
			_image.source = imageSource;
			
			_timer = new Timer(FLASH_TIME);
			_timer.addEventListener(TimerEvent.TIMER, switchColor, false, 0, true);
		}
		
		public static function generate(vo:PieceVO):ChessPiece
		{
			return new (getDefinitionByName(vo.type))(vo);			
		}
		
		public function initialize(board:Vector.<Vector.<ChessPiece>>, king:King):void
		{
			_board = board;	
			_king = king;
			
			_scaleEffect = new Scale();
			_scaleEffect.autoCenterTransform = true;
			_scaleEffect.target = image;
		}
		
		/**
		 * Calculates and stores valid moves
		 * Must be override this function
		 */
		public function generateValidMoves():void
		{
			throw new Error("Must override this function");
		}
		
		public function get imageSource():Class
		{
			throw new Error("Override this function");
		}

		/**
		 * Function to determine if a point on the board is a valid move for this piece
		 */
		protected function isValidMove(row:int, col:int):Boolean
		{
			return isValidPosition(row, col) && !containsPlayerPiece(row,col);
		}	
		

		
		public function getMove(row:int, col:int):ChessMove
		{
			if (canMove(row, col))
			{
				var newPosition:PositionVO = new PositionVO(row, col);
				var capturedPiece:PieceVO = (_board[row][col]) ? _board[row][col].data : null;
				var move:ChessMove = new ChessMove(position, newPosition, capturedPiece);
				
				return move;
			}
		
			return null;
			
		}
		
		protected function canMove(row:int, col:int):Boolean
		{
			var newPosition:PositionVO = new PositionVO(row, col);
			
			for each (var movablePosition:PositionVO in validMoves)
			{
				if (movablePosition.equals(newPosition)){
					return !moveResultsInCheck(row, col, true);
				}
			}
			
			return false;
		}
		
		public function get imageSize():Number
		{
			return _imageSize;
		}
		
		public function set imageSize(value:Number):void
		{
			_imageSize = value;
			
			_scale = _imageSize/96;
			
			image.scaleX = _scale;
			image.scaleY = _scale;
		}

		public function scaleUp(duration:Number = 400):void
		{
			var newScale:Number = (_scale < 1) ? Math.min(1, _scale + 0.3) : _scale;
			
			_scaleEffect.scaleXTo = newScale;
			_scaleEffect.scaleYTo = newScale;
			_scaleEffect.duration = duration;
			_scaleEffect.play();
		}
		
		public function scaleDown():void
		{
			_scaleEffect.stop();
			image.scaleX = _scale;
			image.scaleY = _scale;
		}
		
		
		public function flashRed(numFlashes:int = 1):void
		{
			if (!_timer.running)
			{
				image.transform.colorTransform = (_transformed) ? new ColorTransform() : new ColorTransform(1, 0, 0);
				_transformed = true;

				_timer.repeatCount = numFlashes*2-1;

				_timer.reset();
				_timer.start();
			}
		}
		
		protected function switchColor(event:TimerEvent):void
		{
			image.transform.colorTransform = (_transformed) ? new ColorTransform() : new ColorTransform(1, 0, 0);
			_transformed = !_transformed;
		}
		
		public function updatePosition(value:PositionVO):void
		{
			data.position = value;
			data.hasMoved = true;
		}
		
		public function updateType(type:String):void
		{
			data.type = type;
		}
		
		public function updateCaptured():void
		{
			data.captured = true;
		}
		
		protected function isValidPosition(row:int, col:int):Boolean
		{
			return (row >= 0 && row < board.length && col>= 0 && col < board[row].length);
		}
		
		protected function containsPiece(row:int, col:int):Boolean
		{
			return board[row][col];
		}
		
		protected function containsPlayerPiece(row:int, col:int):Boolean
		{
			return board[row][col] && board[row][col].isWhite == isWhite;
		}
		
		protected function containsOpponentPiece(row:int, col:int):Boolean
		{
			return board[row][col] && board[row][col].isWhite != isWhite;
		}
		
		
		public function moveResultsInCheck(row:int, col:int, alert:Boolean=false):Boolean
		{						
			var newPosition:PositionVO = new PositionVO(row, col);
			var oldPosition:PositionVO = new PositionVO(position.row, position.col);
			var capturedPiece:ChessPiece = board[newPosition.row][newPosition.col];
			
			board[oldPosition.row][oldPosition.col] = null;
			board[newPosition.row][newPosition.col] = this;
			data.position = newPosition;
		
			var isInCheck:Boolean = _king.isInCheck(alert);
			
			board[oldPosition.row][oldPosition.col] = this;
			board[newPosition.row][newPosition.col] = capturedPiece;
			data.position = oldPosition;

			return isInCheck;
		}

		protected function iterateHorizontally():void
		{
			var row1:int = position.row;
			var col1:int = position.col-1;
			
			var row2:int = position.row;
			var col2:int = position.col+1;
			
			while (iterate(row1, col1)){
				col1--;
			}
			
			while (iterate(row2, col2)){
				col2++;
			}
		}
		
		protected function iterateVertically():void
		{
			var row1:int = position.row-1;
			var col1:int = position.col;
			
			var row2:int = position.row+1;
			var col2:int = position.col;
			
			while (iterate(row1, col1)){
				row1--;
			}
			
			while (iterate(row2, col2)){
				row2++;
			}
		}
		
		protected function iterateDiagnallyLeft():void
		{
			var row1:int = position.row-1;
			var col1:int = position.col-1;
			
			var row2:int = position.row+1;
			var col2:int = position.col+1;
			
			while (iterate(row1, col1)){
				row1--;
				col1--;
			}

			while (iterate(row2, col2)){
				row2++;
				col2++;
			}
		}
		
		protected function iterateDiagnallyRight():void
		{
			var row1:int = position.row+1;
			var col1:int = position.col-1;
			
			var row2:int = position.row-1;
			var col2:int = position.col+1;
			
			while (iterate(row1, col1)){
				row1++;
				col1--;
			}
			
			while (iterate(row2, col2)){
				row2--;
				col2++;
			}
		}
		
		private function iterate(row:int, col:int):Boolean
		{
			if (!isValidPosition(row, col)){
				return false;
			}
			else if (containsPiece(row,col))
			{
				if (containsOpponentPiece(row,col)){
					_validMoves.push(new PositionVO(row,col));
				}
					
				return false;
			}
			else{
				_validMoves.push(new PositionVO(row,col));
				return true;
			}
		}
		
		
		
		
		
	}
}