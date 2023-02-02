package;

import flixel.group.FlxGroup.FlxTypedGroup;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var daOptions:Array<String> = ['Resume Song', 'Restart Song', 'Exit'];
	var grpOptions:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;
	public function new(x:Float, y:Float)
	{
		super();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...daOptions.length)
		{
			var optionTxt:Alphabet = new Alphabet(0, (70 * i) + 30, daOptions[i], true, false);
			optionTxt.isMenuItem = true;
			optionTxt.targetY = i;
			grpOptions.add(optionTxt);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
			changeSelection(-1);
		}
		if (downP)
		{
			FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
			changeSelection(1);
		}

		/*if (FlxG.keys.justPressed.J)
		{
			PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}*/

		if (accepted) {
			switch (daOptions[curSelected]) {
				case 'Resume Song':
					close();
				case 'Restart Song':
					FlxG.resetState();
				case 'Exit':
					FlxG.switchState((PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState()));
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = daOptions.length - 1;
		if (curSelected >= daOptions.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.alpha = 0.6;
			if (item.targetY == 0) item.alpha = 1;
		}
	}
}
