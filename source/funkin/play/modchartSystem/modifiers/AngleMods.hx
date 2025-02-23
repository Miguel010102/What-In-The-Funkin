package funkin.play.modchartSystem.modifiers;

import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.notes.Strumline;
import flixel.math.FlxAngle;
import funkin.play.modchartSystem.NoteData;

// Contains all the mods related to rotating the nots / strums!
// Rotate the strums on the z axis
class AngleZOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function strumMath(data:NoteData):Void
  {
    data.angleZ += currentValue;
  }
}

// Rotate the strums on the x axis
class AngleXOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || data.noteType == "receptor") return;
    data.angleX += currentValue;
  }

  override function strumMath(data:NoteData):Void
  {
    data.angleX += currentValue;
  }
}

// Rotate the strums on the y axis
class AngleYOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || data.noteType == "receptor") return;
    data.angleY += currentValue;
  }

  override function strumMath(data:NoteData):Void
  {
    data.angleY += currentValue;
  }
}

// Rotate the notes on the z axis
class NotesAngleZOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, ?isArrowPath:Bool = false):Void
  {
    data.angleZ += currentValue;
  }
}

// Rotate the notes on the x axis
class NotesAngleXOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, ?isArrowPath:Bool = false):Void
  {
    data.angleX += currentValue;
  }
}

// Rotate the notes on the y axis
class NotesAngleYOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, ?isArrowPath:Bool = false):Void
  {
    data.angleY += currentValue;
  }
}
