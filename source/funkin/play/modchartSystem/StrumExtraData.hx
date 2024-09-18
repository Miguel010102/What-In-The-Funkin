package funkin.play.modchartSystem;

import funkin.play.notes.Strumline;
import funkin.play.notes.StrumlineNote;
import openfl.display.TriangleCulling;
import lime.math.Vector4;

// A custom class which contains additional information for special mods such as spiral holds, long holds, mathcutoff, etc
// Done so that it's tied to the strumNote itself as opposed to an arbitrary array somewhere (and so it can work if multiple strums are added like for 7K lol)
class StrumExtraData
{
  // If true, will make the sprites render in 3D space, kind of.
  public var threeD:Bool = false;

  public var useHazCullMode:Bool = false;

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

  // THIS CLASS ALSO CONTAINS THE LOGIC AND FUNCTIONS REQUIRED FOR CUSTOM PATH MOD TO WORK!
  function calculatePathDistances(path:List<TimeVector>):Float
  {
    @:privateAccess
    var iterator_head = path.h;
    var val = iterator_head.item;
    iterator_head = iterator_head.next;
    var last = val;
    last.startDist = 0;
    var dist = 0.0;
    while (iterator_head != null)
    {
      var val = iterator_head.item;
      iterator_head = iterator_head.next;
      var current = val;
      var result = new Vector4();
      result.x = current.x - last.x;
      result.y = current.y - last.y;
      result.z = current.z - last.z;
      var differential = result;
      dist += Math.sqrt(differential.x * differential.x + differential.y * differential.y + differential.z * differential.z);
      current.startDist = dist;
      last.next = current;
      last.endDist = current.startDist;
      last = current;
    }
    return dist;
  }

  public function getPointAlongPath(distance:Float):TimeVector
  {
    @:privateAccess
    var _g_head = this._path.h;
    while (_g_head != null)
    {
      var val = _g_head.item;
      _g_head = _g_head.next;
      var vec = val;
      var Min = vec.startDist;
      var Max = vec.endDist;
      // looks like a FlxMath function could be that
      if ((Min == 0 || distance >= Min) && (Max == 0 || distance <= Max) && vec.next != null)
      {
        var ratio = distance - vec.startDist;
        var _this = vec.next;
        var result = new Vector4();
        result.x = _this.x - vec.x;
        result.y = _this.y - vec.y;
        result.z = _this.z - vec.z;
        var ratio1 = ratio / Math.sqrt(result.x * result.x + result.y * result.y + result.z * result.z);
        var vec2 = vec.next;
        var out1 = new Vector4(vec.x, vec.y, vec.z, vec.w);
        var s = 1 - ratio1;
        out1.x *= s;
        out1.y *= s;
        out1.z *= s;
        var out2 = new Vector4(vec2.x, vec2.y, vec2.z, vec2.w);
        out2.x *= ratio1;
        out2.y *= ratio1;
        out2.z *= ratio1;
        var result1 = new Vector4();
        result1.x = out1.x + out2.x;
        result1.y = out1.y + out2.y;
        result1.z = out1.z + out2.z;
        return new TimeVector(result1.x, result1.y, result1.z, result1.w);
      }
    }
    return _path.first();
  }

  public function executePath(currentBeat:Float, strumTimeDiff:Float, column:Int, modValue:Float, pos:Vector4):Vector4
  {
    if (_path == null)
    {
      return pos;
    }
    var path = getPointAlongPath(strumTimeDiff / -1500.0 * _pathDistance);
    // var a = new Vector4(FlxG.width / 2, FlxG.height / 2 + 280, column % 4 * getOtherPercent("arrowshapeoffset", player) + pos.z);
    var a = new Vector4(FlxG.width / 2, FlxG.height / 2 + 280, column % 4 * 1 + pos.z);
    var result = new Vector4();
    result.x = path.x + a.x;
    result.y = path.y + a.y;
    result.z = path.z + a.z;
    var vec2 = result;
    // var lerp = getPercent(player);
    var lerp = modValue;
    var out1 = new Vector4(pos.x, pos.y, pos.z, pos.w);
    var s = 1 - lerp;
    out1.x *= s;
    out1.y *= s;
    out1.z *= s;
    var out2 = new Vector4(vec2.x, vec2.y, vec2.z, vec2.w);
    out2.x *= lerp;
    out2.y *= lerp;
    out2.z *= lerp;
    var result = new Vector4();
    result.x = out1.x + out2.x;
    result.y = out1.y + out2.y;
    result.z = out1.z + out2.z;
    return result;
  }

  var _path:List<TimeVector> = null;
  var _pathDistance:Float = 0;

  public var customArrowPathModTest:String = null;

  public function formatCustomArrowPathData(d:String):Void
  {
    this.customArrowPathModTest = d;
    var file_part1 = funkin.util.FileUtil.readStringFromPath(customArrowPathModTest);

    var filePath:Array<String> = [];
    filePath = file_part1.trim().split('\n');

    for (i in 0...filePath.length)
    {
      filePath[i] = filePath[i].trim();
    }
    filePath.reverse(); // lmao, the points are reversed when used in my system
    loadCustomArrowPath(filePath);
  }

  public function loadCustomArrowPath(data:Array<String>):Void
  {
    if (data != null)
    {
      var path = new List<TimeVector>();
      var _g = 0;
      while (_g < data.length)
      {
        var line = data[_g];
        // trace("line: " + line);
        _g++;
        var coords = line.split(";");
        // trace((_g - 1) + "split: " + coords);
        var vec = new TimeVector(Std.parseFloat(coords[0]), Std.parseFloat(coords[1]) * (Preferences.downscroll ? -1 : 1), Std.parseFloat(coords[2]),
          Std.parseFloat(coords[3]));
        vec.x *= 200;
        vec.y *= 200;
        vec.z *= 200;
        path.add(vec);

        //  trace("x: " + vec.x);
        // trace("y: " + vec.y);
        // trace("z: " + vec.z);
        // trace("-------");
      }

      _pathDistance = calculatePathDistances(path);
      _path = path;
    }
    else
    {
      trace("nvm, file is fucked");
      customArrowPathModTest == null;
    }
  }
}

class TimeVector extends Vector4
{
  public var startDist:Float;
  public var endDist:Float;
  public var next:TimeVector;

  public function new(x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 0)
  {
    super(x, y, z, w);
    startDist = 0.0;
    endDist = 0.0;
    next = null;
  }
}
