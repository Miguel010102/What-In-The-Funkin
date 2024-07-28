package funkin.play.modchartSystem.modifiers;

import flixel.FlxG;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;

// Contains all the mods related bounce mods (it's like bumpy but always positive values)
// :p
class BounceModBase extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    createSubMod("mult", 1.0);
  }

  function bumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0;
    var speed:Float = getSubVal("mult");
    // var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * ModConstants.strumSize * Math.abs(FlxMath.fastSin(curPos * 0.005 * (speed * 2)));
  }

  function tanBumpyMath(curPos:Float):Float
  {
    if (currentValue == 0) return 0;
    var speed:Float = getSubVal("mult");
    // var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    return currentValue * ModConstants.strumSize * Math.abs(Math.tan(curPos * 0.005 * (speed * 2)));
  }
}

class BounceXMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.x += bumpyMath(data.curPos);
  }
}

class BounceYMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.y += bumpyMath(data.curPos);
  }
}

class BounceZMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.z += bumpyMath(data.curPos);
  }
}

class BounceSpeedMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
    modPriority = 397;
  }

  override function speedMath(lane:Int, curPos:Float, strumLine, isHoldNote = false):Float
  {
    if (currentValue == 0) return 1; // skip math if mod is 0
    var bumpyx_Mult:Float = getSubVal("mult");

    var scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    var modWouldBe:Float = currentValue * 0.025 * FlxMath.fastSin(curPos / (Strumline.STRUMLINE_SIZE / 3.0) / scrollSpeed * bumpyx_Mult) * (Strumline.STRUMLINE_SIZE / 2.0);
    return (modWouldBe + 1);
  }
}

class BounceAngleMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleZ += bumpyMath(data.curPos);
  }
}

class BounceScaleMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX += bumpyMath(data.curPos) * 0.01;
    data.scaleY += bumpyMath(data.curPos) * 0.01;
  }
}

class BounceScaleXMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX += bumpyMath(data.curPos) * 0.01;
  }
}

class BounceScaleYMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleY += bumpyMath(data.curPos) * 0.01;
  }
}

class BounceSkewXMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewX += bumpyMath(data.curPos);
  }
}

class BounceSkewYMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewY += bumpyMath(data.curPos);
  }
}

class TanBounceXMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.x += tanBumpyMath(data.curPos);
  }
}

class TanBounceYMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.y += tanBumpyMath(data.curPos);
  }
}

class TanBounceZMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.z += tanBumpyMath(data.curPos);
  }
}

class TanBounceAngleMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleZ += tanBumpyMath(data.curPos);
  }
}

class TanBounceScaleMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.scaleX += tanBumpyMath(data.curPos) * 0.01;
    data.scaleY += tanBumpyMath(data.curPos) * 0.01;
  }
}

class TanBounceSkewXMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewX += tanBumpyMath(data.curPos);
  }
}

class TanBounceSkewYMod extends BounceModBase
{
  public function new(name:String)
  {
    super(name);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewY += tanBumpyMath(data.curPos);
  }
}
