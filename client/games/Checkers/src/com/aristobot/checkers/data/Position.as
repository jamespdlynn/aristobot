package com.aristobot.checkers.data
{
	import com.aristobot.data.ICustomGameObject;

	public class Position implements ICustomGameObject
	{
		public function Position(row:int = -1, col:int = -1)
		{
			this.row = row;
			this.col = col;
		}
		
		public var row:int;
		public var col:int;
		
		public function equals(pos:Position):Boolean
		{
			return row == pos.row && col == pos.col;
		}
		
		public function isEven():Boolean{
			return (row+col)%2 == 0;
		}
		
		public function toString():String
		{
			return String.fromCharCode(97+col)+(8-row).toString();
		}
		
		public static function toString(row:int, col:int):String
		{
			return String.fromCharCode(97+col)+(8-row).toString();
		}

	}
}