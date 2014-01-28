/**
 * Created with IntelliJ IDEA.
 * User: peterrockwell
 * Date: 1/25/2014
 * Time: 5:10 PM
 */
package
{
	import flash.display.MovieClip;

	public class Layer extends MovieClip
	{
		public var crack:MovieClip;
		public var nasty:MovieClip
		public var playerContainer:MovieClip;
		private var _skin:MovieClip;

		public function Layer(skin:MovieClip)
		{
			_skin = skin;
			crack = _skin.crack;
			nasty = _skin.nasty;
			playerContainer = _skin.playerContainer;

			if(!playerContainer)
			{
				trace("A LAYER DOES NOT CONTAIN A PLAYER CONTAINER");
			}

			if(!crack)
			{
				trace("A LAYER DOES NOT CONTAIN A CRACK");
			}

			this.addChild(skin);
			asleep();
		}

		public function setActive():void
		{
			//hide crack
			crack.visible = false;
		}

		public function setMasked():void
		{
			//show skin
			_skin.visible = true;

			//show crack
			crack.visible = true;
		}

		public function setHidden():void
		{
			//hide skin
			_skin.visible = false;
		}


		public function awake():void
		{


		}

		public function asleep():void
		{


		}
	}
}
