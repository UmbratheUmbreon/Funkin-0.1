package;

import flixel.tweens.FlxTween;
import flixel.graphics.FlxGraphic;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import htmlparser.HtmlDocument;
import lime.utils.Assets;

class FreeplayState extends MusicBeatState
{
	var songs:Array<String> = ["Tutorial", "Bopeebo", "Fresh", "Dadbattle"];
	var iconRefs:Array<String> = ['gf', 'dad', 'dad', 'dad'];
	var colours:Array<Array<Int>> = [[165, 0, 77], [146, 113, 253], [146, 113, 253], [146, 113, 253]];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var bg:FlxSprite;

	private var grpSongs:FlxTypedGroup<Alphabet>;

	override function create()
	{
		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);
		}

		var isDebug:Bool = #if debug true #else false #end;

		for (i=>bool in StoryMenuState.weekUnlocked) {
			if (bool || isDebug) {
				switch (i) {
					case 1:
						songs.push('Spookeez');
						iconRefs.push('spooky');
						colours.push([34, 51, 68]);
						
						songs.push('South');
						iconRefs.push('spooky');
						colours.push([34, 51, 68]);
			
						songs.push('Monster');
						iconRefs.push('monster');
						colours.push([34, 51, 68]);
				}
			}
		}

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(AssetPaths.menuDesat__png);
		bg.screenCenter();
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
			var icon:AttachedHealthIcon = new AttachedHealthIcon(iconRefs[i], songText);
			add(icon);
			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic('assets/music/title' + TitleState.soundExt, 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].toLowerCase(), curDifficulty);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].toLowerCase());
			PlayState.isStoryMode = false;
			FlxG.switchState(new PlayState());
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected], curDifficulty);

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
		}
		PlayState.storyDifficulty = curDifficulty;
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		intendedScore = Highscore.getScore(songs[curSelected], curDifficulty);
		// lerpScore = 0;

		var newColor:FlxColor = FlxColor.fromRGB(colours[curSelected][0], colours[curSelected][1], colours[curSelected][2]);
		if (bg.color != newColor)
			FlxTween.color(bg, 0.5, bg.color, newColor);

		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

class AttachedHealthIcon extends FlxSprite {
	public var sprTracker:Alphabet;
	public function new(icon:String, tracker:Alphabet) {
		super();
		var iconGraphic:FlxGraphic = FlxG.bitmap.add('assets/images/icons/icon-$icon.png', false, 'assets/images/icons/icon-$icon.png');
		loadGraphic(iconGraphic, true, 150, 150);
		scrollFactor.set();
		antialiasing = true;
		animation.add('normal', [0], 24, true, false, false);
		animation.play('normal', true);
		this.sprTracker = tracker;
	}

	override function update(elapsed) {
		x = sprTracker.x + sprTracker.width + 10;
		y = sprTracker.y - 30;
		alpha = sprTracker.alpha;
	}
}