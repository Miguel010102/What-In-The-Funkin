package funkin.play.modchartSystem.modifiers;

import funkin.play.notes.Strumline;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.modifiers.BaseModifier;

// Contains all the mods related to skewing!

class PlayFieldSkewXMod extends Modifier
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
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.skewX_playfield += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewX_playfield += currentValue;
  }
}

class PlayFieldSkewYMod extends Modifier
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
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.skewY_playfield += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewY_playfield += currentValue;
  }
}

class PlayFieldSkewZMod extends Modifier
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
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.skewZ_playfield += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewZ_playfield += currentValue;
  }
}

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
    if (currentValue == 0 || data.noteType == "receptor") return;
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
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.skewY += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewY += currentValue;
  }
}

class NotesSkewZMod extends Modifier
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
    if (currentValue == 0 || data.noteType == "receptor") return;
    data.skewZ += currentValue;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewZ += currentValue;
  }
}

class HoldsSkewYMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    holdsMod = true;
    pathMod = true;
  }

  override function noteMath(data:NoteData, strumLine:Strumline, ?isHoldNote = false, ?isArrowPath:Bool = false):Void
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

class StrumSkewZMod extends Modifier
{
  public function new(name:String)
  {
    super(name, 0);
    unknown = false;
    strumsMod = true;
  }

  override function strumMath(data:NoteData, strumLine:Strumline):Void
  {
    data.skewZ += currentValue;
  }
}
