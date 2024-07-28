package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;

// Contains all the mods related to skewing!

class NotesSkewXMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewX += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewX += currentValue;
  }
}

class NotesSkewYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    notesMod = true;
    holdsMod = true;
    strumsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
  {
    data.skewY += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewY += currentValue;
  }
}

class StrumSkewXMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewX += currentValue;
  }
}

class StrumSkewYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewY += currentValue;
  }
}
