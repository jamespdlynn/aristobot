package com.aristobot.checkers.components
{
	import com.aristobot.checkers.data.Jump;
	import com.aristobot.checkers.data.Piece;
	import com.aristobot.checkers.data.Position;
	import com.aristobot.checkers.data.Positon;
	
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.graphics.BitmapSmoothingQuality;
	
	import spark.effects.Scale;
	import spark.primitives.BitmapImage;

	public class CheckersPiece extends Object
	{
		protected var data:Piece;
		
		public function get id():int{return data.id};
		
		public function get isRed():Boolean{return data.isRed};
		
		public function get position():Position{return data.position};
		public function set position(value:Position):void{data.position=value};
		
		public function get isCaptured():Boolean{return data.isCaptured};
		public function set isCaptured(value:Boolean):void{data.isCaptured=value};
				
		public function get isKing():Boolean{return data.isKing};
		public function set isKing(value:Boolean):void{return data.isKing = value};
		
		protected var _canCapture:Boolean;
		public function get canCapture():Boolean{_canCapture};
				
		protected var _image:BitmapImage;
		public function get image():BitmapImage{return _image};
		
		protected var _board:Vector.<Vector.<CheckersPiece>>;
		public function get board():Vector.<Vector.<CheckersPiece>>{return _board}	
		
		public function get clonedData():Piece{return data.clone();}
		
		protected var _validJumps:Dictionary;
		
		protected var _scale:Number;
		
		protected var _imageSize:Number;
		public function get imageSize():Number{
			return _imageSize;
		}
		
		public function set imageSize(value:Number):void{
			_imageSize = value;
			_scale = _imageSize/96;
			
			image.scaleX = _scale;
			image.scaleY = _scale;
		}
		
		protected var _scaleEffect:Scale;
		
		protected var _transformed:Boolean;
		
		protected var _timer:Timer;
		
		public static const FLASH_TIME:Number = 220;
		
		public function CheckersPiece(data:Piece):void
		{
			this.data = data;
					
			_image = new BitmapImage();
			_image.smoothingQuality = BitmapSmoothingQuality.HIGH;
			_image.smooth = true;
			//_image.source = imageSource;
			
			_timer = new Timer(FLASH_TIME);
			_timer.addEventListener(TimerEvent.TIMER, switchColor, false, 0, true);
			
			
		}
		
		public function initialize(board:Vector.<Vector.<CheckersPiece>, mustCapture):void
		{
			_board = board;	
			
			_scaleEffect = new Scale();
			_scaleEffect.autoCenterTransform = true;
			_scaleEffect.target = image;
			
			_validJumps = new Dictionary();
			_canCapture = false;
			
			if (isRed || isKing){
				generateValidJump(-1, 1,mustCapture);
				generateValidJump(-1, -1,mustCapture);
			}
			
			if (!isRed || isKing){
				generateValidJump(-1, 1,mustCapture);
				generateValidJump(-1, -1, mustCapture);
			}
		}
		

		public function getJump(row:int, col:int):Jump{
			return _validJumps[Position.toString(row, col)];
		}
		
		public function updatePosition(newPosition:Position):void{
			_board[data.position.row][data.position.col] = null;
			_board[newPosition.row][newPosition.col] = this;
			data.position = newPosition;
		}
		
		public function updateCaptured():void{
			_board[data.position.row][data.position.col] = null;
			data.isCaptured = true;
		}
		
		public function hasValidJumps():Boolean{
			for (var key:String in _validJumps) {
				if (key) return true;
			}
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

		
		protected function generateValidJump(deltaRow:int, deltaCol:int, mustCapture:Boolean):void{
			var row:int = position.row+deltaRow;
			var col:int = position.col+deltaCol;
			
			if (isValidPosition(row, col)){
				if (!board[row][col] && !mustCapture){
					_validJumps[Position.toString(row,col)] = new Jump(row, col);
				}
				else if(board[row][col].isRed == !isRed){
					var pieceTaken:CheckersPiece = board[row][col];
					row += deltaRow;
					col += deltaCol;
					
					if (isValidPosition(row,col) && !board[row][col]){
						_canCapture = true;
						_validJumps[Position.toString(row,col)] = new Jump(row, col, pieceTaken);
					}
					
				}
			}
		}

		
		protected function isValidPosition(row:int, col:int):Boolean
		{
			return (row >= 0 && row < board.length && col>= 0 && col < board[row].length);
		}
		
		
		protected function switchColor(event:TimerEvent):void
		{
			image.transform.colorTransform = (_transformed) ? new ColorTransform() : new ColorTransform(1, 0, 0);
			_transformed = !_transformed;
		}


		
		
		
		
	}
}