package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

// Contains all the mods related hourglass mods
// Custom mod made by me (Hazard24)!
class HourGlassModBase extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    createSubMod("start", 420.0);
    createSubMod("end", 135.0);
    createSubMod("offset", 0.0);
  }

  // Basically just a copy of Sudden math with an extra step (b and c)
  function hourGlassMath(data:NoteData):Float
  {
    if (currentValue == 0) return 0.0; // skip math if mod is 0

    var pos:Float = data.curPos_unscaled * (Preferences.downscroll ? -1 : 1);
    // var curPos2:Float = data.curPos_unscaled - (data.whichStrumNote?.noteModData?.curPos_unscaled ?? 0);

    // Copy of Sudden math
    var a:Float = FlxMath.remapToRange(pos, getSubVal("start") + getSubVal("offset"), getSubVal("end") + getSubVal("offset"), 1, 0);
    a = FlxMath.bound(a, 0, 1); // clamp

    var b:Float = 1 - a;
    var c:Float = (FlxMath.fastCos(b * Math.PI) / 2) + 0.5;

    return c;
  }
}

class HourGlassX extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var c:Float = hourGlassMath(data);
    data.x += ModConstants.strumSize * c * (data.direction - 1.5) * -2 * currentValue;
  }
}

class HourGlassY extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var c:Float = hourGlassMath(data);
    data.y += ModConstants.strumSize * c * (data.direction - 1.5) * -2 * currentValue;
  }
}

class HourGlassZ extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var c:Float = hourGlassMath(data);
    data.z += ModConstants.strumSize * c * (data.direction - 1.5) * -2 * currentValue;
  }
}

class HourGlassAngleX extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var c:Float = hourGlassMath(data);
    data.angleX += c * (currentValue * -1);
  }
}

class HourGlassAngleZ extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var c:Float = hourGlassMath(data);
    data.angleZ += c * (currentValue * -1);
  }
}

class HourGlassAngleY extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var c:Float = hourGlassMath(data);
    data.angleY += c * (currentValue * -1);
  }
}

class HourGlassSkewX extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var c:Float = hourGlassMath(data);
    data.skewX += c * (currentValue * -2);
  }
}

class HourGlassSkewY extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var c:Float = hourGlassMath(data);
    data.skewY += c * (currentValue * -2);
  }
}

class HourGlassScaleX extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var c:Float = hourGlassMath(data);
    data.scaleX += c * currentValue;
  }
}

class HourGlassScaleY extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var c:Float = hourGlassMath(data);
    data.scaleY += c * currentValue;
  }
}

class HourGlassScale extends HourGlassModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var c:Float = hourGlassMath(data);
    data.scaleX += c * currentValue;
    data.scaleY += c * currentValue;
  }
}
