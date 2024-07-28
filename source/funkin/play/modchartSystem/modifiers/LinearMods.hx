package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

class LinearXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.x += data.curPos * currentValue;
  }
}

class LinearYMod extends Modifier
{
  public var flipForDownscroll:Bool = true;

  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos;
    curPos2 *= Preferences.downscroll ? -1 : 1;
    var curVal:Float = currentValue;
    curVal *= (Preferences.downscroll && flipForDownscroll ? -1 : 1);
    data.y += curPos2 * curVal;
  }
}

class LinearZMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.z += data.curPos * currentValue;
  }
}

// this is probably useless cuz dizzy exists lmao
class LinearAngleMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleZ += data.curPos * currentValue;
  }
}

class LinearScaleMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var curPos2:Float = data.curPos;
    // curPos2 *= Preferences.downscroll ? -1 : 1;
    data.scaleX += curPos2 * currentValue;
    data.scaleY += curPos2 * currentValue;
  }
}

class LinearScaleXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX += data.curPos * currentValue;
  }
}

class LinearScaleYMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleY += data.curPos * currentValue;
  }
}

class LinearSkewXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewX += data.curPos * currentValue;
  }
}

class LinearSkewYMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewY += data.curPos * currentValue;
  }
}

class LinearSpeedMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    modPriority = 395;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1;
    return curPos / 100 * currentValue;
  }
}

// for legacy support
class ScaleLinearLegacyMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0) return;
    var curPos2:Float = data.curPos_unscaled;
    curPos2 *= Preferences.downscroll ? -1 : 1;
    var p:Float = curPos2 * -1;
    data.scaleX = FlxMath.lerp(data.scaleX, currentValue, p / 1000 * 2);
    data.scaleY = FlxMath.lerp(data.scaleY, currentValue, p / 1000 * 2);
    data.scaleZ = FlxMath.lerp(data.scaleZ, currentValue, p / 1000 * 2);
  }
}
