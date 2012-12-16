package
{
	import flash.display.Bitmap;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.extensions.pixelmask.PixelMaskDisplayObject;
	import starling.text.TextField;
	
	public class ShimmerButtonScene extends DisplayObjectContainer
	{

		// NOTE ON THIS DEMO:
		// This is a button shimmer demo that illustrates putting a sheen on any button and animating it.
		// For extra credit, it also has a shimmer on dynamic text that sits on top of the button
		// One shimmer is masked to the button, the other is masked to the text. 
		
		// embed shimmer texture
		[Embed(source="../assets/shimmer.png")]
		private var ShimmerClass:Class;
		
		[Embed(source="../assets/bg.png")]
		private var BgTexture:Class;

		[Embed(source="../assets/shimmer_button.png")]
		private var ButtonTexture:Class;
		
		private var _shimmer:Image;
		private var _buttonShimmer:Image;
		private var _text:TextField;
		private var _buttonShimmerContainer:PixelMaskDisplayObject;
		
		private var _txt:String = "PIXELMASK";
		public function ShimmerButtonScene()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		private function handleAddedToStage(event:Event) : void
		{

			// background image
			var bitmap:Bitmap = new BgTexture();
			addChild(Image.fromBitmap(bitmap));
			
			// container
			var container:Sprite = new Sprite();

			
			// create mask sprite
			var mask:MaskSprite = new MaskSprite();
			mask.x = (stage.stageWidth-mask.width)/2;
			mask.y = (stage.stageHeight-mask.height)/2;
			
			
			var buttonBitmap:Bitmap = new ButtonTexture();
			var button:Image = Image.fromBitmap(buttonBitmap);
			container.addChild(button);
			
			// textfield
			_text = new TextField(button.width, button.height, "P", "Helvetica Bold", 64, 0x222222);
			
			// a little nudge to center the text vertically
			_text.y += 5;

			_buttonShimmerContainer = new PixelMaskDisplayObject();
			_buttonShimmerContainer.mask = button;
			
			_buttonShimmer = Image.fromBitmap(new ShimmerClass());
	
			_buttonShimmer.alpha = 0.4;
			_buttonShimmerContainer.addChild(_buttonShimmer);
			container.addChild(_text);
			container.addChild(_buttonShimmerContainer);
			// shimmer
			_shimmer = Image.fromBitmap(new ShimmerClass());
			
			// apply the masking here:
			var textMaskContainer:PixelMaskDisplayObject = new PixelMaskDisplayObject();
			textMaskContainer.mask = _text;
			textMaskContainer.addChild(_shimmer);
			
			container.addChild(textMaskContainer);
			container.x = (stage.stageWidth - button.width)/2;
			container.y = (stage.stageHeight - button.height)/2;
			addChild(container);
			addEventListener(TouchEvent.TOUCH, handleClick);

			setInterval(updateText, 500);
			fireShimmer();
		}
		
		private function updateText () : void
		{
			// this is just to illustrate that the text is dynamic
			_txt = _txt.substr(1) + _txt.substr(0,1);
			_text.text = _txt.substr(0,1);
		}
		
		private function fireShimmer() : void
		{
			_shimmer.visible = false;
			_buttonShimmerContainer.visible = false;
			setTimeout(performShimmer, 1000);
			
			function performShimmer() : void {
				_shimmer.visible = true;
				_buttonShimmerContainer.visible = true;
				
				_shimmer.x = _buttonShimmer.x = -200;
				var tween:Tween = new Tween(_shimmer, 2.5);
				tween.animate("x", _text.textBounds.width+200);
				tween.onComplete = fireShimmer;
				Starling.juggler.add(tween);
				
				var tweenButton:Tween = new Tween(_buttonShimmer, tween.totalTime);
				tweenButton.animate("x", _text.textBounds.width+200);
				Starling.juggler.add(tweenButton);
			}
		}
		
		private function handleClick (e:TouchEvent) : void
		{
			
		}
	}
}