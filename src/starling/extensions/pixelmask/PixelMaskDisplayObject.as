package starling.extensions.pixelmask
{
	import flash.display3D.Context3DBlendFactor;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.rendering.Painter;
	import starling.textures.RenderTexture;
	import starling.utils.Pool;

	public class PixelMaskDisplayObject extends DisplayObjectContainer
	{
		private static const MASK_MODE_NORMAL:String = "mask";
		private static const MASK_MODE_INVERTED:String = "maskInverted";

		private var _mask:DisplayObject;
		private var _renderTexture:RenderTexture;
		private var _maskRenderTexture:RenderTexture;

		private var _quad:Quad;
		private var _maskQuad:Quad;

		private var _superRenderFlag:Boolean = false;
		private var _scaleFactor:Number;
		private var _isAnimated:Boolean = true;
		private var _maskRendered:Boolean = false;

		private static var sIdentity:Matrix = new Matrix();

		public function PixelMaskDisplayObject(scaleFactor:Number=-1, isAnimated:Boolean=true)
		{
			super();

			BlendMode.register(MASK_MODE_NORMAL, Context3DBlendFactor.ZERO, Context3DBlendFactor.SOURCE_ALPHA);
			BlendMode.register(MASK_MODE_INVERTED, Context3DBlendFactor.ZERO, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

			_isAnimated = isAnimated;
			_scaleFactor = scaleFactor;

			_quad = new Quad(100, 100);
			_maskQuad = new Quad(100, 100);
			_maskQuad.blendMode = MASK_MODE_NORMAL;

			// Handle lost context. By using the conventional event, we can make a weak listener.
			// This avoids memory leaks when people forget to call "dispose" on the object.
			Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE,
				onContextCreated, false, 0, true);
		}

		override public function dispose():void
		{
			clearRenderTextures();

			_quad.dispose();
			_maskQuad.dispose();

			Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			super.dispose();
		}

		private function onContextCreated(event:Object):void
		{
			refreshRenderTextures();
		}

		public function get isAnimated():Boolean { return _isAnimated; }
		public function set isAnimated(value:Boolean):void { _isAnimated = value; }

		public function get inverted():Boolean { return _maskQuad.blendMode == MASK_MODE_INVERTED; }
		public function set inverted(value:Boolean):void
		{
			_maskQuad.blendMode = value ? MASK_MODE_INVERTED : MASK_MODE_NORMAL;
		}

		public function get pixelMask():DisplayObject { return _mask; }
		public function set pixelMask(value:DisplayObject):void
		{
			_mask = value;

			if (value)
			{
				if (_mask.width == 0 || _mask.height == 0)
					throw new Error ("Mask must have dimensions. Current dimensions are " +
						_mask.width + "x" + _mask.height + ".");

				refreshRenderTextures();
			}
			else
			{
				clearRenderTextures();
			}
		}

		private function clearRenderTextures():void
		{
			if (_maskRenderTexture)	_maskRenderTexture.dispose();
			if (_renderTexture) 	_renderTexture.dispose();
		}

		private function refreshRenderTextures():void
		{
			if (_mask)
			{
				clearRenderTextures();

				var maskBounds:Rectangle = _mask.getBounds(_mask, Pool.getRectangle());
				var maskWidth:Number  = maskBounds.width;
				var maskHeight:Number = maskBounds.height;
				Pool.putRectangle(maskBounds);

				_renderTexture = new RenderTexture(maskWidth, maskHeight, false, _scaleFactor);
				_maskRenderTexture = new RenderTexture(maskWidth, maskHeight, false, _scaleFactor);

				// quad using the new render texture
				_quad.texture = _renderTexture;
				_quad.readjustSize();

				// quad to blit the mask onto
				_maskQuad.texture = _maskRenderTexture;
				_maskQuad.readjustSize();
			}

			_maskRendered = false;
		}

		public override function render(painter:Painter):void
		{
			if (_isAnimated || (!_isAnimated && !_maskRendered))
			{
				painter.finishMeshBatch();
				painter.excludeFromCache(this);

				if (_superRenderFlag || !_mask)
				{
					super.render(painter);
				}
				else
				{
					if (_mask)
					{
						_maskRenderTexture.draw(_mask, sIdentity);
						_renderTexture.drawBundled(drawRenderTextures);

						painter.pushState();
						painter.state.transformModelviewMatrix(_mask.transformationMatrix);

						_quad.render(painter);
						_maskRendered = true;

						painter.popState();
					}
				}
			}
			else
			{
				_quad.render(painter);
			}
		}

		private function drawRenderTextures():void
		{
			var matrix:Matrix = Pool.getMatrix();
			matrix.copyFrom(_mask.transformationMatrix);
			matrix.invert();

			_superRenderFlag = true;
			_renderTexture.draw(this, matrix);
			_superRenderFlag = false;
			_renderTexture.draw(_maskQuad, sIdentity);

			Pool.putMatrix(matrix);
		}
	}
}