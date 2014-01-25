package
{
	import Main.BlueSquare;
	import Main.SpikeLayer;
	import Main.YellowTriangle;

	import com.sociodox.theminer.TheMiner;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.ui.Mouse;

	[SWF(backgroundColor="#333333", frameRate="30", width="1024", height="576")]
	public class Strata extends Sprite
	{
		public static var SPIKE_LAYER:Sprite;
		public static var RING_LAYER:Sprite;
		public static var BLOCK_LAYER:Sprite;

	    public function Strata()
	    {
		    addEventListener(Event.ADDED_TO_STAGE, init);
	    }

		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addChild(new TheMiner());

			//Create layers
			SPIKE_LAYER = new SpikeLayer();
			addChild(SPIKE_LAYER);

			//create player
			createPlayer();
		}

		private function createPlayer():void
		{
			var yellowTriangle:Follower = new Follower(YellowTriangle, true, 10);
			addChild(yellowTriangle);

			var blueSquare:Follower = new Follower(BlueSquare, true, 4);
			addChild(blueSquare);


			SPIKE_LAYER.mask = yellowTriangle;

		}
	}
}
