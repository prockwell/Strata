package
{
	import flash.events.Event;

	public class Follower extends Creature
	{
		public function Follower(Skin:Class)
		{
			super(Skin, true);

			this.addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}

		private function init(e:Event)
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}

		private function onEnterFrame(e:Event):void
		{


			trace("!!!");
			var dx:int = this.x - stage.mouseX;
			var dy:int = this.y - stage.mouseY;
			this.x -= dx / 5;
			this.y -= dy /5;


			//this.x = mouseX;
			//this.y = mouseY;

			//x = e.movementX;
			//y = e.movementY;
		}
	}
}
