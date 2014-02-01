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
		private const CRACK_AVOIDANCE_ZONE:int = 400;

		public var crack:MovieClip;
		public var nasty:MovieClip
		public var playerContainer:MovieClip;
		private var _skin:MovieClip;
		private var _randomizeCrackPos:Boolean;

		public function Layer(skin:MovieClip, randomizeCrackPos:Boolean = true)
		{
			_skin = skin;
			crack = _skin.crack;
			nasty = _skin.nasty;
			playerContainer = _skin.playerContainer;
			_randomizeCrackPos = randomizeCrackPos;

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

		public function randomizeCrackPosition(avoidPos:Point):void
		{
			//do not randomize the crack on the last layer
			if(!_randomizeCrackPos)
			{
				return;
			}

			var avoidRect:Rectangle = new Rectangle(avoidPos.x - CRACK_AVOIDANCE_ZONE/2, avoidPos.y - CRACK_AVOIDANCE_ZONE/2, CRACK_AVOIDANCE_ZONE, CRACK_AVOIDANCE_ZONE);

			 //TEST CRACK RANDOMIZATION LOCATION
//			 var h:int = 700;
//			 while(h != 0)
//			 {
//				 var rect:Shape = Utils.createDebugSquare();
//
//
//				 rect.x = Utils.randomMinMax(CRACK_SIDE_DEAD_ZONE, STAGE_WIDTH - CRACK_SIDE_DEAD_ZONE);
//				 rect.y = Utils.randomMinMax(CRACK_SIDE_DEAD_ZONE, STAGE_HEIGHT - CRACK_SIDE_DEAD_ZONE);
//
//				 while(avoidRect.contains(rect.x, rect.y))
//				 {
//					 rect.x = Utils.randomMinMax(CRACK_SIDE_DEAD_ZONE, STAGE_WIDTH - CRACK_SIDE_DEAD_ZONE);
//					 rect.y = Utils.randomMinMax(CRACK_SIDE_DEAD_ZONE, STAGE_HEIGHT - CRACK_SIDE_DEAD_ZONE);
//				 }
//
//				 addChild(rect);
//
//				 h--;
//			 }


			while(avoidRect.contains(crack.x,crack.y))
			{
				findRandomPosition();
			}

		}

		private function findRandomPosition():void
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
