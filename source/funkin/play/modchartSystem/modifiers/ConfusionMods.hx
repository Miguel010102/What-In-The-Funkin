package funkin.play.modchartSystem.modifiers;

import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;

// Contains all the mods related to rotating the nots / strums!
// Notes spin as they approach the receptors
class DizzyMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || isArrowPath) return; // skip math if mod is 0
    data.angleZ += data.curPos_unscaled / 2.0 * currentValue;
  }
}

// Notes spin as they approach the receptors, not being affected by speed / distance mods
class Dizzy2Mod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || isArrowPath) return; // skip math if mod is 0
    data.angleZ += data.curPos / 2.0 * currentValue;
  }
}

// Notes spin as they approach the receptors
class RollMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || isArrowPath) return; // skip math if mod is 0
    data.angleX += data.curPos_unscaled / 2.0 * currentValue;
  }
}

// Notes spin as they approach the receptors, not being affected by speed / distance mods
class Roll2Mod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || isArrowPath) return; // skip math if mod is 0
    data.angleX += data.curPos / 2.0 * currentValue;
  }
}

// Notes spin as they approach the receptors
class TwirlMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || isArrowPath) return; // skip math if mod is 0
    data.angleY += data.curPos_unscaled / 2.0 * currentValue;
  }
}

// Notes spin as they approach the receptors, not being affected by speed / distance mods
class Twirl2Mod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (currentValue == 0 || isArrowPath) return; // skip math if mod is 0
    data.angleY += data.curPos / 2.0 * currentValue;
  }
}

// Notes and strums will rotate constantly
class ConfusionMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleZ += beatTime * currentValue; // lol, nobody uses this mod XD
  }
}

// Rotate the strums on the z axis
class ConfusionZOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleZ += currentValue;
  }
}

// Rotate the strums on the x axis
class ConfusionXOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || data.noteType == "receptor") return;
    data.angleX += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleX += currentValue;
  }
}

// Rotate the strums on the y axis
class ConfusionYOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    if (isArrowPath || data.noteType == "receptor") return;
    data.angleY += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.angleY += currentValue;
  }
}

// Rotate the notes on the z axis
class NotesConfusionZOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleZ += currentValue;
  }
}

// Rotate the notes on the x axis
class NotesConfusionXOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleX += currentValue;
  }
}

// Rotate the notes on the y axis
class NotesConfusionYOffsetMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.angleY += currentValue;
  }
}
