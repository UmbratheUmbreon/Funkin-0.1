package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;
import flixel.FlxG;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, TitleState));

		#if !mobile
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
		#if cpp
		cpp.vm.Gc.enable(true);
		#end

		FlxG.signals.preStateSwitch.add(() -> {
			FlxG.bitmap.dumpCache();
			FlxG.sound.destroy(false);
			#if cpp
			cpp.vm.Gc.run(true);
			#end
		});
		FlxG.signals.postStateSwitch.add(() -> {
			#if cpp
			cpp.vm.Gc.run(false);
			#end
		});
		FlxG.mouse.visible = false;
	}
}
