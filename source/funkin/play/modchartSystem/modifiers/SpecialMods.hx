package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.notes.StrumlineNote;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.PlayState;
import flixel.math.FlxMath;
import lime.math.Vector4;

// Contains all mods which are unique or have debug purposes!
// load a path from an external file
class CustomPathMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = 119;
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
  }

  // TODO - FIX THE FLIP TO CENTER LOGIC OR REMOVE IT ENTIRELY!!!

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    var path = PlayState.instance.customArrowPathModTest;
    var whichStrumNote = data.whichStrumNote;
    if (path == null || currentValue == 0 || whichStrumNote == null) return;

    // automatically apply linearY mod to cancel the default y movement

    var strumX:Float = whichStrumNote.x;
    var strumY:Float = whichStrumNote.y;
    var strumZ:Float = whichStrumNote.z;

    if (data.noteType == "receptor")
    {
      strumX = data.strumPosWasHere.x;
      strumY = data.strumPosWasHere.y;
      strumZ = data.strumPosWasHere.z;
    }
    else
    {
      strumX += isHoldNote ? strumLine.mods.getHoldOffsetX(isArrowPath) : strumLine.getNoteXOffset();
      if (isHoldNote)
      {
        if (Preferences.downscroll)
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2);
        }
        else
        {
          strumY += (Strumline.STRUMLINE_SIZE / 2) - Strumline.INITIAL_OFFSET;
        }
      }
      else
      {
        strumY += strumLine.getNoteYOffset();
      }
    }

    var strumPosition:Vector4 = new Vector4(strumX, strumY, strumZ, 0);
    var notePosition:Vector4 = new Vector4(data.x, data.y, data.z, 0);

    var newPosition1:Vector4 = PlayState.instance.executePath(beatTime, data.whichStrumNote.strumDistance, data.direction, currentValue, strumPosition);
    var newPosition2:Vector4 = PlayState.instance.executePath(beatTime, Math.abs(data.curPos) * -1 / 0.47, data.direction, currentValue, notePosition);
    // newPosition2.y *= (Preferences.downscroll && flipForDownscroll ? -1 : 1);
    data.x = notePosition.x + (newPosition1.x - newPosition2.x);
    data.y = notePosition.y + (newPosition1.y - newPosition2.y);
    data.z = notePosition.z + (newPosition1.z - newPosition2.z);

    // automatically apply linearY mod to cancel the default y movement
    var curVal:Float = currentValue * -1;
    data.y += data.curPos * curVal;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    var path = PlayState.instance.customArrowPathModTest;
    if (path == null || currentValue == 0) return;

    var newPosition = PlayState.instance.executePath(beatTime, 0.0, data.direction, currentValue, new Vector4(data.x, data.y, data.z, 0));
    data.x = newPosition.x;
    data.y = newPosition.y;
    data.z = newPosition.z;
  }
}

// Notes angle themselves towards direction of travel
class OrientMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority = -50;
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

    var curpos:Float = data.curPos * (Preferences.downscroll ? 1 : -1);

    var fYOffset = -curpos / speed;
    var fEffectHeight = FlxG.height;
    var fScale = FlxMath.remapToRange(fYOffset, 0, fEffectHeight, 0, 1); // scale
    var fNewYOffset = fYOffset * fScale;
    var fBrakeYAdjust = currentValue * (fNewYOffset - fYOffset);
    fBrakeYAdjust = FlxMath.bound(fBrakeYAdjust, -400, 400); // clamp

    yOffset -= fBrakeYAdjust * speed;
    data.y -= curpos + yOffset;
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
    if (currentValue >= 0.5)
    {
      PlayState.instance.noteRenderMode = true;
      strumLine.zSortMode = true; // Doesn't really matter what it's set too here, right?
    }
    else if (currentValue < 0.0)
    {
      PlayState.instance.noteRenderMode = false;
      strumLine.zSortMode = true;
    }
    else
    {
      PlayState.instance.noteRenderMode = false;
      strumLine.zSortMode = false;
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
