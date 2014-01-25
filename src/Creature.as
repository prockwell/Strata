/**
 * Created with IntelliJ IDEA.
 * User: peterrockwell
 * Date: 1/25/2014
 * Time: 12:01 AM
 */
package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;

	public class Creature extends Sprite
	{
		private var _skin:MovieClip;

		public function Creature(Skin:Class, centerSprite:Boolean)
		{
			_skin = new Skin();
			this.addChild(_skin);

			if(centerSprite)
			{
				_skin.x = this.x + _skin.width/2;
				_skin.y = this.y + _skin.height/2;
			}
		}
	}
}
