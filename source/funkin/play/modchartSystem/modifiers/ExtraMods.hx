package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

class AttenuateXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    // This is stupid XD

    var nd = data.direction % Strumline.KEY_COUNT;
    var newPos = FlxMath.remapToRange(nd, 0, Strumline.KEY_COUNT, Strumline.KEY_COUNT * -1 * 0.5, Strumline.KEY_COUNT * 0.5);

    var p:Float = data.curPos * (Preferences.downscroll ? -1 : 1);
    p = (p * p) * 0.1;

    var curVal:Float = currentValue * 0.0015;

    data.x += newPos * curVal * p;
    data.x += curVal * p * 0.5;
  }
}

class AttenuateYMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    // This is stupid XD

    var nd = data.direction % Strumline.KEY_COUNT;
    var newPos = FlxMath.remapToRange(nd, 0, Strumline.KEY_COUNT, Strumline.KEY_COUNT * -1 * 0.5, Strumline.KEY_COUNT * 0.5);

    var p:Float = data.curPos * (Preferences.downscroll ? -1 : 1);
    p = (p * p) * 0.1;

    var curVal:Float = currentValue * 0.0015;

    data.z += newPos * curVal * p;
    data.z += curVal * p * 0.5;
  }
}

class AttenuateZMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    // This is stupid XD

    var nd = data.direction % Strumline.KEY_COUNT;
    var newPos = FlxMath.remapToRange(nd, 0, Strumline.KEY_COUNT, Strumline.KEY_COUNT * -1 * 0.5, Strumline.KEY_COUNT * 0.5);

    var p:Float = data.curPos * (Preferences.downscroll ? -1 : 1);
    p = (p * p) * 0.1;

    var curVal:Float = currentValue * 0.0015;

    data.z += newPos * curVal * p;
    data.z += curVal * p * 0.5;
  }
}

class AttenuateAngleMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    // This is stupid XD

    var nd = data.direction % Strumline.KEY_COUNT;
    var newPos = FlxMath.remapToRange(nd, 0, Strumline.KEY_COUNT, Strumline.KEY_COUNT * -1 * 0.5, Strumline.KEY_COUNT * 0.5);

    var p:Float = data.curPos * (Preferences.downscroll ? -1 : 1);
    p = (p * p) * 0.1;

    var curVal:Float = currentValue * 0.0015;

    data.angleZ += newPos * curVal * p;
    data.angleZ += curVal * p * 0.5;
  }
}

class AttenuateSkewXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    // This is stupid XD

    var nd = data.direction % Strumline.KEY_COUNT;
    var newPos = FlxMath.remapToRange(nd, 0, Strumline.KEY_COUNT, Strumline.KEY_COUNT * -1 * 0.5, Strumline.KEY_COUNT * 0.5);

    var p:Float = data.curPos * (Preferences.downscroll ? -1 : 1);
    p = (p * p) * 0.1;

    var curVal:Float = currentValue * 0.0015;

    data.skewX += newPos * curVal * p;
    data.skewX += curVal * p * 0.5;
  }
}

class AttenuateSkewYMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0

    // This is stupid XD

    var nd = data.direction % Strumline.KEY_COUNT;
    var newPos = FlxMath.remapToRange(nd, 0, Strumline.KEY_COUNT, Strumline.KEY_COUNT * -1 * 0.5, Strumline.KEY_COUNT * 0.5);

    var p:Float = data.curPos * (Preferences.downscroll ? -1 : 1);
    p = (p * p) * 0.1;

    var curVal:Float = currentValue * 0.0015;

    data.skewY += newPos * curVal * p;
    data.skewY += curVal * p * 0.5;
  }
}
