package
{
	import aze.motion.eaze;

	import com.greensock.TweenMax;
	import com.senocular.utils.KeyObject;
	import com.sociodox.theminer.TheMiner;

	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.html.script.Package;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.ui.Keyboard;
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

		private var _firstKeyPressed:Boolean = false;

		private const MAX_MASK_GROW_SIZE:Number = 5;

		//{
		//  sprite:Sprite
		//  speed:Number
		//}
		private var _followingMouseDict:Dictionary;

		private var _layerTransitionActive:Boolean;

		private var masks:Vector.<MovieClip>;

		private var _debugSquare:Shape;

		//ANIMATIONS
		private const MASK_ZOOM_TIME:Number = 0.8;

		//AVATAR
		private var _playerAvatar:PlayerAvatar;
		private const MASK_GROWTH_DISTANCE:Number = 200;
		private const MASK_TRIGGER_DISTANCE:Number = 40;
		private const MASK_FINAL_GROW_SIZE:Number = 14;
		private const FINAL_DELAY_TIME:Number = 1;
		private const FINAL_ANIM_OUT_TIME:Number = 2;

		private var _sounds:Vector.<Sound>;
		private var _soundChannels:Vector.<SoundChannel>;
		private const SOUND_VOLUME:Number = 8;

		private var key:KeyObject;

	    public function Strata()
	    {
		    addEventListener(Event.ADDED_TO_STAGE, init);
	    }

		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			key = new KeyObject(stage);

			//MINER
			//this.addChild(new TheMiner());

			this.mouseEnabled = false
			this.mouseChildren = false;

			_followingMouseDict = new Dictionary();

			//CREATE LAYERS
			_layers = new Vector.<Layer>();
			_layers[TOP_LAYER_INDEX] = new Layer(new TopLayer()); //do not randomize the position in the center of the screen.
			_layers[SPIKE_LAYER_INDEX] = new Layer(new SpikeLayer());
			_layers[RING_LAYER_INDEX] = new Layer(new RingLayer());
			_layers[BLOCK_LAYER_INDEX] = new Layer(new BlockLayer());
			_layers[TITLE_LAYER_INDEX] = new Layer(new TitleLayer(), false); //don't randomize crack on last layer

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
			//check if first key pressed to play intro anim
			if(!_firstKeyPressed)
			{
				if (key.isDown(Keyboard.UP) || key.isDown(Keyboard.RIGHT) || (key.isDown(Keyboard.LEFT)))
				{
					playerStart();
				}
			}

			if (key.isDown(Keyboard.TAB))
			{
				showCrackLocation();
			}
			else if (_debugSquare)
			{
				hideCrackLocation();
			}

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
			if(_activeLayerIndex < TITLE_LAYER_INDEX)
			{
				var crack:MovieClip = _layers[_activeLayerIndex + 1].crack;
				var distanceToCrack:Number = Utils.distanceTwoPoints(_playerAvatar.x, _playerAvatar.y, crack.x, crack.y );
				//trace("crack " + crack.x + " " + crack.y);
				//trace("player " + _playerAvatar.x + " " + _playerAvatar.y);
				//trace(distanceToCrack);

				/*NOT IMPLEMENTED: CHECK FOR NASTIES
				if(_layers[_activeLayerIndex+ 1].nasty && _playerAvatar.hitTestObject(_layers[_activeLayerIndex +1].nasty))
				{
					goUpLayer();
				}*/

				//GROW LAYER
				if(distanceToCrack < MASK_GROWTH_DISTANCE)
				{
					//grow the mask
					var maskScale:Number = Utils.convertRange(0, MASK_GROWTH_DISTANCE, MAX_MASK_GROW_SIZE, 1, distanceToCrack);
					_activeMask.scaleX = maskScale;
					_activeMask.scaleY = maskScale;

					_hyperShell.scaleX = maskScale;
					_hyperShell.scaleY = maskScale;

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
						prepareGoDown();
					}
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
			_layers[_activeLayerIndex + 1].playerContainer.addChild(_playerAvatar);
			_playerAvatar.x = stage.stageWidth / 2;
			_playerAvatar.y = stage.stageHeight / 2;
			_playerAvatar.rotation = 270;

			//create avatar shell
			_hyperShell = new HyperAvatarShell();
			this.addChild(_hyperShell);
			attachFollowAvatar(_hyperShell, 7);
			createAvatarMask();

			//randomize crack location so that it does not appear on top of the player
			_layers[_activeLayerIndex + 1].randomizeCrackPosition(new Point(_playerAvatar.x, _playerAvatar.y));
		}

		private function createAvatarMask():void
		{
			_activeMask = masks[_activeLayerIndex];
			_activeMask.scaleX = 1;
			_activeMask.scaleY = 1;
			_layers[_activeLayerIndex + 1].playerContainer.addChild(_activeMask);
			_layers[_activeLayerIndex + 1].mask = _activeMask;
			attachFollowAvatar(_activeMask, 4);
		}

		private function removeAvatarMask():void
		{
			_layers[_activeLayerIndex + 1].mask = null;
			detachFollowAvatar(_activeMask);
			_layers[_activeLayerIndex + 1].playerContainer.removeChild(_activeMask);
			_activeMask = null;
		}

		//DIMENSION TRAVEL ------------------------------------

		private function prepareGoDown():void
		{
			trace("vvv DOWN LAYER vvv");
			_layerTransitionActive = true;

			eaze(_activeMask).to(MASK_ZOOM_TIME, {scaleX: MASK_FINAL_GROW_SIZE, scaleY:MASK_FINAL_GROW_SIZE}).onComplete(goDownEnd, _activeMask);
			eaze(_hyperShell).to(MASK_ZOOM_TIME, {scaleX: MASK_FINAL_GROW_SIZE, scaleY:MASK_FINAL_GROW_SIZE});

			//update the active layer
			_activeLayerIndex = _activeLayerIndex + 1;
			_layers[_activeLayerIndex].setActive();

			if(_activeLayerIndex == TITLE_LAYER_INDEX)
			{
				return;
			}

			//create new masked layer
			var newMaskLayer:Layer = _layers[_activeLayerIndex + 1];
			newMaskLayer.setMasked();

			//create new mask
			_activeMask = masks[_activeLayerIndex];
			_activeMask.scaleX = 1;
			_activeMask.scaleY = 1;
			_layers[_activeLayerIndex + 1].playerContainer.addChild(_activeMask);
			_layers[_activeLayerIndex + 1].mask = _activeMask;
			_activeMask.x = _layers[_activeLayerIndex].crack.x;
			_activeMask.y = _layers[_activeLayerIndex].crack.y;

			//animate the mask onto the avatar before setting it to follow
			_activeMask.scaleX = 0.2;
			_activeMask.scaleY = 0.2;
			eaze(_activeMask).to(0.5, {scaleX:1, scaleY:1});
			attachFollowAvatar(_activeMask, 4, false);

			//hide crack visibility immediately
			_layers[_activeLayerIndex].crack.visible = false;

			//place the avatar into the new mask
			var px:Number = _playerAvatar.x;
			var py:Number = _playerAvatar.y;
			_layers[_activeLayerIndex].playerContainer.removeChild(_playerAvatar);
			_layers[_activeLayerIndex + 1].playerContainer.addChild(_playerAvatar);
			_playerAvatar.x = px;
			_playerAvatar.y = py;

			//randomize crack location so that it does not appear on top of the player
			_layers[_activeLayerIndex + 1].randomizeCrackPosition(new Point(_playerAvatar.x, _playerAvatar.y));
		}

		private function goDownEnd(oldMask:MovieClip):void
		{
			_layers[_activeLayerIndex].mask = null;
			detachFollowAvatar(oldMask);
			_layers[_activeLayerIndex].playerContainer.removeChild(oldMask);
			oldMask = null;

			//remove old active layer
			var oldLayer:Layer = _layers[_activeLayerIndex - 1];
			oldLayer.setHidden();

			//change the sound playing
			playLayerSound();

			_layerTransitionActive = false;

			if(_activeLayerIndex != TITLE_LAYER_INDEX)
			{
				_hyperShell.scaleX = 1;
				_hyperShell.scaleY = 1;

				var startLabel:String = "inBegin"+_activeLayerIndex;
				var endLabel:String = "inEnd"+_activeLayerIndex;

				eaze(_hyperShell).play(startLabel + ">" + endLabel);
			}

			//when on the last frame fade out the player
			if(_activeLayerIndex == TITLE_LAYER_INDEX)
			{
				trace("THE END.");
				eaze(_playerAvatar).delay(FINAL_DELAY_TIME).to(FINAL_ANIM_OUT_TIME, { alpha:0 });
			}
		}

		/* NOT IMPLEMENTED
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
		}*/

		private function attachFollowAvatar(sprite:Sprite, speed:Number, setPosImmediately:Boolean = true):void
		{
			var followObject:Object = {sprite: sprite, speed: speed };
			_followingMouseDict[sprite] = followObject;

			//start sprite positioned on the avatar if desired
			if(_playerAvatar && setPosImmediately)
			{
				sprite.x = _playerAvatar.x;
				sprite.y = _playerAvatar.y;
			}
		}

		private function detachFollowAvatar(sprite:Sprite):void
		{
			delete _followingMouseDict[sprite];
		}

		public function playerStart():void
		{
			_firstKeyPressed = true;
			eaze(_hyperShell).play("inBegin0>inEnd0");
		}

		private function showCrackLocation():void
		{
			if(!_debugSquare)
			{
				if(_activeLayerIndex < _layers.length - 1)
				{
					_debugSquare = Utils.createDebugSquare();
					_debugSquare.x = _layers[_activeLayerIndex + 1].crack.x;
					_debugSquare.y = _layers[_activeLayerIndex + 1].crack.y;
					this.addChild(_debugSquare);
				}
			}
		}

		private function hideCrackLocation():void
		{
			if (_debugSquare)
			{
				this.removeChild(_debugSquare);
				_debugSquare = null;
			}
		}
	}
}
