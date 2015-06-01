
package com.aristobot.flexmobile.components
{
	import com.aristobot.data.UserIcon;
	
	import flash.display.DisplayObject;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import mx.controls.listClasses.*;
	import mx.core.FlexTextField;
	import mx.core.IFlexDisplayObject;
	import mx.core.ILayoutElement;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.graphics.BitmapFillMode;
	import mx.graphics.BitmapScaleMode;
	
	import spark.core.ContentCache;
	import spark.core.DisplayObjectSharingMode;
	import spark.core.IContentLoader;
	import spark.core.IGraphicElement;
	import spark.core.IGraphicElementContainer;
	import spark.core.ISharedDisplayObject;
	import spark.primitives.BitmapImage;
	
	use namespace mx_internal;

	[Style(name="iconDelay", type="Number", format="Time", inherit="no")]

	[Style(name="rankStyleName", type="String", inherit="no")]

	public class IconRank extends UIComponent 
		implements IGraphicElementContainer, ISharedDisplayObject
	{

		mx_internal static var _imageCache:ContentCache;
		
		public function IconRank()
		{
			super();
		}
		private var iconNeedsValidateProperties:Boolean = false;
		private var iconNeedsValidateSize:Boolean = false;
		private var iconNeedsDisplayObjectAssignment:Boolean = false;
		private var iconSetterDelayTimer:Timer;
		private var iconSourceToLoad:Object;
		
		private var badgeNeedsValidateProperties:Boolean = false;
		private var badgeNeedsValidateSize:Boolean = false;
		private var badgeNeedsDisplayObjectAssignment:Boolean = false;
		
		mx_internal var oldUnscaledWidth:Number;
		
		private var _userIcon:UserIcon;
		public function get userIcon():UserIcon{
			return _userIcon;
		}
		public function set userIcon(value:UserIcon):void{
			_userIcon = value;
			iconChanged = true;
			
			invalidateProperties();
		}
		

		private var _iconContentLoader:IContentLoader = _imageCache;
		
		public function get iconContentLoader():IContentLoader
		{
			return _iconContentLoader;
		}
		
		public function set iconContentLoader(value:IContentLoader):void
		{
			if (value == _iconContentLoader)
				return;
			
			_iconContentLoader = value;
			
			if (iconDisplay)
				iconDisplay.contentLoader = _iconContentLoader;
			
			if (badgeDisplay)
				badgeDisplay.contentLoader = _iconContentLoader;
		}
		
		protected var rankDisplay:FlexTextField;	
		
		private var iconChanged:Boolean;
		
		mx_internal var iconDisplayClass:Class = BitmapImage;
		
		protected var badgeDisplay:BitmapImage;

		protected var iconDisplay:BitmapImage;
		
		private var _iconFillMode:String = BitmapFillMode.SCALE;
		
		[Inspectable(category="General", enumeration="clip,repeat,scale", defaultValue="scale")]
		public function get iconFillMode():String
		{
			return _iconFillMode;
		}

		public function set iconFillMode(value:String):void
		{
			if (value == _iconFillMode)
				return;
			
			_iconFillMode = value;
			
			if (iconDisplay)
				iconDisplay.fillMode = _iconFillMode;
			
			if (badgeDisplay)
				badgeDisplay.fillMode = _iconFillMode;
		}
		
		private var _iconHeight:Number = 72;
		
		public function get iconHeight():Number
		{
			return _iconHeight;
		}
		
		public function set iconHeight(value:Number):void
		{
			if (value == _iconHeight)
				return;
			
			_iconHeight = value;
			
			if (iconDisplay)
				iconDisplay.explicitHeight = _iconHeight;
			
			if (badgeDisplay)
				badgeDisplay.explicitHeight = _iconHeight;
			
			invalidateSize();
			invalidateDisplayList();
		}

		private var _iconScaleMode:String = BitmapScaleMode.STRETCH;
		
		[Inspectable(category="General", enumeration="stretch,letterbox", defaultValue="stretch")]
		
		public function get iconScaleMode():String
		{
			return _iconScaleMode;
		}

		public function set iconScaleMode(value:String):void
		{
			if (value == _iconScaleMode)
				return;
			
			_iconScaleMode = value;
			
			if (iconDisplay)
				iconDisplay.scaleMode = _iconScaleMode;
			
			if (badgeDisplay)
				badgeDisplay.scaleMode = _iconScaleMode;
		}
		
		private var _iconWidth:Number = 72;

		public function get iconWidth():Number
		{
			return _iconWidth;
		}

		public function set iconWidth(value:Number):void
		{
			if (value == _iconWidth)
				return;
			
			_iconWidth = value;
			
			if (iconDisplay)
				iconDisplay.explicitWidth = _iconWidth;
			
			if (badgeDisplay)
				badgeDisplay.explicitWidth = _iconWidth;
			
			invalidateSize();
			invalidateDisplayList();
		}

	
		private var _redrawRequested:Boolean = false;

		public function get redrawRequested():Boolean
		{
			return _redrawRequested;
		}
		
		public function set redrawRequested(value:Boolean):void
		{
			_redrawRequested = value;
		}
		
		public function invalidateGraphicElementSharing(element:IGraphicElement):void
		{
			if (element == iconDisplay)
				iconNeedsDisplayObjectAssignment = true;
			
			if (element == badgeDisplay)
				badgeNeedsDisplayObjectAssignment = true;
			
			invalidateProperties();
		}
		
		public function invalidateGraphicElementProperties(element:IGraphicElement):void
		{
			if (element == iconDisplay)
				iconNeedsValidateProperties = true;
			
			if (element == badgeDisplay)
				badgeNeedsValidateProperties = true;
			
			invalidateProperties();
		}
		
		public function invalidateGraphicElementSize(element:IGraphicElement):void
		{
			if (element == iconDisplay)
				iconNeedsValidateSize = true;
			
			if (element == badgeDisplay)
				badgeNeedsValidateSize = true;
			
			invalidateSize();
		}
		
		public function invalidateGraphicElementDisplayList(element:IGraphicElement):void
		{
			if (element.displayObject is ISharedDisplayObject)
				ISharedDisplayObject(element.displayObject).redrawRequested = true;
			
			invalidateDisplayList();
		}
			
		
		/**
		 *  @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
		
			if (iconChanged)
			{
				iconChanged = false;
				
				// let's see if we need to create or remove it
				if (!iconDisplay && userIcon){
					createIconDisplay();
				}
				else if (!userIcon && iconDisplay)
				{
					destroyIconDisplay();
				}
				
				if (!badgeDisplay && userIcon && userIcon.rank > 0){
					createBadgeDisplay();
				}
				else  if(badgeDisplay && (!userIcon || userIcon.rank <= 0)){
					destroyBadgeDisplay();
				}
				
				if (iconDisplay){
					iconDisplay.source = userIcon.iconURL;
				}

				if (badgeDisplay){
					badgeDisplay.source = userIcon.badgeURL;
					rankDisplay.text = userIcon.rank.toString();
				}
				
				invalidateSize();
				invalidateDisplayList();;
			}
			
			if (iconNeedsDisplayObjectAssignment)
			{
				iconNeedsDisplayObjectAssignment = false;
				assignDisplayObject(iconDisplay);
			}
			
			if (badgeNeedsDisplayObjectAssignment)
			{
				badgeNeedsDisplayObjectAssignment = false;
				assignDisplayObject(badgeDisplay);
				
				addChild(rankDisplay);
			}
			
			cacheAsBitmap = true;		
		}
		
		
		/**
		 *  @private
		 */
		override public function validateProperties():void
		{
			super.validateProperties();
			
			// Since IGraphicElement is not ILayoutManagerClient, we need to make sure we
			// validate properties of the elements
			if (iconNeedsValidateProperties)
			{
				iconNeedsValidateProperties = false;
				if (iconDisplay)
					iconDisplay.validateProperties();
			}
			
			if (badgeNeedsValidateProperties)
			{
				badgeNeedsValidateProperties = false;
				if (badgeDisplay)
					badgeDisplay.validateProperties();
			}
		}
		
		/**
		 *  @private
		 */
		private function assignDisplayObject(bitmapImage:BitmapImage):void
		{
			if (bitmapImage)
			{
				// if we can't use this as the display object, then let's see if 
				// the icon already has and owns a display object
				var ownsDisplayObject:Boolean = (bitmapImage.displayObjectSharingMode != DisplayObjectSharingMode.USES_SHARED_OBJECT);
				
				// If the element doesn't have a DisplayObject or it doesn't own
				// the DisplayObject it currently has, then create a new one
				var displayObject:DisplayObject = bitmapImage.displayObject;
				if (!ownsDisplayObject || !displayObject)
					displayObject = bitmapImage.createDisplayObject();
				
				// Add the display object as a child
				// Check displayObject for null, some graphic elements
				// may choose not to create a DisplayObject during this pass.
				if (displayObject)
					addChild(displayObject);
				
				bitmapImage.displayObjectSharingMode = DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT;
			}
		}
			
		

		protected function createIconDisplay():void
		{
			iconDisplay = new iconDisplayClass();
			
			iconDisplay.contentLoader = iconContentLoader;
			iconDisplay.fillMode = iconFillMode;
			iconDisplay.scaleMode = iconScaleMode;
			
			if (!isNaN(iconWidth))
				iconDisplay.explicitWidth = iconWidth;
			if (!isNaN(iconHeight))
				iconDisplay.explicitHeight = iconHeight;
			
			iconDisplay.parentChanged(this);
			
			iconNeedsDisplayObjectAssignment = true;
		}
		
		protected function destroyIconDisplay():void
		{
			// need to remove the display object
			var oldDisplayObject:DisplayObject = iconDisplay.displayObject;
			if (oldDisplayObject)
			{ 
				// If the element created the display object
				if (iconDisplay.displayObjectSharingMode != DisplayObjectSharingMode.USES_SHARED_OBJECT &&
					oldDisplayObject.parent == this)
				{
					removeChild(oldDisplayObject);
				}
			}
			
			iconDisplay.parentChanged(null);
			iconDisplay = null;
		}
		
		
		protected function createBadgeDisplay():void
		{
			badgeDisplay = new iconDisplayClass();
			
			badgeDisplay.contentLoader = iconContentLoader;
			badgeDisplay.fillMode = iconFillMode;
			badgeDisplay.scaleMode = iconScaleMode;
			
			badgeDisplay.parentChanged(this);
			
			rankDisplay = new FlexTextField();
			rankDisplay.selectable = false;
			rankDisplay.multiline = false;
			rankDisplay.wordWrap = false;
			
			badgeNeedsDisplayObjectAssignment = true;

		}
		
		protected function destroyBadgeDisplay():void
		{
			// need to remove the display object
			var oldDisplayObject:DisplayObject = badgeDisplay.displayObject;
			if (oldDisplayObject)
			{ 
				// If the element created the display object
				if (badgeDisplay.displayObjectSharingMode != DisplayObjectSharingMode.USES_SHARED_OBJECT &&
					oldDisplayObject.parent == this)
				{
					removeChild(oldDisplayObject);
				}
			}
			
			badgeDisplay.parentChanged(null);
			badgeDisplay = null;
			
			removeChild(rankDisplay);
			badgeDisplay = null;
		}
		
		/**
		 *  @private
		 */
		override public function validateSize(recursive:Boolean = false):void
		{
			// Since IGraphicElement is not ILayoutManagerClient, we need to make sure we
			// validate sizes of the elements, even in cases where recursive==false.
			
			// Validate element size
			if (iconNeedsValidateSize)
			{
				iconNeedsValidateSize = false;
				if (iconDisplay)
					iconDisplay.validateSize();
			}
			
			if (badgeNeedsValidateSize)
			{
				badgeNeedsValidateSize = false;
				if (badgeDisplay)
					badgeDisplay.validateSize();
			}
			
			
			super.validateSize(recursive);
		}
		
		/**
		 *  @private
		 *  If we invalidate display list, we need to redraw any graphic elements sharing 
		 *  our display object since we call graphics.clear() in super.updateDisplayList()
		 */
		override public function invalidateDisplayList():void
		{
			redrawRequested = true;
			super.invalidateDisplayList();
		}

		override public function validateDisplayList():void
		{
			super.validateDisplayList();

			if (iconDisplay && 
				iconDisplay.displayObject is ISharedDisplayObject && 
				ISharedDisplayObject(iconDisplay.displayObject).redrawRequested)
			{
				ISharedDisplayObject(iconDisplay.displayObject).redrawRequested = false;
				iconDisplay.validateDisplayList();
				
				if (badgeDisplay && 
					badgeDisplay.displayObject is ISharedDisplayObject){
					badgeDisplay.validateDisplayList();
				}
			}
			
			if (badgeDisplay && 
				badgeDisplay.displayObject is ISharedDisplayObject && 
				ISharedDisplayObject(badgeDisplay.displayObject).redrawRequested)
			{
				ISharedDisplayObject(badgeDisplay.displayObject).redrawRequested = false;
				badgeDisplay.validateDisplayList();
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void
		{
			// clear the graphics before calling super.updateDisplayList()
			graphics.clear();
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
						
			layoutContents(unscaledWidth, unscaledHeight);
		}
		
		protected function layoutContents(unscaledWidth:Number,unscaledHeight:Number):void
		{
			if (iconDisplay)
			{
				 setElementSize(iconDisplay, iconWidth, iconHeight);
				 iconDisplay.x = 0;
				 iconDisplay.y = 0;
				 iconDisplay.smooth =true;
			}
			
			if (badgeDisplay)
			{
				var badgeWidth:Number = badgeDisplay.getPreferredBoundsWidth();
				var badgeHeight:Number = badgeDisplay.getPreferredBoundsHeight();
				
				setElementSize(badgeDisplay, badgeWidth, badgeHeight);
				badgeDisplay.x = -4;
				badgeDisplay.y = iconHeight - badgeHeight+8;
				badgeDisplay.smooth = true;
				
				if (rankDisplay)
				{							
					var size:Number = Math.ceil(badgeWidth/2);
					size += (rankDisplay.text && rankDisplay.text.length > 1) ? 1 : 2;
					
					var tf:TextFormat = new TextFormat();
					tf.size = size;
					tf.bold = true;
					tf.color = 0xFFFFFF;
					
					rankDisplay.setTextFormat(tf);
					rankDisplay.filters = [new DropShadowFilter(1, -45, 0x000000, 1, 4, 4, 2)];
					
					rankDisplay.x = Math.round(badgeDisplay.x + (badgeWidth/2) - (rankDisplay.textWidth/2)-2);
					rankDisplay.y = Math.round(badgeDisplay.y + (badgeHeight/2) - (rankDisplay.textHeight/2)-1);
					
				}
			}
			
			
		}
	
	
		protected function setElementSize(element:Object, width:Number, height:Number):void
		{
			if (element is ILayoutElement)
			{
				ILayoutElement(element).setLayoutBoundsSize(width, height, false);
			}
			else if (element is IFlexDisplayObject)
			{
				IFlexDisplayObject(element).setActualSize(width, height);
			}
			else
			{
				element.width = width;
				element.height = height;
			}
		}
		
		override public function get width():Number
		{
			return iconWidth;
		}
		
		override public function get height():Number
		{
			return iconHeight;
		}
		
		override public function set width(value:Number):void{
			iconWidth = value;
		}
		
		override public function set height(value:Number):void{
			iconHeight = value;
		}
		
	
	}

	
}