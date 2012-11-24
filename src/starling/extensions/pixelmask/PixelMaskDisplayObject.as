package starling.extensions.pixelmask
{
	import flash.display3D.Context3DBlendFactor;
	import flash.geom.Rectangle;
	
	import starling.core.RenderSupport;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.RenderTexture;
	
	public class PixelMaskDisplayObject extends DisplayObjectContainer
	{
		private var _mask:DisplayObject;
		private var _renderTexture:RenderTexture;
		private var _maskRenderTexture:RenderTexture;
		private var _source:DisplayObject;
		
		private var _image:Image;
		private var _maskImage:Image;
		
		private var _maskRect:Rectangle = new Rectangle();
		private var _superRenderFlag:Boolean = false;
		private var _inverted:Boolean = false;
		
		public function PixelMaskDisplayObject()
		{
			super();			
			BlendMode.register("mask", Context3DBlendFactor.ZERO, Context3DBlendFactor.SOURCE_ALPHA);
			BlendMode.register("inversemask", Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		}

		public function get inverted():Boolean
		{
			return _inverted;
		}

		public function set inverted(value:Boolean):void
		{
			_inverted = value;
			refreshRenderTextures(null);
		}

		public function set mask(mask:DisplayObject) : void
		{
			
			// clean up existing mask if there is one
			if (_mask) {
				_mask = null;
			}
			
			if (mask) {
				_mask = mask;				
				
				if (_mask.width==0 || _mask.height==0) {
					throw new Error ("Mask must have dimensions. Current dimensions are " + _mask.width + "x" + _mask.height + ".");
				}
				
				refreshRenderTextures(null);
			} else {
				clearRenderTextures();
			}
		}
		
		private function clearRenderTextures() : void
		{
			// clean up old render textures and images
			if (_maskRenderTexture) {
				_maskRenderTexture.dispose();
			}
			
			if (_renderTexture) {
				_renderTexture.dispose();
			}
			
			if (_image) {
				_image.dispose();
			}
			
			if (_maskImage) {
				_maskImage.dispose();
			}
		}
		
		private function refreshRenderTextures(e:Event=null) : void
		{
			if (_mask) {
				var newMaskRect:Rectangle = new Rectangle(0, 0, 0, 0);
				
				newMaskRect.width = getNearestNextPowerOfTwo(_mask.width);
				newMaskRect.height = getNearestNextPowerOfTwo(_mask.height);
				
				// if we have new dimensions to draw from, 
				if (_maskRect.width!=newMaskRect.width || _maskRect.height!=newMaskRect.height) {
					
					clearRenderTextures();
					
					_maskRenderTexture = new RenderTexture(newMaskRect.width, newMaskRect.height, false);
					_renderTexture = new RenderTexture(newMaskRect.width, newMaskRect.height, false);
					
					// create image with the new render texture
					_image = new Image(_renderTexture);
					
					// create image to blit the mask onto
					_maskImage = new Image(_maskRenderTexture);
					
					_maskRect = newMaskRect;
				}
				
				// set the blending mode to MASK (ZERO, SRC_ALPHA)
				if (_inverted) {
					_maskImage.blendMode = "inversemask";
				} else {
					_maskImage.blendMode = "mask";
				}
			}
		}
		
		public override function render(support:RenderSupport, parentAlpha:Number):void
		{
			if (_superRenderFlag || !_mask) {
				super.render(support, parentAlpha);
			} else {			
				if (_mask) {					 
					_superRenderFlag = true;
					// draw the mask
					_maskRenderTexture.draw(_mask);
					_renderTexture.drawBundled(drawRenderTextures);				
					_image.render(support, parentAlpha);
				}
			}
			_superRenderFlag = false;
		}
		
		private function drawRenderTextures() : void
		{
			_renderTexture.draw(this);
			_renderTexture.draw(_maskImage);
		}
		
		private function getNearestNextPowerOfTwo(value:int) : int
		{
			if (value==0) {
				throw new Error ("Trying to round up to the nearest power of 2 with 0 input");
			}
			
			value--;
			value |= value >> 1;  // handle  2 bit numbers
			value |= value >> 2;  // handle  4 bit numbers
			value |= value >> 4;  // handle  8 bit numbers
			value |= value >> 8;  // handle 16 bit numbers
			value |= value >> 16; // handle 32 bit numbers
			value++;

			return value;
		}
	}
}