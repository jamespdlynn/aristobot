package com.aristobot.checkers
{
	import com.aristobot.as3srserrvice.model.Status;
	import com.aristobot.checkers.components.CapturedDataGroup;
	import com.aristobot.checkers.components.CheckersPiece;
	import com.aristobot.checkers.data.GameState;
	import com.aristobot.checkers.data.Piece;
	import com.aristobot.checkers.data.Position;
	import com.aristobot.data.ICustomGameObject;
	import com.aristobot.data.Player;
	import com.aristobot.flexmobile.components.IGameBoard;
	import com.aristobot.flexmobile.data.GameBoardUpdateData;
	import com.aristobot.flexmobile.model.AlertManager;
	import com.aristobot.flexmobile.model.SoundManager;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import mx.core.BitmapAsset;
	import mx.core.FlexTextField;
	import mx.core.UIComponent;
	import mx.events.EffectEvent;
	
	import spark.components.Group;
	import spark.effects.Move;
	import spark.primitives.BitmapImage;
	
	import avmplus.getQualifiedClassName;
	
	public class CheckersBoard extends Group implements IGameBoard
	{
		protected var gm:CheckersGameManager;
		
		protected var boardBkg:UIComponent;		
		protected var boardSize:int;
		protected var squareSize:int;
		protected var squarePadding:int;
		
		//[Embed(source="/checkers_assets/images/tile_light.png")]
		protected  var WhiteTileClass:Class;
		
		protected static const RED_BOARD_COLOR:uint = 0x6F1311;
		protected static const BLUE_BOARD_COLOR:uint = 0x274277;
		protected static const GREEN_BOARD_COLOR:uint = 0x254017;
		
		//[Embed(source="/checkers_assets/images/tile_red.png")]
		protected var RedTileClass:Class;
		//[Embed(source="/checkers_assets/images/tile_blue.png")]
		protected var BlueTileClass:Class;
		//[Embed(source="/checkers_assets/images/tile_green.png")]
		protected var GreenTileClass:Class;
		
		protected var measured:Boolean;
		protected var boardDrawn:Boolean;
		
		protected var points:Vector.<Vector.<Point>>;
		
		protected var checkersPiecesGroup:Group;
		
		protected var playerCapturedGroup:CapturedDataGroup;
		
		protected var opponentCapturedGroup:CapturedDataGroup;
		
		protected var borderStroke:Number;
		
		protected var horizontalPadding:Number;
		protected var verticalPadding:Number;
		
		protected var grabbedPiece:CheckersPiece;

		protected var player:Player;
		
		protected var lastMove:Move;	
		
		protected var currentGameState:GameState;
		
		protected var currentMove:Move;
		
		protected var _playEnabled:Boolean;
		[Bindable]
		public function get playEnabled():Boolean{
			return _playEnabled;
		}
		public function set playEnabled(value:Boolean):void{
			_playEnabled = value;
		}
				
		protected var nextMove:Move;
		protected var nextMoveCompleteCallback:Function;
		
		public function CheckersBoard():void
		{
			measured = false;
			boardDrawn = false;
		}
		
		public function createInitialGameState():ICustomGameObject
		{
			var initialGameState:GameState = new GameState();
			
			initialGameState.pieces = new Vector.<Piece>(40);
			
			for (var row:int = 0; row < 3; row++)
			{
				for (var col:int = (row+1)%2; col < 8; col+=2){
					var piece:Piece = new Piece(initialGameState.pieces.length, new Position(row, col), false);
					initialGameState.pieces.push(piece);
				}
			}
			
			for (var row:int = 0; row < 3; row++)
			{
				for (var col:int = (row+1)%2; col < 8; col+=2){
					var piece:Piece = new Piece(initialGameState.pieces.length, new Position(row, col), true);
					initialGameState.pieces.push(piece);
				}
			}
			
			var rand:Number = Math.floor(Math.random()*3);
			initialGameState.boardColor = (rand == 0) ? RED_BOARD_COLOR : ((rand == 1) ? BLUE_BOARD_COLOR : GREEN_BOARD_COLOR);
			
			return initialGameState;
		}
		
		public function initializeGame(customGameState:ICustomGameObject, currentPlayer:Player, previousMove:ICustomGameObject = null, redrawBoard:Boolean=false):void
		{
			resetGameData();
			
			currentGameState = customGameState as GameState;
			player = currentPlayer;
			lastMove = previousMove as Move;
			
			if (!currentGameState || !player || !currentGameState.pieces || !currentGameState.pieces.length == 40){
				AlertManager.displayNotificaitonWindow("Checkers data not in expected format");
				return;
			}
			
			if (redrawBoard){
				resetBoard();
			}
			
			gm = new CheckersGameManager(player.isFirstPlayer);
			
			if (lastMove){
				gm.createPreviousBoard(currentGameState.pieces, lastMove);
			}
			else{
				gm.createBoard(currentGameState.pieces);
			}
			
			if (measured)
			{
				if (!boardDrawn){
					drawBoard();
				}
				
				drawCheckersPieces();
			}
			
		}
		
		public function resetBoard():void
		{
			if (boardBkg){
				boardBkg.graphics.clear();
			}
			
			points = null;
			boardDrawn = false;
		}
		
		public function resetGameData():void
		{
			player = null;
			currentGameState = null;
			grabbedPiece = null;
			gm = null;
			
			lastMove =null;
			nextMove = null;
			nextMoveCompleteCallback = null;
			
			currentMove = null;	
			
			if (checkersPiecesGroup){
				checkersPiecesGroup.removeAllElements();
				checkersPiecesGroup.mouseEnabled = false;
			}
			
			if (playerCapturedGroup){
				playerCapturedGroup.reset();
			}
			
			if (opponentCapturedGroup){
				opponentCapturedGroup.reset();
			}
			
			playEnabled = false;
		}
		
		
		public function run():void
		{
			if (currentGameState)
			{
				if (lastMove != null){
					movePiece(lastMove, lastMoveCompleteHandler);
				}
				else{
					prepareForPlay();
				}
			}
		}
		
		
		protected function prepareForPlay():void
		{	 
			if (player.isTurn){
				gm.initializeCheckersBoard();
			}
			
			checkersPiecesGroup.mouseEnabled = true;
			playEnabled = false;
			drawCheckersPieces();
		}
		
		public function cycleNextMove(move:ICustomGameObject):void
		{
			nextMove = null;
			nextMoveCompleteCallback = null;
			
			currentGameState.pieces = gm.createNextBoard(currentGameState.pieces, move as Move);
			drawCheckersPieces();
			
			var checkersMove:Move = move as Move;
			
		}
		
		public function cyclePreviousMove(move:ICustomGameObject):void
		{
			nextMove = null;
			nextMoveCompleteCallback = null;
			
			currentGameState.pieces = gm.createPreviousBoard(currentGameState.pieces, move as Move);
			drawCheckersPieces();
		}
		
		public function playNextMove(move:ICustomGameObject, moveCompleteHandler:Function):void
		{
			nextMove = move as Move;
			nextMoveCompleteCallback = moveCompleteHandler;
			
			movePiece(nextMove, nextMoveCompleteHandler);
		}
		
		protected function nextMoveCompleteHandler(event:EffectEvent):void
		{
			if (nextMove)
			{
				if (nextMove.subsequentMove && !movedSubsequent){
					movePiece(nextMove.subsequentMove, nextMoveCompleteHandler);
					movedSubsequent = true;
				}
				else
				{
					movedSubsequent = false;
					currentGameState.pieces = gm.createNextBoard(currentGameState.pieces, nextMove);
					drawCheckersPieces();
					
					if (nextMove.isCheck){
						var piece:CheckersPiece = gm.boardPieces[nextMove.newPosition.row][nextMove.newPosition.col];
						(piece.isWhite == player.isFirstPlayer) ? gm.opponentKing.flashRed(4) : gm.playerKing.flashRed(4);
						setTimeout(nextMoveCompleteCallback, CheckersPiece.FLASH_TIME*4);
					}
					else{
						nextMoveCompleteCallback();
					}
				}
				
				SoundManager.playSound(SoundManager.DROP);
			}
			
			
		}
		
		public function revertTurn():void
		{
			drawCheckersPieces();
			checkersPiecesGroup.mouseEnabled = true;
			playEnabled = false;
		}
		
		public function executeTurn():GameBoardUpdateData
		{
			checkersPiecesGroup.mouseEnabled = false;
			gm.updateBoard(currentMove);
			
			var updateData:GameBoardUpdateData = new GameBoardUpdateData();
			updateData.turnMessage = player.username + " ";
			
			if (currentMove.subsequentMove)
			{
				updateData.turnMessage += "castles ";
				updateData.turnMessage += currentMove.newPosition.col > currentMove.oldPosition.col ? "kingside." : "queenside.";
			}
			else
			{
				updateData.turnMessage +=  grabbedPiece.formattedType + " ";
				updateData.turnMessage += currentMove.oldPosition.toString() + " ";
				
				if (currentMove.capturedPiece){
					updateData.turnMessage += "captures " + currentMove.capturedPiece.formattedType + " " + currentMove.newPosition.toString();
					updateData.turnMessage += !currentMove.capturedPiece.position.equals(currentMove.newPosition) ? " en passant." : ".";
				}
				else{
					updateData.turnMessage += "to " + currentMove.newPosition.toString() +".";
				}
			}
			
			if (currentMove.transformation){
				updateData.turnMessage += " Promotes "+ grabbedPiece.formattedType+"!";
			}
			
			switch (gm.getOpponentCheckStatus())
			{
				case CheckersGameManager.CHECK_MATE_STATUS:
					currentMove.isCheck = true;
					updateData.outcome = Status.PLAYER_WON;
					updateData.turnMessage += " Checkmate!!";
					break;
				
				case CheckersGameManager.STALE_MATE_STATUS:
					currentMove.isCheck = false;
					updateData.outcome = Status.PLAYER_TIED;
					updateData.turnMessage += " Stalemate.";
					break;
				
				case CheckersGameManager.CHECK_STATUS:
					currentMove.isCheck = true;
					updateData.outcome = Status.PLAYER_PLAYING;
					updateData.turnMessage += " Check!";
					break;
				
				default:
					currentMove.isCheck = false;
					updateData.outcome = Status.PLAYER_PLAYING;
					break;
			}
			
			currentGameState.isInCheck = currentMove.isCheck; 
			playEnabled = false;
			
			updateData.gameMove = currentMove;
			updateData.newGameState = currentGameState;
			
			return updateData;
		}
		
		
		override protected function createChildren():void
		{	
			boardBkg = new UIComponent();
			boardBkg.cacheAsBitmap = true;
			boardBkg.cacheAsBitmapMatrix = new Matrix();
			addElement(boardBkg);
			
			var textFilter:DropShadowFilter = new DropShadowFilter(2, 45, 0x00000, 0.6);
			
			for (var i:int = 0; i < 16; i++){
				var tf:FlexTextField = new FlexTextField();
				tf.mouseEnabled = false;
				tf.filters = [textFilter];
				boardBkg.addChild(tf);
			}
			
			checkersPiecesGroup = new Group();	
			checkersPiecesGroup.cacheAsBitmap = true;
			checkersPiecesGroup.addEventListener(MouseEvent.MOUSE_DOWN, grabPiece, false, 0, true);
			addElement(checkersPiecesGroup);
			
			if (player){
				checkersPiecesGroup.mouseEnabled = player.isTurn;
			}
			
			playerCapturedGroup = new CapturedDataGroup();
			playerCapturedGroup.cacheAsBitmap = true;
			addElement(playerCapturedGroup);
			
			if (gm && gm.playerCapturedPieces){
				playerCapturedGroup.parseCapturedPieces(gm.playerCapturedPieces);
			}
			
			opponentCapturedGroup = new CapturedDataGroup();
			opponentCapturedGroup.cacheAsBitmap = true;
			addElement(opponentCapturedGroup);
			
			if(gm && gm.opponentCapturedPieces){
				opponentCapturedGroup.parseCapturedPieces(gm.opponentCapturedPieces);
			}
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (!measured)
			{
				boardSize = Math.min(unscaledWidth, Math.round(unscaledHeight*0.82));
				squareSize = Math.round(boardSize /8);
				squarePadding = Math.floor(squareSize/20);
				
				horizontalPadding= Math.round((unscaledWidth-boardSize)/2);
				verticalPadding = Math.round((unscaledHeight-boardSize)/2);
				
				borderStroke = 6;
				
				boardBkg.x = horizontalPadding;
				boardBkg.y = verticalPadding;
				boardBkg.width = boardSize;
				boardBkg.height = boardSize;
				
				checkersPiecesGroup.x = horizontalPadding;
				checkersPiecesGroup.y = verticalPadding;
				checkersPiecesGroup.width = boardSize;
				checkersPiecesGroup.height = boardSize;
				
				var additionalPadding:Number = Math.round(squareSize/3);
				var capturedGroupHeight:Number = Math.min(48, verticalPadding-borderStroke-additionalPadding);
				
				opponentCapturedGroup.x = horizontalPadding+4;
				opponentCapturedGroup.y = verticalPadding-borderStroke-capturedGroupHeight-(additionalPadding*0.25);
				opponentCapturedGroup.width = unscaledWidth-(2*horizontalPadding)-8;
				opponentCapturedGroup.height = capturedGroupHeight;
				
				playerCapturedGroup.x = horizontalPadding+4;
				playerCapturedGroup.y = boardSize+verticalPadding+borderStroke+(additionalPadding*0.75);
				playerCapturedGroup.width = unscaledWidth-(2*horizontalPadding)-8;
				playerCapturedGroup.height = capturedGroupHeight;
				
				measured = true;
				
				if (currentGameState){
					drawBoard();
					drawCheckersPieces();
				}
			}
			
			super.updateDisplayList(unscaledWidth, unscaledWidth);
		}
		
		
		protected function drawBoard():void
		{
			if (!player || !currentGameState || !measured){
				return;
			}
			
			var boardColor:uint = currentGameState.boardColor > 0 ? currentGameState.boardColor : RED_BOARD_COLOR;
			var lightTileBitmap:BitmapAsset = new WhiteTileClass() as BitmapAsset;
			var darkTileBitmap:BitmapAsset;	
			
			switch (boardColor){
				case RED_BOARD_COLOR:
					darkTileBitmap = new RedTileClass() as BitmapAsset;
					break;
				
				case BLUE_BOARD_COLOR:
					darkTileBitmap = new BlueTileClass() as BitmapAsset;
					break;
				
				case GREEN_BOARD_COLOR:
					darkTileBitmap = new GreenTileClass() as BitmapAsset;
					break;
				
				default:
					darkTileBitmap = new BlueTileClass() as BitmapAsset;
					break;
				
			}
			
			points = new Vector.<Vector.<Point>>;
			
			var x:int = (player.isFirstPlayer) ? 0 : 7*squareSize;
			var y:int = (player.isFirstPlayer) ? 0 : 7*squareSize;
			
			for (var row:int = 0; row < 8; row++)
			{
				points[row] = new Vector.<Point>(8);
				
				for (var col:int = 0; col < 8; col++)
				{
					var bitmapData:BitmapData= (row+col)%2 == 0 ? lightTileBitmap.bitmapData: darkTileBitmap.bitmapData;
					
					boardBkg.graphics.beginBitmapFill(bitmapData, null, true, true);
					
					boardBkg.graphics.drawRect(x, y, squareSize, squareSize);
					boardBkg.graphics.endFill();
					points[row][col] = new Point(x,y);
					
					x = (player.isFirstPlayer) ? x+squareSize : x-squareSize;
				}
				x = (player.isFirstPlayer) ? 0 : 7*squareSize;;
				y = (player.isFirstPlayer) ? y+squareSize : y-squareSize;
				
			}
			
			var dashLength:int = Math.round(squareSize/3);			
			boardBkg.graphics.lineStyle(6, 0xFFFFFF);
			
			var left:int = -2;
			var right:int = boardSize;
			var top:int = -3;
			var bottom:int = boardSize;
			
			boardBkg.graphics.moveTo(left, top);
			
			if (boardSize < unscaledWidth)
			{
				boardBkg.graphics.lineTo(right, top);
				boardBkg.graphics.lineTo(right, bottom);
				boardBkg.graphics.lineTo(left, bottom);
				boardBkg.graphics.lineTo(left, top);
			}
			else{
				boardBkg.graphics.lineTo(right, top);
				boardBkg.graphics.moveTo(right, bottom);
				boardBkg.graphics.lineTo(left, bottom);
			}
			
			
			boardBkg.graphics.lineStyle(borderStroke, boardColor);
			
			for (x = left + (dashLength/2); x <  right-dashLength; x += dashLength*2)
			{
				boardBkg.graphics.moveTo(x, top);
				boardBkg.graphics.lineTo(x+dashLength, top);
				
				boardBkg.graphics.moveTo(x, bottom);
				boardBkg.graphics.lineTo(x+dashLength, bottom);
			}
			
			
			if (boardSize < unscaledWidth)
			{
				for (y = top + (dashLength/2); y < bottom-dashLength; y += dashLength*2){
					
					boardBkg.graphics.moveTo(left, y);
					boardBkg.graphics.lineTo(left, y+dashLength);
					
					boardBkg.graphics.moveTo(right, y);
					boardBkg.graphics.lineTo(right, y+dashLength);
				}
			}
			
			var fontSize:int = Math.round(squareSize/4.3);
			var textFormat:TextFormat= new TextFormat(null, fontSize, 0xFFFFFF, true);
			
			var colTf:FlexTextField 
			var rowTf:FlexTextField;
			
			for (var c:int = 0; c < 8; c++)
			{
				x= points[0][c].x;
				
				colTf = boardBkg.getChildAt(c) as FlexTextField;
				colTf.text = String.fromCharCode(97+c);
				colTf.setTextFormat(textFormat);
				colTf.x = x+ ((squareSize - colTf.textWidth)/2);
				colTf.y = boardSize+1;
			}
			
			for (var r:int = 0; r < 8; r++)
			{
				y= points[r][0].y;
				
				rowTf = boardBkg.getChildAt(8+r) as FlexTextField;	
				rowTf.text = (8-r).toString();
				rowTf.setTextFormat(textFormat);
				rowTf.x = (boardSize >= unscaledWidth) ? -1 : (-1 * colTf.textWidth) - 10;
				rowTf.y = y + ((squareSize - rowTf.textHeight)/2);
			}
			
			boardDrawn = true;
		}
		
		protected function drawCheckersPieces():void
		{
			
			checkersPiecesGroup.removeAllElements();
			for (var row:int = 0; row < 8; row++)
			{
				
				for (var col:int = 0; col < 8; col++)
				{
					if (gm.boardPieces[row][col])
					{						
						gm.boardPieces[row][col].image.x = points[row][col].x+squarePadding;
						gm.boardPieces[row][col].image.y = points[row][col].y+squarePadding;
						
						gm.boardPieces[row][col].imageSize = squareSize-(squarePadding*2);		
						gm.boardPieces[row][col].image.visible = true;
						
						checkersPiecesGroup.addElement(gm.boardPieces[row][col].image);
						
					}
				}
			}
			
			if (playerCapturedGroup){
				playerCapturedGroup.parseCapturedPieces(gm.playerCapturedPieces);
			}
			
			if(opponentCapturedGroup){
				opponentCapturedGroup.parseCapturedPieces(gm.opponentCapturedPieces);
			}
			
			
		}
		
		
		protected function grabPiece(event:MouseEvent):void
		{
			var row:int = Math.floor(event.localY/squareSize);
			var col:int = Math.floor(event.localX/squareSize);
			
			if (!player.isFirstPlayer){
				row = 7-row;
				col = 7-col;
			}
			
			if (!playEnabled)
			{
				if (gm.boardPieces[row][col] == null){
					return;
				}
				if (!gm.initialized || gm.boardPieces[row][col].isWhite != player.isFirstPlayer){
					gm.boardPieces[row][col].flashRed();
					SoundManager.playSound(SoundManager.ERROR);
					return;
				}
				
				grabbedPiece = gm.boardPieces[row][col];
			}
			else
			{
				if (row != currentMove.newPosition.row || col != currentMove.newPosition.col)
				{	
					if (gm.boardPieces[row][col]){
						gm.boardPieces[row][col].flashRed();
						SoundManager.playSound(SoundManager.ERROR);
					}
					
					return;
				}
				
				drawCheckersPieces();
				grabbedPiece = gm.boardPieces[currentMove.oldPosition.row][currentMove.oldPosition.col];
			}
			
			SoundManager.playSound(SoundManager.BLOOP);
			
			grabbedPiece.image.x = event.localX- (grabbedPiece.imageSize/2);
			grabbedPiece.image.y = event.localY - (grabbedPiece.imageSize/2);
			grabbedPiece.scaleUp();
			
			
			grabbedPiece.generateValidMoves();
			
			addEventListener(MouseEvent.MOUSE_MOVE, dragPiece, false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, dropPiece, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, dropPiece, false, 0, true);
			
			checkersPiecesGroup.removeElement(grabbedPiece.image);
			checkersPiecesGroup.addElement(grabbedPiece.image);
			
			oldX = event.localX;
			oldY = event.localY;
			
		}
		
		protected function dragPiece(event:MouseEvent):void
		{			
			var deltaX:Number = event.localX-oldX;
			var deltaY:Number = event.localY-oldY;
			
			if (Math.abs(deltaX) >= 5 || Math.abs(deltaY) >= 5)
			{
				grabbedPiece.image.x += deltaX;
				grabbedPiece.image.y += deltaY;
				
				oldX = event.localX;
				oldY = event.localY;
			}
			
		}
		
		protected function dropPiece(event:MouseEvent):void
		{			
			removeEventListener(MouseEvent.MOUSE_MOVE, dragPiece);
			removeEventListener(MouseEvent.MOUSE_UP, dropPiece);
			removeEventListener(MouseEvent.MOUSE_OUT, dropPiece);
			
			var row:int = Math.floor(event.localY/squareSize);
			var col:int = Math.floor(event.localX/squareSize);
			
			if (!player.isFirstPlayer){
				row = 7-row;
				col = 7-col;
			}
			
			grabbedPiece.scaleDown();
			currentMove = grabbedPiece.getMove(row, col);
			
			if (currentMove){
				
				SoundManager.playSound(SoundManager.DROP);
				
				if (grabbedPiece is Pawn && (currentMove.newPosition.row == 0 || currentMove.newPosition.row == 7))
				{
					promotionWindow = new PromotionWindow();
					promotionWindow.addEventListener(PromotionWindow.SELECT, promotePiece, false, 0, true);
					promotionWindow.pieceData = grabbedPiece.clonedData;
					
					AlertManager.displayCustomWindow(promotionWindow);
				}
				else{
					playEnabled = true;
				}
				
			}
			else
			{
				
				currentMove = new Move(grabbedPiece.position, grabbedPiece.position);
				
				if (grabbedPiece.position.row != row || grabbedPiece.position.col != col)
				{
					grabbedPiece.flashRed();
					SoundManager.playSound(SoundManager.ERROR);
				}
				else{
					SoundManager.playSound(SoundManager.DROP);
				}
				
				playEnabled = false;
				
			}
			
			movePiece(currentMove, currentMoveCompleteHandler, 80);
			
		}
		
		
		protected function movePiece(move:Move, completeHandler:Function, speed:Number=300):void
		{
			checkersPiecesGroup.mouseEnabled = false;
			
			var piece:CheckersPiece = gm.boardPieces[move.oldPosition.row][move.oldPosition.col];
			
			checkersPiecesGroup.removeElement(piece.image);
			checkersPiecesGroup.addElement(piece.image);
			
			var endPoint:Point = points[move.newPosition.row][move.newPosition.col];
			var delta:Number = Math.sqrt(Math.pow(Math.abs(endPoint.x-piece.image.x),2)+Math.pow(Math.abs(endPoint.y-piece.image.y),2));
			
			var moveEffect:Move = new Move();
			moveEffect.target = piece.image;
			moveEffect.duration = (delta/squareSize) * speed;
			moveEffect.xTo = endPoint.x+squarePadding;
			moveEffect.yTo = endPoint.y+squarePadding;
			moveEffect.addEventListener(EffectEvent.EFFECT_END, completeHandler, false, 0, true);
			
			moveEffect.play();
		}
		
		protected function lastMoveCompleteHandler(event:EffectEvent):void
		{
			if (currentGameState && lastMove)
			{
				if (lastMove.subsequentMove && !movedSubsequent){
					movePiece(lastMove.subsequentMove, lastMoveCompleteHandler);
					movedSubsequent = true;
				}
				else
				{		
					movedSubsequent = false;
					gm.createBoard(currentGameState.pieces);
					prepareForPlay();
				}
				
				SoundManager.playSound(SoundManager.DROP);
			}
		}
		
		protected function currentMoveCompleteHandler(event:EffectEvent):void
		{
			if (currentMove)
			{
				if (currentMove.subsequentMove && !movedSubsequent){
					movePiece(currentMove.subsequentMove, currentMoveCompleteHandler);
					movedSubsequent = true;
				}
				else
				{
					if (currentMove.capturedPiece){
						var capturedPieceImage:BitmapImage = gm.boardPieces[currentMove.capturedPiece.row][currentMove.capturedPiece.col].image;
						capturedPieceImage.visible = false;
					}
					
					if (movedSubsequent){
						movedSubsequent = false;
						SoundManager.playSound(SoundManager.DROP);
					}
					
					checkersPiecesGroup.mouseEnabled = true;
				}
			}
		}
		
		protected function promotePiece(event:Event):void
		{
			promotionWindow.removeEventListener(PromotionWindow.SELECT, promotePiece);
			
			var promotedPiece:CheckersPiece = promotionWindow.promotedPiece;
			promotedPiece.imageSize = grabbedPiece.imageSize;
			promotedPiece.image.x = grabbedPiece.image.x;
			promotedPiece.image.y = grabbedPiece.image.y;
			
			checkersPiecesGroup.removeElement(grabbedPiece.image);
			checkersPiecesGroup.addElement(promotedPiece.image);
			
			currentMove.transformation = new TransformationVO(grabbedPiece.type, promotionWindow.promotedType);
			
			promotionWindow = null;
			playEnabled = true;
		}
		
		
		
		
	}
}


