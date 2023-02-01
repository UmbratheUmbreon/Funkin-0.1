package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	public var singTimer:Float = 0;
	public var heyTimer:Float = 0;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var healthColor:FlxColor = 0xFFFF0000;
	public var iconOffsets:Array<Float> = [0, 0];
	public var iconAntialiasing:Bool = true;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		animOffsets = new Map<String, Array<Dynamic>>();
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				tex = FlxAtlasFrames.fromSparrow('assets/images/characters/GF_assets.png', 'assets/images/characters/GF_assets.xml');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);

				addOffset('scared');

				playAnim('danceRight');
				healthColor = 0xFFA5004D;

			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = FlxAtlasFrames.fromSparrow('assets/images/characters/DADDY_DEAREST.png', 'assets/images/characters/DADDY_DEAREST.xml');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);
				playAnim('idle');

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);
				healthColor = 0xFFAF66CE;

			case 'spooky':
				tex = FlxAtlasFrames.fromSparrow('assets/images/characters/spooky_kids_assets.png', 'assets/images/characters/spooky_kids_assets.xml');
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				addOffset('danceLeft');
				addOffset('danceRight');

				addOffset("singUP", -20, 26);
				addOffset("singRIGHT", -130, -14);
				addOffset("singLEFT", 130, -10);
				addOffset("singDOWN", -50, -130);

				playAnim('danceRight');
				healthColor = 0xFFD57E00;
				iconOffsets = [10, -15];

			case 'monster':
				tex = FlxAtlasFrames.fromSparrow('assets/images/characters/Monster_Assets.png', 'assets/images/characters/Monster_Assets.xml');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -20, 50);
				addOffset("singRIGHT", -51);
				addOffset("singLEFT", -30);
				addOffset("singDOWN", -30, -40);
				playAnim('idle');
				healthColor = 0xFFF3FF6E;
				iconOffsets = [0, 5];
		}
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		switch (curCharacter)
		{
			case 'gf':
				danced = !danced;

				if (danced) playAnim('danceRight');
				else playAnim('danceLeft');
			case 'spooky':
				danced = !danced;

				if (danced) playAnim('danceRight');
				else playAnim('danceLeft');
			default:
				playAnim('idle');
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(animation.curAnim.name);
		if (animOffsets.exists(animation.curAnim.name))
		{
			offset.set(daOffset[0], daOffset[1]);
		}

		if (curCharacter == 'gf')
		{
			switch (AnimName) {
				case 'singLEFT': danced = true;
				case 'singRIGHT': danced = false;
				case 'singUP' | 'singDOWN': danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	override function update(elapsed) {
		super.update(elapsed);
		if (singTimer > 0) singTimer -= elapsed;
		if (heyTimer > 0) heyTimer -= elapsed;
	}
}
