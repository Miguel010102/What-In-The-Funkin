package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.notes.StrumlineNote;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.PlayState;
import flixel.math.FlxMath;

// Contains all mods which are unique or have debug purposes!
// Notes angle themselves towards direction of travel
class OrientMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    // modPriority = -50;
    // modPriority = -200;
    modPriority = -999999; // ALWAYS APPLY LAST!!
    unknown = false;
    notesMod = true;
    // holdsMod = true;
    // pathMod = true;
    strumsMod = true;
    specialMod = true;

    createSubMod("offset", 1.0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || isArrowPath || data.noteType == "receptor") return;

    // Oh hey, same math for spiral hold shit lmfao
    var a:Float = (data.y - data.lastKnownPosition.y) * -1; // height
    var b:Float = (data.x - data.lastKnownPosition.x); // length
    var calculateAngleDif:Float = Math.atan(b / a);
    // var calculateAngleDif:Float = Math.atan2(b, a);
    if (Math.isNaN(calculateAngleDif))
    {
      calculateAngleDif = data.lastKnownOrientAngle; // TODO -> Make this less likely to be a NaN in the first place lol
    }
    else
    {
      calculateAngleDif *= (180 / Math.PI);
      data.lastKnownOrientAngle = calculateAngleDif;
    }
    data.angleZ += (calculateAngleDif * currentValue);
    data.angleZ -= data.whichStrumNote.strumExtraModData.orientStrumAngle; // undo the mother fucking strum rotation for orient XD
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.orientExtraMath = currentValue;
    // strumLine.orientExtraMath[lane] = (currentValue == 0 ? 0 : getSubVal("offset"));
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;

    // strumLine.orientExtraMath[data.direction] = true;
    var a:Float = (data.y - data.lastKnownPosition.y) * -1;
    var b:Float = (data.x - data.lastKnownPosition.x);
    var calculateAngleDif:Float = Math.atan(b / a);
    // var calculateAngleDif:Float = Math.atan2(b, a);
    if (Math.isNaN(calculateAngleDif))
    {
      calculateAngleDif = 0;
    }
    else
    {
      calculateAngleDif *= (180 / Math.PI);
      // data.lastKnownOrientAngle = calculateAngleDif;
    }
    var orientAngleAmount:Float = (calculateAngleDif * currentValue);
    data.angleZ += orientAngleAmount;
    // strumLine.orientStrumAngle[data.direction] = orientAngleAmount;
    data.whichStrumNote.strumExtraModData.orientStrumAngle = orientAngleAmount;
  }
}

// Same as Orient but instead notes will sample based on mod math instead of last known position.
class Orient2Mod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    // modPriority = -50;
    // modPriority = -200;
    modPriority = -999998; // ALWAYS APPLY LAST!!
    unknown = false;
    notesMod = true;
    // holdsMod = true;
    // pathMod = true;
    strumsMod = true;
    specialMod = true;

    createSubMod("offset", 1.0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.orient2 = currentValue;
    if (currentValue == 0 || isArrowPath || data.noteType == "receptor") return;

    // Oh hey, same math for spiral hold shit lmfao
    var a:Float = (data.y - data.lastKnownPosition.y) * -1; // height
    var b:Float = (data.x - data.lastKnownPosition.x); // length
    var calculateAngleDif:Float = Math.atan(b / a);
    // var calculateAngleDif:Float = Math.atan2(b, a);
    if (Math.isNaN(calculateAngleDif))
    {
      calculateAngleDif = data.lastKnownOrientAngle; // TODO -> Make this less likely to be a NaN in the first place lol
    }
    else
    {
      calculateAngleDif *= (180 / Math.PI);
      data.lastKnownOrientAngle = calculateAngleDif;
    }
    data.angleZ += (calculateAngleDif * currentValue);
    data.angleZ -= data.whichStrumNote.strumExtraModData.orientStrumAngle; // undo the mother fucking strum rotation for orient XD
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.orientExtraMath = currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;

    // strumLine.orientExtraMath[data.direction] = true;
    var a:Float = (data.y - data.lastKnownPosition.y) * -1;
    var b:Float = (data.x - data.lastKnownPosition.x);
    var calculateAngleDif:Float = Math.atan(b / a);
    // var calculateAngleDif:Float = Math.atan2(b, a);
    if (Math.isNaN(calculateAngleDif))
    {
      calculateAngleDif = 0;
    }
    else
    {
      calculateAngleDif *= (180 / Math.PI);
      // data.lastKnownOrientAngle = calculateAngleDif;
    }
    var orientAngleAmount:Float = (calculateAngleDif * currentValue);
    data.angleZ += orientAngleAmount;
    // strumLine.orientStrumAngle[data.direction] = orientAngleAmount;
    data.whichStrumNote.strumExtraModData.orientStrumAngle = orientAngleAmount;
  }
}

// WTF?!
class BangarangMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -50;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0) return;

    var yOffset:Float = 0;

    var speed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;

    var curpos:Float = data.curPos;

    var fYOffset = -curpos / speed;
    var fEffectHeight = FlxG.height;
    var fScale = FlxMath.remapToRange(fYOffset, 0, fEffectHeight, 0, 1); // scale
    var fNewYOffset = fYOffset * fScale;
    var fBrakeYAdjust = currentValue * (fNewYOffset - fYOffset);
    fBrakeYAdjust = FlxMath.bound(fBrakeYAdjust, -400, 400); // clamp

    yOffset -= fBrakeYAdjust * speed;
    data.y += curpos + yOffset;
  }
}

// If enabled, *all* sprites will be sorted by their z value! Can lead to holds and arrowpath being infront of receptors / notes!
class ZSortMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    // IMPORTANT NOTE -> ONLY WORKS FOR BOYFRIEND!
    if (strumLine != PlayState.instance.playerStrumline) return;
    if (currentValue >= 0.5)
    {
      PlayState.instance.noteRenderMode = true;
      strumLine.zSortMode = true; // Doesn't really matter what it's set too here, right?
    }
    else if (currentValue < 0.0)
    {
      PlayState.instance.noteRenderMode = false;
      strumLine.zSortMode = false;
    }
    else
    {
      PlayState.instance.noteRenderMode = false;
      strumLine.zSortMode = true;
    }
  }
}

// If enabled,.. errr... 3D?
class ThreeDProjection extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.whichStrumNote.strumExtraModData.threeD = currentValue >= 0.5;
  }
}

class MathCutOffMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.mathCutOff = currentValue;
    // strumLine.mods.mathCutOff[lane] = currentValue;
  }
}

class DisableHoldMathShortCutMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.noHoldMathShortcut = currentValue;
    // strumLine.mods.noHoldMathShortcut[lane] = currentValue;
  }
}

class DrawDistanceBackMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.drawdistanceBack = currentValue;
    // strumLine.mods.drawdistanceBack_Lane[lane] = currentValue;
  }
}

class DrawDistanceMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    var whichStrum = strumLine.getByIndex(lane);
    whichStrum.strumExtraModData.drawdistanceForward = currentValue;
    // strumLine.mods.drawdistanceForward_Lane[lane] = currentValue;
  }
}

class InvertModValues extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    specialMod = true;
  }

  override function specialMath(lane:Int, strumLine:Strumline):Void
  {
    strumLine.mods.invertValues = currentValue < 0.5 ? false : true;
  }
}
