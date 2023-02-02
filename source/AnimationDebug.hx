package;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
	*DEBUG MODE
 */
class AnimationDebug extends FlxState
{
	var bf:Boyfriend;
	var dad:Character;
	var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;
	var bg:FlxSprite;

	public function new(daAnim:String = 'spooky')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		bg = new FlxSprite().loadGraphic('assets/images/menuBGMagenta.png');
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		if (daAnim == 'bf')
			isDad = false;

		if (isDad)
		{
			dad = new Character(0, 0, daAnim);
			dad.screenCenter();
			dad.debugMode = true;
			add(dad);

			char = dad;
		}
		else
		{
			bf = new Boyfriend(0, 0);
			bf.screenCenter();
			bf.debugMode = true;
			add(bf);

			char = bf;
		}

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		add(textAnim);

		genBoyOffsets();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	function genBoyOffsets(pushList:Bool = true):Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.BLUE;
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	override function update(elapsed:Float)
	{
		textAnim.text = char.getCurAnimName();

		if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]))
		{
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E && FlxG.camera.zoom < 1.75) {
			FlxG.camera.zoom += 0.25;
			var scale = 1 / FlxG.camera.zoom;
			bg.scale.set(scale, scale);
			bg.updateHitbox();
			bg.screenCenter();
		}
		if (FlxG.keys.justPressed.Q && FlxG.camera.zoom > 0.25) {
			FlxG.camera.zoom -= 0.25;
			var scale = 1 / FlxG.camera.zoom;
			bg.scale.set(scale, scale);
			bg.updateHitbox();
			bg.screenCenter();
		}
		if (FlxG.keys.justPressed.R) {
			FlxG.camera.zoom = 1;
			bg.scale.set(1, 1);
			bg.updateHitbox();
			bg.screenCenter();
		}


		if (FlxG.keys.anyPressed([I, J, K, L]))
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90;
			else
				camFollow.velocity.x = 0;
		}
		else
		{
			camFollow.velocity.set();
		}

		function updateAnim() {
			char.playAnim(animList[curAnim], true);
			genBoyOffsets(false);
		}

		if (FlxG.keys.anyJustPressed([S, W, SPACE]))
		{
			if (FlxG.keys.justPressed.S)
				curAnim += 1;
			else if (FlxG.keys.justPressed.W)
				curAnim -= 1;
			updateAnim();
		}

		if (curAnim < 0) {
			curAnim = animList.length - 1;
			updateAnim();
		}

		if (curAnim > animList.length-1) {
			curAnim = 0;
			updateAnim();
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			if (upP)
				char.animOffsets.set(animList[curAnim], [char.animOffsets.get(animList[curAnim])[0], char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier]);
			if (downP)
				char.animOffsets.set(animList[curAnim], [char.animOffsets.get(animList[curAnim])[0], char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier]);
			if (leftP)
				char.animOffsets.set(animList[curAnim], [char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier, char.animOffsets.get(animList[curAnim])[1]]);
			if (rightP)
				char.animOffsets.set(animList[curAnim], [char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier, char.animOffsets.get(animList[curAnim])[1]]);

			genBoyOffsets(false);
			char.playAnim(animList[curAnim]);
		}

		super.update(elapsed);
	}
}
