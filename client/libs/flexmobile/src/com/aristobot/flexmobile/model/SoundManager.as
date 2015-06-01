package com.aristobot.flexmobile.model
{
	import flash.media.SoundTransform;
	
	import mx.core.SoundAsset;

	public class SoundManager
	{
		
		[Embed(source="/assets/sounds/click.mp3")]
		public static const CLICK:Class;
		
		[Embed(source="/assets/sounds/snap.mp3")]
		public static const SNAP:Class;
		
		[Embed(source="/assets/sounds/drop.mp3")]
		public static const DROP:Class;
				
		[Embed(source="/assets/sounds/error.mp3")]
		public static const ERROR:Class;
		
		[Embed(source="/assets/sounds/bloop.mp3")]
		public static const BLOOP:Class;
		
		[Embed(source="/assets/sounds/alert.mp3")]
		public static const ALERT:Class;
		
		[Embed(source="/assets/sounds/victory.mp3")]
		public static const VICTORY:Class;
		
		[Embed(source="/assets/sounds/defeat.mp3")]
		public static const DEFEAT:Class;
		
		[Embed(source="/assets/sounds/draw.mp3")]
		public static const DRAW:Class;
				
		public static var vm:ViewModel = ViewModel.getInstance();
		
		protected static var soundTransform:SoundTransform = new SoundTransform();

		public static function playSound(sound:Class, loops:int=0):void
		{
			
			if (vm.soundEnabled){
				var soundAsset:SoundAsset = new sound() as SoundAsset;
				soundAsset.play(0, loops, soundTransform);
			}
		}
		
		public static function getVolume():Number
		{
			return soundTransform.volume;
		}
		
		public static function setVolume(value:Number):void
		{
			soundTransform.volume = value;
		}
		
	}
}