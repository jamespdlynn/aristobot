package com.aristobot.chess.data
{
	public class PositionVO
	{
		public function PositionVO(row:int = -1, col:int = -1)
		{
			this.row = row;
			this.col = col;
		}
		
		public var row:int;
		public var col:int;
		
		[Transient]
		public function equals(pos:PositionVO):Boolean
		{
			return row == pos.row && col == pos.col;
		}
		
		[Transient]
		public function isEven():Boolean{
			return (row+col)%2 == 0;
		}
		
		[Transient]
		public function toString():String
		{
			return String.fromCharCode(97+col)+(8-row).toString();
		}
		
		[Transient] 
		public static function toString(row:int, col:int):String{
			return String.fromCharCode(97+col)+(8-row).toString();
		}

	}
}