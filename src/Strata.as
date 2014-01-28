package
{
	import aze.motion.eaze;

	import com.greensock.TweenMax;
	import com.sociodox.theminer.TheMiner;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;

	[SWF(backgroundColor="#000000", frameRate="30", width="1024", height="576")]
	public class Strata extends Sprite
	{
		public static const TOP_LAYER_INDEX:int = 0;
		public static const SPIKE_LAYER_INDEX:int = 1;
		public static const RING_LAYER_INDEX:int = 2;
		public static const BLOCK_LAYER_INDEX:int = 3;
		public static const TITLE_LAYER_INDEX:int = 4;

		private var _layers:Vector.<Layer>;
		private var _activeLayerIndex:int;
		private var _activeMask:MovieClip;


		private var _hyperShell:MovieClip;
		private var _subShell:MovieClip;

		//{
		//  sprite:Sprite
		//  speed:Number
		//}
		private var _followingMouseDict:Dictionary;

		private var _layerTransitionActive:Boolean;

		private var masks:Vector.<MovieClip>;
		private var _maskContainer:Sprite;

		//ANIMATIONS
		private const MASK_ZOOM_TIME:Number = 0.4;

		//AVATAR
		private var _playerAvatar:PlayerAvatar;
		private const MASK_GROWTH_DISTANCE:Number = 200;
		private const MASK_TRIGGER_DISTANCE:Number = 40;

		private var _sounds:Vector.<Sound>;
		private var _soundChannels:Vector.<SoundChannel>;
		private const SOUND_VOLUME:Number = 8;


	    public function Strata()
	    {
		    addEventListener(Event.ADDED_TO_STAGE, init);
	    }

		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			//MINER
			this.addChild(new TheMiner());

			this.mouseEnabled = false
			this.mouseChildren = false;

			_followingMouseDict = new Dictionary();

			//CREATE LAYERS
			_layers = new Vector.<Layer>();
			_layers[TOP_LAYER_INDEX] = new Layer(new TopLayer());
			_layers[SPIKE_LAYER_INDEX] = new Layer(new SpikeLayer());
			_layers[RING_LAYER_INDEX] = new Layer(new RingLayer());
			_layers[BLOCK_LAYER_INDEX] = new Layer(new BlockLayer());
			_layers[TITLE_LAYER_INDEX] = new Layer(new TitleLayer());

			//set active layer to the top
			_activeLayerIndex = TOP_LAYER_INDEX;

			addChild(_layers[TOP_LAYER_INDEX]);
			_layers[TOP_LAYER_INDEX].setActive();

			addChild(_layers[SPIKE_LAYER_INDEX]);
			_layers[SPIKE_LAYER_INDEX].setMasked();

			addChild(_layers[RING_LAYER_INDEX]);
			_layers[RING_LAYER_INDEX].setHidden();

			addChild(_layers[BLOCK_LAYER_INDEX]);
			_layers[BLOCK_LAYER_INDEX].setHidden();

			addChild(_layers[TITLE_LAYER_INDEX]);
			_layers[TITLE_LAYER_INDEX].setHidden();

			_maskContainer = new Sprite();
			addChild(_maskContainer);<br />

			//CREATE MASKS
			masks = new Vector.<MovieClip>();
			masks[TOP_LAYER_INDEX] = new TopMask();
			masks[SPIKE_LAYER_INDEX] = new SpikeMask();
			masks[RING_LAYER_INDEX] = new RingMask();
			masks[BLOCK_LAYER_INDEX] = new BlockMask();

			//create player
			createAvatar();

			//create sounds
			_sounds = new Vector.<Sound>();
			_sounds[TOP_LAYER_INDEX] = null;
			_sounds[SPIKE_LAYER_INDEX] = new SpikeLayerSound();
			_sounds[RING_LAYER_INDEX] = new RingLayerSound();
			_sounds[BLOCK_LAYER_INDEX] = new BlockLayerSound();
			_sounds[TITLE_LAYER_INDEX] = null;

			//create sounds channels for each layer
			_soundChannels = new Vector.<SoundChannel>();
			for (var i:int = 0; i < _sounds.length; i ++)
			{
				if(_sounds[i])
				{
					_soundChannels[i] = _sounds[i].play(0, 99999, new SoundTransform(0));
				}
				else
				{
					_soundChannels[i] = null;
				}
			}

			//play sound on first layer
			playLayerSound();

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
			var crack:MovieClip = _layers[_activeLayerIndex + 1].crack;
			var distanceToCrack:Number = Utils.distanceTwoPoints(_playerAvatar.x, _playerAvatar.y, crack.x, crack.y );
			//trace("crack " + crack.x + " " + crack.y);
			//trace("player " + _playerAvatar.x + " " + _playerAvatar.y);
			//trace(distanceToCrack);

			//CHECK FOR NASTIES
			if(_layers[_activeLayerIndex+ 1].nasty && _playerAvatar.hitTestObject(_layers[_activeLayerIndex +1].nasty))
			{
				goUpLayer();
			}

			//GROW LAYER
			if(distanceToCrack < MASK_GROWTH_DISTANCE)
			{
				//grow the mask
				var maskScale:Number = Utils.convertRange(0, MASK_GROWTH_DISTANCE, 6, 1, distanceToCrack);
				_activeMask.scaleX = maskScale;
				_activeMask.scaleY = maskScale;

				//bleed volume in from layer below
				var maskedVolume:Number = Utils.convertRange(0, MASK_GROWTH_DISTANCE, SOUND_VOLUME, 0, distanceToCrack);
				if(_soundChannels[_activeLayerIndex + 1])
				{
					var soundTransform:SoundTransform = _soundChannels[_activeLayerIndex + 1].soundTransform;
					soundTransform.volume = maskedVolume;
					_soundChannels[_activeLayerIndex + 1].soundTransform = soundTransform;
				}

				//GO DOWN LAYER
				if(distanceToCrack < MASK_TRIGGER_DISTANCE)
				{
					_layerTransitionActive = true;
					eaze(_activeMask).to(MASK_ZOOM_TIME, {scaleX: 15, scaleY:10}).onComplete(goDownLayer);
				}
			}
		}

		//SOUNDS  --------------------------------------------

		private function playLayerSound():void
		{
			//fade out last layer sounds if existing
			if(_activeLayerIndex > TOP_LAYER_INDEX && _soundChannels[_activeLayerIndex - 1])
			{
				TweenMax.to(_soundChannels[_activeLayerIndex - 1], 1, {volume:0});
			}

			//fade in current layer sounds
			if(_soundChannels[_activeLayerIndex])
			{
				TweenMax.to(_soundChannels[_activeLayerIndex], 1, {volume:SOUND_VOLUME});
			}
		}

		//SPRITE CREATION ------------------------------------

		private function createAvatar():void
		{
			//create avatar ship
			_playerAvatar = new PlayerAvatar();
			_layers[_activeLayerIndex + 1].addChild(_playerAvatar);
			_playerAvatar.x = stage.stageWidth / 2;
			_playerAvatar.y = stage.stageHeight / 2;
			_playerAvatar.rotation = 270;

			//create avatar shell
			_hyperShell = new HyperAvatarShell();
			this.addChild(_hyperShell);
			attachFollowAvatar(_hyperShell, 6);
			_subShell = new SubAvatarShell();
			this.addChild(_subShell);
			attachFollowAvatar(_subShell, 8);

			createAvatarMask();
		}

		private function createAvatarMask():void
		{
			_activeMask = masks[_activeLayerIndex];
			_activeMask.scaleX = 1;
			_activeMask.scaleY = 1;
			_maskContainer.addChild(_activeMask);
			_layers[_activeLayerIndex + 1].mask = _activeMask;
			attachFollowAvatar(_activeMask, 4);

			var startLabel:String = "inBegin"+_activeLayerIndex;
			var endLabel:String = "inEnd"+_activeLayerIndex;
			eaze(_hyperShell).play(startLabel + ">" + endLabel);
			eaze(_subShell).play(startLabel + ">" + endLabel);
		}

		private function removeAvatarMask():void
		{
			_layers[_activeLayerIndex + 1].mask = null;
			detachFollowAvatar(_activeMask);
			_maskContainer.removeChild(_activeMask);
			_activeMask = null;

			var startLabel:String = "outBegin"+_activeLayerIndex;
			var endLabel:String = "outEnd"+_activeLayerIndex;
			eaze(_hyperShell).play(startLabel + ">" + endLabel);
			eaze(_subShell).play(startLabel + ">" + endLabel);
		}

		//DIMENSION TRAVEL ------------------------------------

		private function goDownLayer():void
		{
			trace("vvv DOWN LAYER vvv");

			//remove old active layer
			var oldLayer:Layer = _layers[_activeLayerIndex];
			oldLayer.setHidden();

			//unmask active layer
			removeAvatarMask();

			//update the active layer
			_activeLayerIndex = _activeLayerIndex + 1;
			_layers[_activeLayerIndex].setActive();

			//change the sound playing
			playLayerSound();

			if(_activeLayerIndex == TITLE_LAYER_INDEX)
			{
				return;
			}

			//create new masked layer
			var newMaskLayer:Layer = _layers[_activeLayerIndex + 1];
			newMaskLayer.setMasked();

			//create new mask
			createAvatarMask();

			//animate in the mask
			_activeMask.scaleX = 0.2;
			_activeMask.scaleY = 0.2;
			eaze(_activeMask).to(0.5, {scaleX:1, scaleY:1});

			//place the avatar into the new mask
			var px:Number = _playerAvatar.x;
			var py:Number = _playerAvatar.y;
			_layers[_activeLayerIndex].removeChild(_playerAvatar);
			_layers[_activeLayerIndex + 1].addChild(_playerAvatar);
			_playerAvatar.x = px;
			_playerAvatar.y = py;

			_layerTransitionActive = false;
		}

		private function goUpLayer():void
		{
			trace("^^^ UP LAYER ^^^");

			removeAvatarMask();

			//remove old masked layer
			var oldMaskLayer:Layer = _layers[_activeLayerIndex + 1];
			oldMaskLayer.setHidden();

			//set the active layer to the layer before
			_activeLayerIndex = _activeLayerIndex - 1;
			_layers[_activeLayerIndex].setActive();

			//set old active as new masked
			_layers[_activeLayerIndex + 1].setMasked();

			//create new mask
			createAvatarMask();

			//place the avatar into the new mask
			var px:Number = _playerAvatar.x;
			var py:Number = _playerAvatar.y;
			_layers[_activeLayerIndex + 2].removeChild(_playerAvatar);
			_layers[_activeLayerIndex + 1].addChild(_playerAvatar);
			_playerAvatar.x = px;
			_playerAvatar.y = py;

			_layerTransitionActive = false;
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
