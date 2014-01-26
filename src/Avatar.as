package
{

	import flash.display.MovieClip;
	import flash.events.Event;
	import com.senocular.utils.KeyObject;
	import flash.ui.Keyboard;

	public class Avatar extends MovieClip
	{
		private var key:KeyObject;
		private var speed:Number = 0.35;
		private var rotateSpeed:Number = 7.5;
		private var vx:Number = 0;
		private var vy:Number = 0;
		private var friction:Number = 0.90;

		public function Avatar()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			key = new KeyObject(stage);
			addEventListener(Event.ENTER_FRAME, loop, false, 0, true);
		}

		public function loop(e:Event):void
		{
			if (key.isDown(Keyboard.UP))
			{
				vy += Math.sin(degreesToRadians(rotation)) * speed;
				vx += Math.cos(degreesToRadians(rotation)) * speed;
			} else {
				vy *= friction;
				vx *= friction;
			}

			if (key.isDown(Keyboard.RIGHT))
				rotation += rotateSpeed;
			else if (key.isDown(Keyboard.LEFT))
				rotation -= rotateSpeed;

			y += vy;
			x += vx;

			//STOP ON CORNER
			if (x > stage.stageWidth)
			{
				x = stage.stageWidth;
				vx = 0;
			}
			else if (x < 0)
			{
				x = 0;
				vx = 0;
			}

			if (y > stage.stageHeight)
			{
				y = stage.stageHeight;
				vy = 0;
			}
			else if (y < 0)
			{
				y = 0;
				y = 0;
			}

			//JUMP TO OPPOSITE SIDE
			/*
			if (x > stage.stageWidth)
				x = 0;
			else if (x < 0)
				x = stage.stageWidth;

			if (y > stage.stageHeight)
				y = 0;
			else if (y < 0)
				y = stage.stageHeight;
				*/
		}

		public function degreesToRadians(degrees:Number) : Number
		{
			return degrees * Math.PI / 180;
		}

	}

}