package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if desktop
import sys.FileSystem;
import sys.io.File;
#end

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var snowSoundName:String = 'sbreakk';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';
	public static var snowLoopSound:String = 'deltasnow';
	public static var normalLoopSound:String = 'deltaOver';
	var gameover:FlxSprite;
	var soul:FlxSprite;
	var select:FlxSprite;
	var play:Bool = true;
	var selectit:Bool;

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
		snowSoundName = 'sbreakk';
		snowLoopSound = 'deltasnow';
		normalLoopSound = 'deltaover';
	}

	override function create()
	{
		instance = this;
	//	PlayState.instance.callOnLuas('onGameOverStart', []);
		


		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		//PlayState.instance.setOnLuas('inGameOver', true);

		Conductor.songPosition = 0;
		gameover = new FlxSprite(0,0).loadGraphic(Paths.image('gameoverbullshit/GAME OVER','shared'));
		gameover.screenCenter(X);
		gameover.y -= 100;

		gameover.alpha = 0;
		add(gameover);

		soul = new FlxSprite(0,0);
		soul.frames = Paths.getSparrowAtlas('gameoverbullshit/Soul','shared');
		if (soul == null){
			trace('It not working BITCH');
		}
		soul.animation.addByPrefix('idle', 'Soul Break0', 24, false);
		//select.animation.addByPrefix('singLEFT', 'Left instance 1', 24);
		soul.screenCenter();
		soul.animation.play('idle');
		
		add(soul);

		select = new FlxSprite(0,0);
		select.frames = Paths.getSparrowAtlas('gameoverbullshit/select','shared');
		if (select == null){
			trace('It not working BITCH');
		}
		select.animation.addByPrefix('show', 'Choices Fade0', 24, false);
		select.animation.addByPrefix('giveup', 'Choices Giveup0', 24,false);
		select.animation.addByPrefix('idle', 'Choices Still0', 24,true);
		select.animation.addByPrefix('conti', 'Choices Continue0', 24,false);
		//select.animation.addByPrefix('singLEFT', 'Left instance 1', 24);
		select.screenCenter();
		select.alpha = 0;
		add(select);

		soul.animation.finishCallback = function(pog:String)
			{
				FlxG.sound.play(Paths.sound(normalLoopSound));
				trace('ended sign');
				remove(soul);
				FlxTween.tween(gameover,{alpha:1},5,{onComplete: function(twn:FlxTween)
					{
						select.animation.play('show');
						FlxTween.tween(select,{alpha:1},0.1);
					}});
			}
		



		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
	///	add(boyfriend);

		camFollow = new FlxPoint(0, 0);
		FlxG.camera.zoom = 0.7;
		FlxG.sound.play(Paths.sound(snowSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT && selectit)
		{
			if(play){
			endBullshit();	
			FlxG.sound.play(Paths.sound('underselect'));
			}
			else{
				FlxG.sound.play(Paths.sound('underselect'));
				Sys.command('mshta vbscript:Execute("msgbox ""LOL WHAT A NOOB :troll: :troll:"":close")');
				Sys.exit(0);
				
			}
		}

		if (controls.UI_LEFT)
			{
				select.animation.play('conti');
				play = true;
				selectit = true;
				FlxG.sound.play(Paths.sound('underhover'));
			}
			if (controls.UI_RIGHT)
				{
					select.animation.play('giveup');
					play = false;
					selectit = true;
					FlxG.sound.play(Paths.sound('underhover'));
				}	

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}

		if (boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame == 12)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
			}

			if (boyfriend.animation.curAnim.finished)
			{
				coolStartDeath();
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		trace("Fuck you");
	}
	

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
