package
{
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class MaskSprite extends Sprite
	{
		[Embed(source="../assets/pixelmask.xml",mimeType="application/octet-stream")]
		private var AnimData:Class;
		[Embed(source="../assets/pixelmask.png")]
		private var AnimTexture:Class;		
		
		public function MaskSprite()
		{
			super();

			var heroTexture:Texture = Texture.fromBitmap(new AnimTexture());
			var heroXmlData:XML = XML(new AnimData());
			var heroTextureAtlas:TextureAtlas = 
				new TextureAtlas(heroTexture, heroXmlData);
			//Fetch the sprite sequence form the texture using their name
			var _mc:MovieClip = new MovieClip(heroTextureAtlas.getTextures("mask_text"), 18);		 
			addChild(_mc);
			Starling.juggler.add(_mc);
			
			
		}
	}
}