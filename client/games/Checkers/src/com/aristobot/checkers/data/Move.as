package com.aristobot.checkers.data
{
	import com.aristobot.data.ICustomGameObject;
	
	public class Move implements ICustomGameObject
	{
		public var pieceId:int;
		public var oldPosition:Position;
		public var jumps:Vector.<Jump>;
		public var transformed:Boolean;
		
		[Transient]
		public var isValid:Boolean;
		
		public function Move(pieceId:int, oldPosition:Position)
		{
			this.pieceId = pieceId;
			this.oldPosition = oldPosition;
			this.jumps = new Vector.<Jump>;
			this.transformed = false;
		}	
		
		public function hasCapturedPieceId(pieceId:int):Boolean{
			
			var capturedPieceIds = new Vector.<int>;
			for each(var jump:Jump in jumps){
				if (jump.capturedPieceId == pieceId){
					return true;
				}
			}
			return false;
		}
		
		public function getNewPosition():Position{
			if (jumps.length==0) return null;
			
			return jumps[jumps.length-1].position;
		}

		public function marshall():XML
		{
			var rootXML:XML = <com.aristobot.checkers.Moves/>;
			rootXML.id = pieceId;
			rootXML.op.r = oldPosition.row;
			rootXML.op.c = oldPosition.col;
			
			rootXML.js = <js/>;
			for each(var jump:Jump in jumps){
				rootXML.js.appendChild(jump.marshall(<j/>));
			}
			
			if (transformed){
				rootXML.t = 1;
			}

			return rootXML;
		}
		
		public function unmarshall(rootXML:XML):void
		{
			pieceId = rootXML.id;
			oldPosition = new Position(rootXML.op.r, rootXML.op.c);
			
			for each (var jumpXML:XML in rootXML.js.*)
			{
				var jump:Jump = new Jump();
				jump.unmarshall(jumpXML);
				jumps.push(jump);
			}
			
			transformed = (parseInt(rootXML.t) == 1);
		}
	}
}