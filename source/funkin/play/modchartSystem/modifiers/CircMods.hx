package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;

class CircXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    data.x += curPos2 * curPos2 * currentValue * -0.001;
  }
}

class CircYMod extends Modifier
{
  public var flipForDownscroll:Bool = true;

  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var curVal:Float = currentValue;
    curVal *= (Preferences.downscroll && flipForDownscroll ? -1 : 1);
    data.y += curPos2 * curPos2 * curVal * -0.001;
  }
}

class CircZMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    data.z += curPos2 * curPos2 * currentValue * -0.001;
  }
}

class CircAngleMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    data.angleZ += curPos2 * curPos2 * currentValue * -0.001;
  }
}

class CircAngleYMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    data.angleY += curPos2 * curPos2 * currentValue * -0.001;
  }
}

class CircAngleXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    data.angleX += curPos2 * curPos2 * currentValue * -0.001;
  }
}

class CircScaleMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var result:Float = curPos2 * curPos2 * currentValue * -0.001;
    data.scaleX += result;
    data.scaleY += result;
  }
}

class CircScaleXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var result:Float = curPos2 * curPos2 * currentValue * -0.001;
    data.scaleX += result;
  }
}

class CircScaleYMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var result:Float = curPos2 * curPos2 * currentValue * -0.001;
    data.scaleY += result;
  }
}

class CircSkewXMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var result:Float = curPos2 * curPos2 * currentValue * -0.001;
    data.skewX += result;
  }
}

class CircSkewYMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return; // skip math if mod is 0
    var curPos2:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    var result:Float = curPos2 * curPos2 * currentValue * -0.001;
    data.skewY += result;
  }
}

class CircSpeedMod extends Modifier
{
  public function new(name:String)
  {
    super(name);
    modPriority = 396;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    var r:Float = 1;
    var curPos2:Float = curPos * (Preferences.downscroll ? -1 : 1);
    var result:Float = curPos2 * curPos2 * currentValue * -0.001;

    return r + result;
  }
}
