package
{
	import Main.BlueSquare;

	import com.sociodox.theminer.TheMiner;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.ui.Mouse;

	[SWF(backgroundColor="#333333", frameRate="30", width="1280", height="720")]
	public class Strata extends Sprite
	{
		private var _square:BlueSquare;

	    public function Strata()
	    {
		    addEventListener(Event.ADDED_TO_STAGE, init);
	    }

		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addChild(new TheMiner());


			//_square = new BlueSquare();
			//this.addChild(_square);

			var follower:Follower = new Follower(BlueSquare);
			addChild(follower);

			//this.addEventListener(Event.ENTER_FRAME, update);
		}

		private function update(e:Event):void
		{
			_square.x = stage.mouseX;
			_square.y = stage.mouseY;
		}
	}
}
