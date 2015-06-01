package com.aristobot.chess.data
{
	public class TransformationVO
	{
		public var oldType:String;
		public var newType:String;
		
		public function TransformationVO(oldType:String = null, newType:String = null):void
		{
			this.oldType = oldType;
			this.newType = newType;
		}
		
		public function marshall(rootXML:XML):XML
		{
			rootXML.ot = oldType;
			rootXML.nt = newType
			return rootXML;
		}
		
		public function unmarshall(rootXML:XML):void
		{
			oldType = rootXML.ot;
			newType = rootXML.nt;
		}
	}
}