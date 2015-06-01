package com.aristobot.flexmobile.skins
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	
	import spark.components.Group;
	import spark.components.ResizeMode;
	import spark.primitives.BitmapImage;
	import spark.skins.mobile.ViewMenuItemSkin;
	
	public class ViewMenuItemSkin extends spark.skins.mobile.ViewMenuItemSkin
	{
		
		private var iconChanged:Boolean = false;
		private var iconInstance:Object;    // Can be either DisplayObject or BitmapImage
		private var iconHolder:Group;       // Needed when iconInstance is a BitmapImage
		private var _icon:Object;           // The currently set icon, can be Class, DisplayObject, URL
		
		public function ViewMenuItemSkin()
		{
			super();
		}
		
		override protected function getIconDisplay():DisplayObject
		{
			return iconHolder ? iconHolder : iconInstance as DisplayObject;
		}
		

		override protected function setIcon(icon:Object):void
		{
			if (_icon == icon)
				return;
			_icon = icon;
			
			if (iconInstance)
			{
				if (iconHolder)
					iconHolder.removeAllElements();
				else
					this.removeChild(iconInstance as DisplayObject);
			}
			iconInstance = null;
			
			var needsHolder:Boolean = icon && !(icon is DisplayObject);
			if (needsHolder && !iconHolder)
			{
				iconHolder = new Group();
				iconHolder.resizeMode = ResizeMode.SCALE;
				addChild(iconHolder);
			}
			else if (!needsHolder && iconHolder)
			{
				this.removeChild(iconHolder);
				iconHolder = null;
			}
			
			if (icon)
			{
				if (needsHolder)
				{
					iconInstance = new BitmapImage();
					iconInstance.smooth = true;
					iconInstance.explicitWidth = 48;
					iconInstance.explicitHeight = 48;
					iconInstance.source = icon;
					iconHolder.addElementAt(iconInstance as BitmapImage, 0);
				}
				else
				{
					iconInstance = icon;
					addChild(iconInstance as DisplayObject);
				}
			}
			
			invalidateSize();
			invalidateDisplayList();
		}
	}
}