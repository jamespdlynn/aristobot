package com.aristobot.flexmobile.components
{	
	import com.aristobot.flexmobile.views.SignIn;
	import com.aristobot.flexmobile.views.UserProfile;
	
	import mx.controls.Spacer;
	import mx.events.FlexEvent;
	
	import spark.components.Label;
	import spark.components.ViewNavigatorApplication;
	import spark.primitives.BitmapImage;
	
	public class MobileApplication extends ViewNavigatorApplication
	{		
		protected var _appIcon:Class;
		public function get appIcon():Class{
			return _appIcon;
		}
		public function set appIcon(value:Class):void{
			_appIcon = value;
		}

		public function MobileApplication(){
			super();
			this.firstView = SignIn;
			this.addEventListener(FlexEvent.PREINITIALIZE, preInitializeHandler, false, 0, true);
		}	
		
		protected function preInitializeHandler(event:FlexEvent):void{
			
 			var spacer:Spacer = new Spacer();
			spacer.width = 16;
			
			var img:BitmapImage = new BitmapImage();
			img.smooth = true;
			img.width = 64;
			img.height = 64;
			img.source = _appIcon;
			this.navigationContent = [spacer, img];
			
			var label:Label = new Label();
			label.styleName = "viewTitle";
			label.text = title;
			this.titleContent = [label];
		}

	}
}