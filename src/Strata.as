package
{
	import aze.motion.easing.Cubic;
	import aze.motion.easing.Quint;
	import aze.motion.eaze;

	import com.sociodox.theminer.TheMiner;

	import flash.display.MovieClip;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	[SWF(backgroundColor="#000000", frameRate="30", width="1024", height="576")]
	public class Strata extends Sprite
	{
		public static const TOP_LAYER_INDEX:int = 0;
		public static const SPIKE_LAYER_INDEX:int = 1;
		public static const RING_LAYER_INDEX:int = 2;
		public static const BLOCK_LAYER_INDEX:int = 3;

		public static var layers:Vector.<MovieClip>;
		public static var _activeLayer:int;
		private var _activeMask:MovieClip;

		//{
		//  sprite:Sprite
		//  speed:Number
		//}
		private var _followingMouseDict:Dictionary;

		private var _mouseDown:Boolean;

		//ANIMATIONS
		private const MASK_ZOOM_TIME:Number = 0.8;

	    public function Strata()
	    {
		    addEventListener(Event.ADDED_TO_STAGE, init);
	    }

		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addChild(new TheMiner());
			_followingMouseDict = new Dictionary();

			//CREATE LAYERS
			layers = new Vector.<MovieClip>();
			layers[TOP_LAYER_INDEX] = new TopLayer();
			layers[SPIKE_LAYER_INDEX] = new SpikyLayer();

			//set active layer to the top
			_activeLayer = TOP_LAYER_INDEX;
			addChild(layers[TOP_LAYER_INDEX]);
			addChild(layers[SPIKE_LAYER_INDEX]);

			//create player
			createAvatar();

			//UPDATE
			this.addEventListener(Event.ENTER_FRAME, update);

			//MOUSE PRESS
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp)
		}

		private function update(e:Event):void
		{
			//if the mask is expanding do not allow mouse follow
			if(_mouseDown)
			{
				return;
			}

			//MOUSE FOLLOWING OBJECTS
			for each (var followObject:Object in _followingMouseDict)
			{
				var dx:int = followObject.sprite.x - stage.mouseX;
				var dy:int = followObject.sprite.y - stage.mouseY;
				followObject.sprite.x -= dx / followObject.speed;
				followObject.sprite.y -= dy / followObject.speed;
			}
		}

		private function onMouseDown(e:MouseEvent):void
		{
			if(e.target.name == "crack")
			{
				_mouseDown = true;
				eaze(_activeMask).to(MASK_ZOOM_TIME, {scaleX: 20, scaleY:10}).easing(Cubic.easeIn).onComplete(goDownLayer, e.target);
			}
		}

		private function onMouseUp(e:MouseEvent):void
		{
			_mouseDown = false;
			eaze(_activeMask).to(MASK_ZOOM_TIME, {scaleX: 1, scaleY:1}).easing(Cubic.easeOut);
		}

		private function createAvatar():void
		{
			//create mask
			var diamondMask:DiamondMask = new DiamondMask();
			this.addChild(diamondMask);
			_activeMask = diamondMask;
			layers[SPIKE_LAYER_INDEX].mask = diamondMask;
			attachFollowMouse(diamondMask, 4);

			//create avatar shell
			var hyper:HyperAvatarShell = new HyperAvatarShell();
			this.addChild(hyper);
			attachFollowMouse(hyper, 6);
			var sub:SubAvatarShell = new SubAvatarShell();
			this.addChild(sub);
			attachFollowMouse(sub, 8);

		}

		private function goDownLayer(crack:MovieClip):void
		{
			//remove old active layer
			var oldLayer:MovieClip = layers[_activeLayer];
			removeChild(oldLayer);

			//update the active layer
			_activeLayer = _activeLayer + 1;

			//unmask masked layer
			var maskedLayer:MovieClip = layers[_activeLayer];
			maskedLayer.mask = null;
			detachFollowMouse(_activeMask);
			this.removeChild(_activeMask);

			//remove crack
			maskedLayer.removeChild(crack);
		}

		private function goUpLayer():void
		{
			//implement
		}

		private function changeLayer(goingDown:Boolean):void
		{

		}

		private function attachFollowMouse(sprite:Sprite, speed:Number):void
		{
			var followObject:Object = {sprite: sprite, speed: speed };
			_followingMouseDict[sprite] = followObject;
		}

		private function detachFollowMouse(sprite:Sprite):void
		{
			delete _followingMouseDict[sprite];
		}
	}
}
