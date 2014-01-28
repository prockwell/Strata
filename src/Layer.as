/**
 * Created with IntelliJ IDEA.
 * User: peterrockwell
 * Date: 1/25/2014
 * Time: 5:10 PM
 */
package
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Layer extends MovieClip
	{
		private const STAGE_WIDTH:int = 1024;
		private const STAGE_HEIGHT:int = 576;
		private const CRACK_SIDE_DEAD_ZONE:int = 20;
		private const CRACK_CENTER_DEAD_ZONE:int = 400;

		public var crack:MovieClip;
		public var nasty:MovieClip
		public var playerContainer:MovieClip;
		private var _skin:MovieClip;

		public function Layer(skin:MovieClip, randomizeCrackPos:Boolean = true, crackAllowedInCenter:Boolean = true)
		{
			_skin = skin;
			crack = _skin.crack;
			nasty = _skin.nasty;
			playerContainer = _skin.playerContainer;

			if(!playerContainer)
			{
				trace("A LAYER DOES NOT CONTAIN A PLAYER CONTAINER");
			}

			if(crack)
			{
				if(randomizeCrackPos)
				{
					randomizeCrackPosition();

					if(crackAllowedInCenter)
					{
						var centerRect:Rectangle = new Rectangle(STAGE_WIDTH/2 - CRACK_CENTER_DEAD_ZONE/2, STAGE_HEIGHT/2 - CRACK_CENTER_DEAD_ZONE/2, CRACK_CENTER_DEAD_ZONE, CRACK_CENTER_DEAD_ZONE);

						/*
						//TEST CRACK RANDOMIZATION LOCATION

						var h:int = 700;
						while(h != 0)
						{
							var rect:Shape = Utils.createDebugSquare();


							rect.x = Utils.randomMinMax(CRACK_SIDE_DEAD_ZONE, STAGE_WIDTH - CRACK_SIDE_DEAD_ZONE);
							rect.y = Utils.randomMinMax(CRACK_SIDE_DEAD_ZONE, STAGE_HEIGHT - CRACK_SIDE_DEAD_ZONE);

							while(centerRect.contains(rect.x, rect.y))
							{
								rect.x = Utils.randomMinMax(CRACK_SIDE_DEAD_ZONE, STAGE_WIDTH - CRACK_SIDE_DEAD_ZONE);
								rect.y = Utils.randomMinMax(CRACK_SIDE_DEAD_ZONE, STAGE_HEIGHT - CRACK_SIDE_DEAD_ZONE);
							}

							addChild(rect);

							h--;
						}
						*/

						while(centerRect.contains(crack.x,crack.y))
						{
							randomizeCrackPosition();
						}
					}
				}
			}
			else
			{
				trace("A LAYER DOES NOT CONTAIN A CRACK");
			}

			this.addChild(skin);
			asleep();
		}

		public function randomizeCrackPosition():void
		{
			var crackPosition:Point = new Point;

			crackPosition.x = Utils.randomMinMax(CRACK_SIDE_DEAD_ZONE, STAGE_WIDTH - CRACK_SIDE_DEAD_ZONE);
			crackPosition.y = Utils.randomMinMax(CRACK_SIDE_DEAD_ZONE, STAGE_HEIGHT - CRACK_SIDE_DEAD_ZONE);
			crack.x = crackPosition.x;
			crack.y = crackPosition.y;
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
