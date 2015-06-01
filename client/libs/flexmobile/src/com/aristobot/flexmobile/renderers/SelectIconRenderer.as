package com.aristobot.flexmobile.renderers
{
	import com.aristobot.flexmobile.components.IconDisplayHolder;
	
	import mx.core.mx_internal;
	
	import spark.components.supportClasses.ItemRenderer;
	
	use namespace mx_internal; 
	
	[Style(name="selectedColor", inherit="inherit", type="uint")]
	public class SelectIconRenderer extends ItemRenderer
	{
		
		private var iconFieldChanged:Boolean;
		
		private var iconChanged:Boolean;
		
		private var holder:IconDisplayHolder;
		
		private var _iconField:String;
		
		private var _iconSize:Number;
		
		
		public function SelectIconRenderer()
		{
			super();
			this.autoDrawBackground = false;
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			
			iconChanged = true;
			
			invalidateProperties();
		}
		
		public function get iconField():String
		{
			return _iconField;
		}
		
		
		public function set iconField(value:String):void
		{
			if (value == _iconField){
				return;
			}
			
			_iconField = value;
			iconFieldChanged = true;
			iconChanged = true;
			
			invalidateProperties();
		}
		
		public function get iconSize():Number
		{
			return  _iconSize;
		}
		
		
		public function set iconSize(value:Number):void
		{
			_iconSize = value; 
			
			iconChanged = true;
			invalidateSize();
			invalidateDisplayList();
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (iconFieldChanged)
			{
				iconFieldChanged = false;
				
				if (iconField && !holder)
				{
					holder = new IconDisplayHolder();
					holder.top = 6;
					holder.left = 6;
					holder.bottom = 6;
					holder.right = 6;
					
					holder.selected = selected;
					
					addElement(holder);
				}
				else if (!iconField && IconDisplayHolder)
				{
					removeElement(holder);
					holder = null;
				}
				
				invalidateSize();
				invalidateDisplayList();
			}
			
			
			if (iconChanged)
			{
				iconChanged = false;
				
				if (iconField)
				{
					try
					{
						if (iconField in data){
							holder.source = data[iconField];
						}
					}
					catch(e:Error)
					{
						holder.source = null;
					}
				}
				
				if (_iconSize > 0){
					holder.width = _iconSize;
					holder.height = _iconSize;
				}
				
			}	
		}
		
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			
			if (holder){
				holder.selected = value;
			}
			
		}
			
		
	}
}