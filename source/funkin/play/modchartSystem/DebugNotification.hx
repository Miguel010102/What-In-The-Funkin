package funkin.play.modchartSystem;

import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

class DebugNotification extends FlxText
{
  public var alphaTween:FlxTween;
  public var timer:FlxTimer;
  public var age:Float = 0;

  public function new()
  {
    super(0, 0, FlxG.width / 4, '', 20);
    this.scrollFactor.set();
    this.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
  }

  // Call this function to trigger the process of showing and hiding the debug notification text!
  public function displayText(txtToShow:String = "", color:FlxColor = FlxColor.WHITE):Void
  {
    this.text = txtToShow;
    this.color = color;

    alphaTween = FlxTween.tween(this, {alpha: 1}, 0.25, {ease: FlxEase.linear});

    timer = new FlxTimer().start(5 + 0.25, function(tmr) {
      if (alphaTween != null) alphaTween.cancel();
      alphaTween = FlxTween.tween(this, {alpha: 0}, 1, {ease: FlxEase.linear});
      timer = null;
    });
  }

  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);
    age += elapsed;
  }

  public override function kill():Void
  {
    age = 0;
    if (alphaTween != null) alphaTween.cancel();
    if (timer != null) timer.cancel();
    timer = null;
    alphaTween = null;
    alpha = 0;
    super.kill();
  }

  public override function revive():Void
  {
    super.revive();
    age = 0;
  }

  public override function destroy():Void
  {
    if (alphaTween != null) alphaTween.cancel();
    if (timer != null) timer.cancel();
    timer = null;
    alphaTween = null;
    super.destroy();
  }
}
