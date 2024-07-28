package funkin.play.modchartSystem;

import funkin.play.notes.Strumline;
import funkin.play.notes.StrumlineNote;
import openfl.display.TriangleCulling;

// A custom class which contains additional information for special mods such as spiral holds, long holds, mathcutoff, etc
// Done so that it's tied to the strumNote itself as opposed to an arbitrary array somewhere (and so it can work if multiple strums are added like for 7K lol)
class StrumExtraData
{
  // If true, will make the sprites render in 3D space, kind of.
  public var threeD:Bool = false;

  public var useHazCullMode:Bool = true; // otherwise we get weird behaviour cuz drawTriangles sucks at it's job

  public var cullMode(default, set):String = "none";

  function set_cullMode(value:String):String
  {
    if (whichStrumNote?.mesh != null)
    {
      useHazCullMode ? whichStrumNote.mesh.hazCullMode = value : whichStrumNote.mesh.cullMode = value;
    }
    this.cullMode = value;
    return this.cullMode;
  }

  public var cullModeNotes(default, set):String = "none";

  function set_cullModeNotes(value:String):String
  {
    // if value changed...
    if (value != this.cullModeNotes && whichStrumNote != null)
    {
      this.cullModeNotes = value;
      whichStrumNote.weBelongTo.requestMeshCullUpdateForNotes(true);
    }
    else
    {
      this.cullModeNotes = value;
    }
    return this.cullModeNotes;
  }

  public var cullModeSustain(default, set):String = "none";

  function set_cullModeSustain(value:String):String
  {
    // if value changed...
    if (value != this.cullModeSustain && whichStrumNote != null)
    {
      this.cullModeSustain = value;
      whichStrumNote.weBelongTo.requestMeshCullUpdateForNotes(false);
    }
    else
    {
      this.cullModeSustain = value;
    }

    return this.cullModeSustain;
  }

  // Who we belong too, in case we need to reference it
  public var whichStrumNote:StrumlineNote;

  // Lower number = more detailed holds
  public var holdGrain:Float = 82;

  // Lower number = more detailed holds
  public var pathGrain:Float = 95;

  // multiplier on the drawdistance! Note that it acts like NotITG where 0 is default, 1 is double, -1 is mutliplied by 0 (no draw distance)
  public var drawdistanceForward:Float = 0;

  // multiplier on the drawdistance! Note that it acts like NotITG where 0 is default, 1 is double, -1 is mutliplied by 0 (no draw distance)
  public var drawdistanceBack:Float = 0;

  // If set to true, will alter how the hold is rendered (rotates the sustain to always face direction of travel)
  public var spiralHolds:Bool = false;

  // If set to true, will alter how the hold is rendered (rotates the sustain to always face direction of travel)
  public var spiralPaths:Bool = false;

  // Makes holds straight lol. negative makes them less straight FOR ARROW PATH
  public var arrowpathStraightHold:Float = 0;

  // Makes holds straight lol. negative makes them less straight
  public var straightHolds:Float = 0;

  // makes holds look longer then what they actually are
  public var longHolds:Float = 0;

  // If distance is equal or greater then the value set, then skip doing mod math! 0 or below means don't use this mod!
  public var mathCutOff:Float = 0;

  // lol
  public var noHoldMathShortcut:Float = 0;

  // so the angle can get undone for regular notes
  public var orientStrumAngle:Float = 0;
  public var orientExtraMath:Float = 0;

  // I errr, forgot. I think it's like strum curpos for drive2?
  public var strumPos:Float = 0;

  // The alpha of this lane's arrowpath. This is used so that at 0 or lower alpha, it doesn't do any math for optimisation
  public var arrowPathAlpha:Float = 0;
  public var arrowpathLength:Float = 1500;
  public var arrowpathBackwardsLength:Float = 400;
  public var alphaSplashMod:Float = 0;
  public var alphaHoldCoverMod:Float = 0;

  public function new(who:StrumlineNote)
  {
    whichStrumNote = who;
    reset();
  }

  public function reset():Void
  {
    mathCutOff = 0;
    drawdistanceForward = 0;
    drawdistanceBack = 0;

    holdGrain = 82;
    spiralHolds = false;
    straightHolds = 0;
    longHolds = 0;
    noHoldMathShortcut = 0;

    spiralPaths = false;
    pathGrain = 95;
    arrowPathAlpha = 0;
    arrowpathLength = 1500;
    arrowpathBackwardsLength = 400;
    arrowpathStraightHold = 0;

    orientStrumAngle = 0;
    orientExtraMath = 0;

    strumPos = 0;

    alphaHoldCoverMod = 0;
    alphaSplashMod = 0;
  }
}
