package
{
	import aze.motion.easing.Cubic;
	import aze.motion.eaze;

	import com.sociodox.theminer.TheMiner;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;

	[SWF(backgroundColor="#000000", frameRate="30", width="1024", height="576")]
	public class Strata extends Sprite
	{
		public static const TOP_LAYER_INDEX:int = 0;
		public static const SPIKE_LAYER_INDEX:int = 1;
		public static const RING_LAYER_INDEX:int = 2;
		public static const BLOCK_LAYER_INDEX:int = 3;
		public static const TITLE_LAYER_INDEX:int = 4;

		public static var layers:Vector.<Layer>;
		public static var _activeLayerIndex:int;
		public static var _activeMask:MovieClip;

		//{
		//  sprite:Sprite
		//  speed:Number
		//}
		private var _followingMouseDict:Dictionary;

		private var _layerTransitionActive:Boolean;

		private var masks:Vector.<MovieClip>;
		private var _maskContainer:Sprite;

		//ANIMATIONS
		private const MASK_ZOOM_TIME:Number = 0.9;

		//AVATAR
		private var _playerAvatar:PlayerAvatar;
		private const MASK_GROWTH_DISTANCE:Number = 200;
		private const MASK_TRIGGER_DISTANCE:Number = 40;

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
			layers = new Vector.<Layer>();
			layers[TOP_LAYER_INDEX] = new Layer(new TopLayer());
			layers[SPIKE_LAYER_INDEX] = new Layer(new SpikeLayer());
			layers[RING_LAYER_INDEX] = new Layer(new RingLayer());
			layers[BLOCK_LAYER_INDEX] = new Layer(new BlockLayer());
			layers[TITLE_LAYER_INDEX] = new Layer(new TitleLayer());

			//set active layer to the top
			_activeLayerIndex = TOP_LAYER_INDEX;

			addChild(layers[TOP_LAYER_INDEX]);
			layers[TOP_LAYER_INDEX].setActive();

			addChild(layers[SPIKE_LAYER_INDEX]);
			layers[SPIKE_LAYER_INDEX].setMasked();

			addChild(layers[RING_LAYER_INDEX]);
			layers[RING_LAYER_INDEX].setHidden();

			addChild(layers[BLOCK_LAYER_INDEX]);
			layers[BLOCK_LAYER_INDEX].setHidden();

			addChild(layers[TITLE_LAYER_INDEX]);
			layers[TITLE_LAYER_INDEX].setHidden();

			_maskContainer = new Sprite();
			addChild(_maskContainer);

			//CREATE MASKS
			masks = new Vector.<MovieClip>();
			masks[TOP_LAYER_INDEX] = new SpikeMask();
			masks[SPIKE_LAYER_INDEX] = new RingMask();
			masks[RING_LAYER_INDEX] = new BlockMask();
			masks[BLOCK_LAYER_INDEX] = new BlockMask();

			//create player
			createAvatar();

			//UPDATE
			this.addEventListener(Event.ENTER_FRAME, update);
		}

		//UPDATE ------------------------------------

		private function update(e:Event):void
		{
			//MOUSE FOLLOWING OBJECTS
			for each (var followObject:Object in _followingMouseDict)
			{
				var dx:int = followObject.sprite.x - _playerAvatar.x;
				var dy:int = followObject.sprite.y - _playerAvatar.y;
				followObject.sprite.x -= dx / followObject.speed;
				followObject.sprite.y -= dy / followObject.speed;
			}

			//if the mask is expanding do not allow distance check
			if(_layerTransitionActive)
			{
				return;
			}


			//CHECK DISTANCE TO CRACK
			var crack:MovieClip = layers[_activeLayerIndex + 1].crack;
			var distanceToCrack:Number = Utils.distanceTwoPoints(_playerAvatar.x, _playerAvatar.y, crack.x, crack.y );
			//trace("crack " + crack.x + " " + crack.y);
			//trace("player " + _playerAvatar.x + " " + _playerAvatar.y);
			//trace(distanceToCrack);

			//GROW LAYER
			if(distanceToCrack < MASK_GROWTH_DISTANCE)
			{
				var maskScale:Number = Utils.convertRange(0, MASK_GROWTH_DISTANCE, 6, 1, distanceToCrack);
				_activeMask.scaleX = maskScale;
				_activeMask.scaleY = maskScale;

				//GO DOWN LAYER
				if(distanceToCrack < MASK_TRIGGER_DISTANCE)
				{
					_layerTransitionActive = true;
					eaze(_activeMask).to(MASK_ZOOM_TIME, {scaleX: 20, scaleY:10}).onComplete(goDownLayer);
				}
			}

		}

		//SPRITE CREATION ------------------------------------

		private function createAvatar():void
		{
			createAvatarMask();

			//create avatar ship
			_playerAvatar = new PlayerAvatar();
			this.addChild(_playerAvatar);
			_playerAvatar.x = stage.stageWidth / 2;
			_playerAvatar.y = stage.stageHeight / 2;

			//create avatar shell
			var hyper:HyperAvatarShell = new HyperAvatarShell();
			this.addChild(hyper);
			attachFollowAvatar(hyper, 6);
			var sub:SubAvatarShell = new SubAvatarShell();
			this.addChild(sub);
			attachFollowAvatar(sub, 8);
		}

		private function createAvatarMask():void
		{
			_activeMask = masks[_activeLayerIndex];
			_maskContainer.addChild(_activeMask);
			layers[_activeLayerIndex + 1].mask = _activeMask;
			attachFollowAvatar(_activeMask, 4);
		}

		private function removeAvatarMask():void
		{
			layers[_activeLayerIndex + 1].mask = null;
			detachFollowAvatar(_activeMask);
			_maskContainer.removeChild(_activeMask);
		}

		//DIMENSION TRAVEL ------------------------------------

		private function goDownLayer():void
		{
			trace("vvv DOWN LAYER vvv");

			//remove old active layer
			var oldLayer:Layer = layers[_activeLayerIndex];
			removeChild(oldLayer);

			//unmask active layer
			removeAvatarMask();

			//update the active layer
			_activeLayerIndex = _activeLayerIndex + 1;
			layers[_activeLayerIndex].setActive();

			//create new masked layer
			var newMaskLayer:Layer = layers[_activeLayerIndex + 1];
			newMaskLayer.setMasked();

			//create new mask
			createAvatarMask();

			_layerTransitionActive = false;
		}

		private function goUpLayer():void
		{
			trace("^^^ UP LAYER ^^^");
			//implement
		}

		private function attachFollowAvatar(sprite:Sprite, speed:Number):void
		{
			var followObject:Object = {sprite: sprite, speed: speed };
			_followingMouseDict[sprite] = followObject;

			//start sprite positioned on mouse
			if(_playerAvatar)
			{
				sprite.x = _playerAvatar.x;
				sprite.y = _playerAvatar.y;
			}
		}

		private function detachFollowAvatar(sprite:Sprite):void
		{
			delete _followingMouseDict[sprite];
		}
	}
}
