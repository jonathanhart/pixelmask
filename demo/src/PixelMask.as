package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import starling.core.Starling;
	
	[SWF(frameRate=60,width=800,height=300)]
	public class PixelMask extends Sprite
	{
		private var _starling:Starling;

		public function PixelMask()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			_starling = new Starling(PixelMaskScene, stage);
			_starling.start();
			//_starling.showStats = true;
			_starling.stage.color = 0x222222;
		}
	}
}