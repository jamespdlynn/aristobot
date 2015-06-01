package com.aristobot.admin.components
{
	import com.aristobot.admin.components.BusyIndicator;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	
	import spark.components.Group;
	import spark.core.ContentCache;
	import spark.core.ContentRequest;
	import spark.primitives.BitmapImage;

	public class IconDisplayHolder extends Group
	{
		private var iconDisplay:BitmapImage;
		private var iconLoadSpinner:BusyIndicator;
		private var filter:GlowFilter = new GlowFilter(0xC5B358, 0.7, 48, 48, 2, 2);
		
		
		private var _source:Object;
		private var _isLoading:Boolean;
		private var _selected:Boolean;
		
		private static const MAX_FAILED_LOADS:int = 5;
		
		[Embed(source="/assets/images/file_broken.png")]
		private static var invalidIcon:Class;
		
		public static var iconCache:ContentCache;
		
		{
			iconCache = new ContentCache();
			iconCache.enableCaching = true;
			iconCache.enableQueueing = true;
			iconCache.maxCacheEntries = 200;
		}
		
		
		public function IconDisplayHolder():void
		{
			iconLoadSpinner = new BusyIndicator();

			iconDisplay = new BitmapImage();
			iconDisplay.percentWidth = 100;
			iconDisplay.percentHeight = 100;
			addElement(iconDisplay);
			
			iconDisplay.contentLoader = iconCache;
			iconDisplay.smooth = true;
			
			cacheAsBitmap=true;
				
		}
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			iconLoadSpinner.x = 8;
			iconLoadSpinner.y = 8;
			iconLoadSpinner.width = unscaledWidth-16;
			iconLoadSpinner.height = unscaledHeight-16;
			
			iconDisplay.filters = (_selected) ? [filter] : null;
			
			super.updateDisplayList(unscaledWidth,unscaledHeight);
		}
		
		
		
		public function set isLoading(value:Boolean):void
		{
			_isLoading = value;
			
			if (!iconDisplay) return;
			
			if (_isLoading && !contains(iconLoadSpinner)){
				addElement(iconLoadSpinner);
			}
			else if (!_isLoading && contains(iconLoadSpinner)){
				removeElement(iconLoadSpinner);
			}
			
			iconDisplay.visible = !_isLoading;
		}
		public function set source(value:Object):void
		{	
			_source = value;		
			
			var contentRequest:ContentRequest = (_source && (_source is String || _source is URLRequest)) ? iconCache.load(_source) : null;
			
			if (contentRequest && !contentRequest.complete  && !_isLoading)
			{
				isLoading = true;
				contentRequest.content.addEventListener(Event.COMPLETE, iconLoaded, false, 0, true);
				contentRequest.content.addEventListener(IOErrorEvent.IO_ERROR, iconError, false, 0, true);
			}
			else
			{
				isLoading = false;
				iconDisplay.source = _source;
			}
				
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		public function set selected(value:Boolean):void
		{
			_selected = value;
			invalidateDisplayList();
		}
		

		protected function iconLoaded(event:Event):void
		{
			isLoading = false;
			event.currentTarget.removeEventListener(Event.COMPLETE, iconLoaded);
			event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, iconError);
			
			iconDisplay.source = _source;
		}
		
		
		
		protected function iconError(event:IOErrorEvent):void
		{
			isLoading = false;
			event.currentTarget.removeEventListener(Event.COMPLETE, iconLoaded);
			event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, iconError);
			
			iconDisplay.source = new invalidIcon();
		}
	}
}