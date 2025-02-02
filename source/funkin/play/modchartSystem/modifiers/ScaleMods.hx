package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import flixel.math.FlxMath;

// Contains all the mods related to scale!
class ScaleModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX += currentValue;
    data.scaleY += currentValue;
    data.scaleZ += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX += currentValue;
    data.scaleY += currentValue;
    data.scaleZ += currentValue;
  }
}

class ScaleXModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX += currentValue;
  }
}

class ScaleYModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleY += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleY += currentValue;
  }
}

class ScaleZModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleZ += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleZ += currentValue;
  }
}

class ScaleStrumsModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX += currentValue;
    data.scaleY += currentValue;
    data.scaleZ += currentValue;
  }
}

class ScaleXStrumsModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX += currentValue;
  }
}

class ScaleYStrumsModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleY += currentValue;
  }
}

class ScaleNotesModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX += currentValue;
    data.scaleY += currentValue;
    data.scaleZ += currentValue;
  }
}

class ScaleXNotesModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX += currentValue;
  }
}

class ScaleYNotesModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleY += currentValue;
  }
}

class ScaleHoldsModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 3; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    if (isHoldNote)
    {
      data.scaleX += currentValue;
      data.scaleY += currentValue;
      data.scaleZ += currentValue;
    }
  }
}

// Not finished
class MiniModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 2; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue);
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue);
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue);
  }
}

// Contains all the mods related to scale!
class TinyModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    modPriority += 1; // apply before tiny
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue);
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue);
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue);
  }
}

class TinyXModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue);
  }
}

class TinyYModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue);
  }
}

class TinyZModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue);
  }
}

class TinyHoldsModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    if (isHoldNote)
    {
      data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue);
      data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue);
      data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue);
    }
  }
}

class TinyStrumModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue);
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue);
  }
}

class TinyStrumXModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue);
  }
}

class TinyStrumYModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue);
  }
}

class TinyStrumZModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    if (currentValue == 0) return;
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue);
  }
}

class TinyNotesModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue);
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue);
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue);
  }
}

class TinyNotesXModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleX = FlxMath.lerp(data.scaleX, 0.0, currentValue);
  }
}

class TinyNotesYModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleY = FlxMath.lerp(data.scaleY, 0.0, currentValue);
  }
}

class TinyNotesZModifier extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || currentValue == 0 || data.noteType == "receptor") return;
    data.scaleZ = FlxMath.lerp(data.scaleZ, 0.0, currentValue);
  }
}
