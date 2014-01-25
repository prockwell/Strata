package
{
	import flash.events.Event;

	public class Follower extends Creature
	{
		private var _followSpeed:Number;

		public function Follower(Skin:Class, centerSprite:Boolean, followSpeed:Number = 5)
		{
			_followSpeed = followSpeed;
			super(Skin, centerSprite);

			this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}

		private function init(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}

		private function onEnterFrame(e:Event):void
		{
			trace("!!!");
			var dx:int = this.x - stage.mouseX;
			var dy:int = this.y - stage.mouseY;
			this.x -= dx / _followSpeed;
			this.y -= dy / _followSpeed;


			//this.x = mouseX;
			//this.y = mouseY;

			//x = e.movementX;
			//y = e.movementY;
		}
	}
}
