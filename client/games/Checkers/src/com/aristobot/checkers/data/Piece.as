package com.aristobot.checkers.data
{
	import com.aristobot.data.ICustomGameObject;

	public class Piece implements ICustomGameObject
	{
		public var id:int;
		public var position:Position;
		public var isRed:Boolean;
		public var isKing:Boolean;
		public var isCaptured:Boolean;
		
		[Transient]
		public function get row():int{
			return position.row;
		}
		
		[Transient]
		public function get col():int{
			return position.col;
		}
		
		public function Piece(id:int=null, position:Position=null, isRed:Boolean, isKing:Boolean=false, isCaptured:Boolean=false) 
		{
			this.id = id;
			this.position = position;
			this.isRed = isRed;
			this.isKing = isKing;
		}
		
		public function Piece(id:int=null, row:int=null, col:int=null, isRed:Boolean, isKing:Boolean=false, isCaptured:Boolean=false)
		{
			this.id = id;
			this.positon = new Position(row, col);
			this.isRed = isRed;
			this.isKing = isKing;
		}		
		
		public function marshall(rootXML:XML):XML
		{
			rootXML.i = id;
			rootXML.r = position.row;
			rootXML.c = position.col;
			
			if (isRed) rootXML.r = 1;
			if (isKing) rootXML.k = 1;
			if (isCaptured) rootXML.cp = 1;

			return rootXML;
		}
		
		public function unmarshall(rootXML:XML):void
		{
			id = parseInt(rootXML.i);
			position = parseInt(rootXML.r);
			col = parseInt(rootXML.c);
			
			isRed = parseInt(rootXML.r) == 1;
			isKing = parseInt(rootXML.k) == 1;
			isCaptured = parseInt(rootXML.cp) == 1;		
		}
		
		public function clone():Piece
		{
			return new Piece(id, row, col, isRed, isKing, isCaptured);
		}
	}
}