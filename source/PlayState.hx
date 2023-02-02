package;

import flixel.graphics.FlxGraphic;
import openfl.events.KeyboardEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;

	private var camFollow:FlxObject;
	private var camFollowPoint:FlxPoint;
	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var dadStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health(default, set):Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	var scoreTxt:FlxText;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	var playerIcon:FlxSprite;
	var dadIcon:FlxSprite;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	//var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var songScore:Int = 0;
	var defaultCamZoom:Float = 1.05;

	public static var campaignScore:Int = 0;

	override function destroy() {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		camFollowPoint.put();
		super.destroy();
	}

	override public function create()
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('Tutorial');

		Conductor.changeBPM(SONG.bpm);

		/*switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
		}*/

		switch (SONG.song.toLowerCase()) {
			case 'spookeez' | 'south' | 'monster':
				var hallowTex = FlxAtlasFrames.fromSparrow('assets/images/halloween_bg.png', 'assets/images/halloween_bg.xml');

				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);
	
				isHalloween = true;
	
				defaultCamZoom = 1.05;
			default:
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic('assets/images/stageback.png');
				// bg.setGraphicSize(Std.int(bg.width * 2.5));
				// bg.updateHitbox();
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);
	
				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic('assets/images/stagefront.png');
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(1, 1);
				stageFront.active = false;
				add(stageFront);
	
				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic('assets/images/stagecurtains.png');
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;
	
				add(stageCurtains);
	
				defaultCamZoom = 0.9;
		}

		gf = new Character(400, 130, 'gf');
		gf.scrollFactor.set(0.95, 0.95);
		add(gf);
		gf.dance();

		dad = new Character(100, 100, SONG.player2);
		add(dad);
		dad.dance();

		var camPos:FlxPoint = FlxPoint.get(gf.getGraphicMidpoint().x + 100, gf.getGraphicMidpoint().y + 100);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					//camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			/*case 'dad':
				camPos.x += 400;*/
		}

		boyfriend = new Boyfriend(770, 450);
		add(boyfriend);
		boyfriend.playAnim('idle');

		/*var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;*/

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		dadStrums = new FlxTypedGroup<FlxSprite>();

		startingSong = true;

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPoint = FlxPoint.get(camPos.x, camPos.y);

		camFollow.setPosition(camPos.x, camPos.y);
		add(camFollow);
		FlxG.camera.focusOn(FlxPoint.get(camPos.x, camPos.y));
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		camPos.put();

		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic('assets/images/healthBar.png');
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(dad.healthColor, boyfriend.healthColor);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 170, healthBarBG.y + healthBarBG.height + 5, 0, "Score: 0", 16);
		scoreTxt.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.NONE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.cameras = [camHUD];
		add(scoreTxt);

		var dadGraphicThing:FlxGraphic = FlxG.bitmap.add('assets/images/icons/icon-${dad.curCharacter}.png', false, 'assets/images/icons/icon-${dad.curCharacter}.png');
		dadIcon = new FlxSprite().loadGraphic(dadGraphicThing, true, 150, 150);
		dadIcon.y = (healthBar.y - (dadIcon.height / 2)) - dad.iconOffsets[1];
		dadIcon.scrollFactor.set();
		dadIcon.antialiasing = true;
		dadIcon.animation.add('normal', [0], 24, true, false, false);
		dadIcon.animation.add('ouch', [1], 24, true, false, false);
		dadIcon.animation.play('normal', true);
		dadIcon.antialiasing = dad.iconAntialiasing;
		add(dadIcon);

		var bfGraphicThing:FlxGraphic = FlxG.bitmap.add('assets/images/icons/icon-${boyfriend.curCharacter}.png', false, 'assets/images/icons/icon-${boyfriend.curCharacter}.png');
		playerIcon = new FlxSprite().loadGraphic(bfGraphicThing, true, 150, 150);
		playerIcon.y = (healthBar.y - (playerIcon.height / 2)) - boyfriend.iconOffsets[1];
		playerIcon.scrollFactor.set();
		playerIcon.antialiasing = true;
		playerIcon.animation.add('normal', [0], 24, true, true, false);
		playerIcon.animation.add('ouch', [1], 24, true, true, false);
		playerIcon.animation.play('normal', true);
		playerIcon.antialiasing = boyfriend.iconAntialiasing;
		add(playerIcon);

		for (icon in [dadIcon, playerIcon]) {
			icon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(50, 0, 100, 100, 0) * 0.01)) - (icon.width / 2) + (icon == playerIcon ? 50 - boyfriend.iconOffsets[0] : -50 - dad.iconOffsets[0]);
		}

		if (isStoryMode)
		{
			// TEMP for now, later get rid of startCountdown()
			// add(doof);
			startCountdown();
		}
		else
			startCountdown();

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		playerIcon.cameras = dadIcon.cameras = [camHUD];
		//doof.cameras = [camHUD];

		super.create();
	}

	var startTimer:FlxTimer;

	function startCountdown():Void
	{
		generateStaticArrows(0);
		generateStaticArrows(1);

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play('assets/sounds/intro3' + TitleState.soundExt, 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic('assets/images/ready.png');
					ready.scrollFactor.set();
					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro2' + TitleState.soundExt, 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic('assets/images/set.png');
					set.scrollFactor.set();
					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro1' + TitleState.soundExt, 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic('assets/images/go.png');
					go.scrollFactor.set();
					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/introGo' + TitleState.soundExt, 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		startingSong = false;
		FlxG.sound.playMusic('assets/songs/${SONG.song.toLowerCase()}/Inst${TitleState.soundExt}', 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		//im so sorry for this if statement
		if (SONG.needsVoices && (openfl.Assets.exists('assets/songs/${SONG.song.toLowerCase()}/Voices${TitleState.soundExt}', MUSIC)
			#if sys || sys.FileSystem.exists('assets/songs/${SONG.song.toLowerCase()}/Voices${TitleState.soundExt}') #end))
			vocals = new FlxSound().loadEmbedded('assets/songs/${SONG.song.toLowerCase()}/Voices${TitleState.soundExt}');
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			var arrTex = FlxAtlasFrames.fromSparrow('assets/images/NOTE_assets.png', 'assets/images/NOTE_assets.xml');
			babyArrow.frames = arrTex;
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.scrollFactor.set();
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			babyArrow.updateHitbox();
			babyArrow.antialiasing = true;

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			if (player == 1) {
				playerStrums.add(babyArrow);
			} else {
				dadStrums.add(babyArrow);
			}

			switch (Math.abs(i))
			{
				case 0:
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}

			babyArrow.x += Note.swagWidth * i;
			babyArrow.animation.play('static');
			babyArrow.x += 87.5;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				vocals.time = Conductor.songPosition;

				FlxG.sound.music.play();
				vocals.play();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
		}

		super.closeSubState();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		for (icon in [dadIcon, playerIcon]) {
			icon.setGraphicSize(Std.int(FlxMath.lerp(150, icon.width, 0.50)));
			icon.updateHitbox();
		}

		if (FlxG.keys.justPressed.ENTER && startedCountdown)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition = FlxG.sound.music.time;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (camFollowPoint.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollowPoint.x = dad.getMidpoint().x + 150;
				camFollowPoint.y = dad.getMidpoint().y - 100;
				vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollowPoint.x != boyfriend.getMidpoint().x - 100)
			{
				camFollowPoint.x = boyfriend.getMidpoint().x - 100;
				camFollowPoint.y = boyfriend.getMidpoint().y - 100;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}
		camFollow.setPosition(FlxMath.lerp(camFollow.x, camFollowPoint.x, 0.8), FlxMath.lerp(camFollow.y, camFollowPoint.y, 0.8));

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		
		if (unspawnNotes[0] != null)
		{
			final spawnTime:Float = (1850/1)/(FlxMath.bound(camHUD.zoom, null, 1));

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < spawnTime)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				daNote.x = (daNote.mustPress ? playerStrums.members[daNote.noteData].x : dadStrums.members[daNote.noteData].x);
				daNote.x += (daNote.isSustainNote ? Note.swagWidth/2 - daNote.width/2 : 0);
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.mustPress && daNote.canBeHit)
					dadNoteHit(daNote);

				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
				daNote.y += daNote.offsetY;

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.y < -daNote.height)
				{

					if (daNote.mustPress)
					{
						noteMiss(daNote.noteData, true);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
			sustainShit();
		}

		var helds:Array<Bool> = [];
		var presseds = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (!presseds[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm')
			{
				boyfriend.singTimer += elapsed;
				helds.push(true);
			} else {
				helds.push(false);
			}
			resetStrumOffsets(spr);
		});
		if (!helds.contains(true)) boyfriend.singTimer /= 1.5;
		var sings = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
		dadStrums.forEach(function(spr:FlxSprite)
		{
			if (!dad.animation.curAnim.name.startsWith('sing${sings[spr.ID]}'))
				spr.animation.play('static');

			resetStrumOffsets(spr);
		});

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());
		}

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player1));
		#end
	}

	//setter go vroom vroom and not boom boom (sounds of an engine fucking exploding)
	function set_health(Val:Float) {
		health = FlxMath.bound(Val, -1, 2);

		for (icon in [dadIcon, playerIcon]) {
			icon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(health*50, 0, 100, 100, 0) * 0.01)) - (icon.width / 2) + (icon == playerIcon ? 50 - boyfriend.iconOffsets[0] : -50 - dad.iconOffsets[0]);
		}

		if (health*50 < 20) playerIcon.animation.play('ouch');
		else playerIcon.animation.play('normal');
		if (health*50 > 80) dadIcon.animation.play('ouch');
		else dadIcon.animation.play('normal');

		if (health <= 0)
		{
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		return health;
	}

	function endSong():Void
	{
		Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);

				FlxG.switchState(new StoryMenuState());

				StoryMenuState.weekUnlocked[1] = true;
				
				Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty == '-hard';

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.switchState(new PlayState());
			}
		}
		else
		{
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
		}

		songScore += score;

		rating.loadGraphic('assets/images/' + daRating + ".png");
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.updateHitbox();
		rating.antialiasing = true;
		rating.velocity.x -= FlxG.random.int(0, 10);
		add(rating);

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic('assets/images/num' + Std.int(i) + '.png');
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;
			numScore.antialiasing = true;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();
			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001,
			onComplete: _ -> {
				coolText.destroy();
				rating.destroy();
			}
		});
	}

	function onKeyPress(event:KeyboardEvent):Void
	{
		if (paused) return;
		var pressed = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];

		if (pressed.contains(true) && generatedMusic)
		{
			//literally week 7 inputs LMAO
			//id like to have doubles thank you very much
			var possibles:Array<Note> = [];
			var directions:Array<Int> = [];
			var doubles:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					if (directions.contains(daNote.noteData))
					{
						for (coolNote in possibles)
						{
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
							{ // if it's the same note twice at < 10ms distance, just delete it
								// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
								doubles.push(daNote);
								break;
							}
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
							{ // if daNote is earlier than existing note (coolNote), replace
								possibles.remove(coolNote);
								possibles.push(daNote);
								break;
							}
						}
					}
					else
					{
						possibles.push(daNote);
						directions.push(daNote.noteData);
					}
				}
			});

			for (note in doubles)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			possibles.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			if (possibles.length > 0)
			{
				for (shit in 0...pressed.length)
				{ // if a direction is hit that shouldn't be
					if (pressed[shit] && !directions.contains(shit))
						noteMiss(shit);
				}
				for (coolNote in possibles)
				{
					if (pressed[coolNote.noteData])
						goodNoteHit(coolNote);
				}
			}
			else
			{
				for (shit in 0...pressed.length)
					if (pressed[shit])
						noteMiss(shit);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (pressed[spr.ID] && spr.animation.curAnim.name != 'confirm')
					spr.animation.play('pressed');
	
				resetStrumOffsets(spr);
			});
		}
	}

	function onKeyRelease(event:KeyboardEvent):Void
	{
		if (paused) return;
		var released = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (released[spr.ID])
				spr.animation.play('static');

			resetStrumOffsets(spr);
		});
	}

	function resetStrumOffsets(spr:FlxSprite) {
		if (spr.animation.curAnim.name == 'confirm')
		{
			spr.centerOffsets();
			spr.offset.x -= 13;
			spr.offset.y -= 13;
		}
		else
			spr.centerOffsets();
	}

	private function sustainShit():Void
	{
		// HOLDING
		var holds = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

		if (holds.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holds[daNote.noteData])
					goodNoteHit(daNote);
			});
		}
	}

	function noteMiss(direction:Int = 1, mute:Bool = false):Void
	{
		health -= 0.06;
		if (mute) vocals.volume = 0;
		if (combo > 5) gf.playAnim('sad');
		combo = 0;

		songScore -= 10;

		FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));

		final sings = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
		boyfriend.playAnim('sing${sings[direction]}miss', true);
		boyfriend.singTimer = 100; //very high number because you probably release the key right after and trigger the every frame /=

		scoreTxt.text = 'Score: $songScore';
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			var noAnim:Bool = false;
			var healthAmount = 0.023;
			switch (note.type) {
				case 'hey':
					boyfriend.playAnim('hey', true);
					gf.playAnim('cheer', true);
					gf.heyTimer = boyfriend.heyTimer = 0.3;
					noAnim = true;
				case 'no animation':
					noAnim = true;
				case 'hurt':
					healthAmount = -healthAmount;
					//boyfriend.playAnim('hurt', true);
					//boyfriend.singTimer += 0.15;
					noAnim = true;
			}

			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime);
				combo += 1;
			}

			health += healthAmount;

			if (!noAnim) {
				final sings = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
				boyfriend.playAnim('sing${sings[note.noteData]}', true);
				boyfriend.singTimer += 0.15;
			}

			playerStrums.members[note.noteData].animation.play('confirm', true);

			note.wasGoodHit = true;
			vocals.volume = 1;

			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
		scoreTxt.text = 'Score: $songScore';
	}

	function dadNoteHit(daNote:Note) {
		if (SONG.song != 'Tutorial')
			camZooming = true;

		var noAnim = false;
		switch (daNote.type) {
			case 'hey':
				dad.playAnim('hey', true);
				dad.heyTimer = 0.3;
				noAnim = true;
			case 'no animation':
				noAnim = true;
		}

		if (!noAnim) {
			final sings = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
			dad.playAnim('sing${sings[daNote.noteData]}', true);
			dad.singTimer += 0.15;
			if (dad.singTimer > FlxG.elapsed*10) dad.singTimer = FlxG.elapsed*10;
		}
		dadStrums.forEach(function(spr:FlxSprite)
		{
			if(spr.ID == Math.abs(daNote.noteData)) spr.animation.play('confirm');
				
			resetStrumOffsets(spr);
		});

		if (SONG.needsVoices)
			vocals.volume = 1;

		daNote.kill();
		notes.remove(daNote, true);
		daNote.destroy();
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play('assets/sounds/thunder_' + FlxG.random.int(1, 2) + TitleState.soundExt);
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		if (SONG.needsVoices)
		{
			if (vocals.time > Conductor.songPosition + Conductor.stepCrochet
				|| vocals.time < Conductor.songPosition - Conductor.stepCrochet)
			{
				vocals.pause();
				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}

		super.stepHit();

		switch (curSong) {
			case 'Tutorial':
				switch (curStep) {
					case 124 | 188:
						boyfriend.playAnim('hey', true);
						dad.playAnim('cheer', true);
						dad.heyTimer = boyfriend.heyTimer = 0.3;
				}
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			else
				Conductor.changeBPM(SONG.bpm);
		}
		if (dad.singTimer <= 0 && dad.heyTimer <= 0 && curBeat % dad.danceBeats == 0)
			dad.dance();

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		for (icon in [dadIcon, playerIcon]) {
			icon.setGraphicSize(Std.int(icon.width + 30));
			icon.updateHitbox();
		}

		if (curBeat % gfSpeed == 0 && gf.heyTimer <= 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.heyTimer <= 0 && boyfriend.singTimer <= 0 && curBeat % boyfriend.danceBeats == 0)
			boyfriend.playAnim('idle');

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}

		switch (curSong) {
			case 'Fresh':
				switch (curBeat)
				{
					case 16:
						camZooming = true;
						gfSpeed = 2;
					case 48 | 112:
						gfSpeed = 1;
					case 80:
						gfSpeed = 2;
				}
			case 'Bopeebo':
				if (curBeat % 8 == 7)
				{
					boyfriend.playAnim('hey', true);
					boyfriend.heyTimer = 0.5;
				}
		}
	}
}
