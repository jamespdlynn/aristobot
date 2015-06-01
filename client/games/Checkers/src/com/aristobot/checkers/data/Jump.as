package com.aristobot.checkers.data
{
	import com.aristobot.checkers.data.Position;
	import com.aristobot.data.ICustomGameObject;
	
	public class Jump implements ICustomGameObject
	{
		public var position:Position;
		public var capturedPieceId:int;
		
		public function Jump(position:Position=null, capturedPieceId:int = null)
		{
			this.position = position;
			this.capturedPieceId = capturedPieceId;
		}
		
		public function Jump(row:int, col:int, capturedPieceId:int = null)
		{
			this.position = new Position(row,col);
			this.capturedPieceId = capturedPieceId;
		}
		
		public function marshall(rootXML:XML):XML
		{
			rootXML.r = position.row;
			rootXML.c = position.col;
			
			if (capturedPieceId){
				rootXML.cp = capturedPieceId;
			}
			
			return rootXML;
		}
		
		public function unmarshall(rootXML:XML):void
		{
			this.position = new Position(rootXML.r, rootXML.c);
			this.capturedPieceId = parseInt(rootXML.cp);	
		}
		
	
}

