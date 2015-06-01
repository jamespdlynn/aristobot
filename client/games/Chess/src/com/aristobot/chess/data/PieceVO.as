package com.aristobot.chess.data
{
	public class PieceVO
	{
		public function PieceVO(id:int=-1, row:int=-1, col:int=-1, isWhite:Boolean=true, type:String=null, hasMoved:Boolean=false, captured:Boolean=false, enPassant:Boolean=false)
		{
			this.id = id;
			this.row = row;
			this.col = col;
			this.isWhite = isWhite;
			this.type = type;
			this.hasMoved = hasMoved;
			this.captured = captured;
			this.enPassant = enPassant;
		}
	
		public var id:int;
		public var row:int;
		public var col:int;
		public var isWhite:Boolean;
		public var type:String;		
		public var hasMoved:Boolean;
		public var captured:Boolean;
		public var enPassant:Boolean;
		
		[Transient]
		public function get position():PositionVO{
			return new PositionVO(row, col);
		}
		public function set position(value:PositionVO):void{
			row = value.row;
			col = value.col;
		}
		
		[Transient]
		public function get formattedType():String{
			var index:int = type.indexOf("::");	
			return (index >= 0) ? type.substring(type.indexOf("::")+2).toLowerCase() : type;
		}
		
		public function marshall(rootXML:XML):XML
		{
			rootXML.i = id;
			rootXML.r = row;
			rootXML.c = col;
			rootXML.t = type;
			
			if (isWhite) rootXML.w = 1;
			if (captured) rootXML.cp = 1;
			if (hasMoved) rootXML.mv = 1;
			if (enPassant) rootXML.ep = 1;

			return rootXML;
		}
		
		public function unmarshall(rootXML:XML):void
		{
			id = parseInt(rootXML.i);
			row = parseInt(rootXML.r);
			col = parseInt(rootXML.c);
			type = rootXML.t;
			
			isWhite = parseInt(rootXML.w) == 1;
			captured = parseInt(rootXML.cp) == 1;
			hasMoved = parseInt(rootXML.mv) == 1;
			enPassant = parseInt(rootXML.ep) == 1;			
		}
		
		public function clone():PieceVO
		{
			return new PieceVO(id, row, col, isWhite, type, hasMoved, captured, enPassant);
		}
	}
}