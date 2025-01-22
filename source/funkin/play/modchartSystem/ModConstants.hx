package funkin.play.modchartSystem;

import flixel.FlxG;
import flixel.util.FlxColor;
// funkin stuff
import funkin.play.PlayState;
import funkin.Conductor;
import funkin.play.song.Song;
import funkin.Preferences;
import funkin.util.Constants;
import funkin.play.notes.Strumline;
import funkin.Paths;
import funkin.play.notes.NoteSprite;
import funkin.play.notes.StrumlineNote;
// Math and utils
import StringTools;
import flixel.util.FlxStringUtil;
import flixel.math.FlxMath;
import lime.math.Vector2;
import openfl.geom.Vector3D;
import flixel.math.FlxAngle;
import funkin.util.SortUtil;
import flixel.util.FlxSort;
// tween
import flixel.tweens.FlxTween;
// import flixel.tweens.FlxTweenManager;
import flixel.tweens.FlxEase;
// For holds
import funkin.graphics.FunkinSprite;
import flixel.FlxSprite;
import openfl.display.Sprite;
import funkin.graphics.ZSprite;
import funkin.play.modchartSystem.ModHandler;
import funkin.play.modchartSystem.HazardEase;
import lime.math.Vector4;
//
import openfl.display.BlendMode;
// I want to kill myself:
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.modifiers.ColumnMods;
import funkin.play.modchartSystem.modifiers.ConfusionMods;
import funkin.play.modchartSystem.modifiers.BeatMods;
import funkin.play.modchartSystem.modifiers.DrunkMods;
import funkin.play.modchartSystem.modifiers.MoveMods;
import funkin.play.modchartSystem.modifiers.SkewMods;
import funkin.play.modchartSystem.modifiers.SpeedMods;
import funkin.play.modchartSystem.modifiers.SpecialMods;
import funkin.play.modchartSystem.modifiers.DebugMods;
import funkin.play.modchartSystem.modifiers.RotateMods;
import funkin.play.modchartSystem.modifiers.ArrowpathMods;
import funkin.play.modchartSystem.modifiers.HoldMods;
import funkin.play.modchartSystem.modifiers.StealthMods;
import funkin.play.modchartSystem.modifiers.BumpyMods;
import funkin.play.modchartSystem.modifiers.ScaleMods;
import funkin.play.modchartSystem.modifiers.BounceMods;
import funkin.play.modchartSystem.modifiers.OffsetMods;
import funkin.play.modchartSystem.modifiers.LinearMods;
import funkin.play.modchartSystem.modifiers.CircMods;
import funkin.play.modchartSystem.modifiers.SpiralMods;
import funkin.play.modchartSystem.modifiers.SpiralCosMods;
import funkin.play.modchartSystem.modifiers.TipsyMods;
import funkin.play.modchartSystem.modifiers.TornadoMods;
import funkin.play.modchartSystem.modifiers.WaveyMods;
import funkin.play.modchartSystem.modifiers.ZigZagMods;
import funkin.play.modchartSystem.modifiers.SquareMods;
import funkin.play.modchartSystem.modifiers.DigitalMods;
import funkin.play.modchartSystem.modifiers.ColorTintMods;
import funkin.play.modchartSystem.modifiers.SawtoothMods;
import funkin.play.modchartSystem.modifiers.CosecantMods;
import funkin.play.modchartSystem.modifiers.ExtraMods;
import funkin.play.modchartSystem.modifiers.CullMods;
import funkin.play.modchartSystem.modifiers.GridFloorMods;
import funkin.play.modchartSystem.modifiers.CustomPathModifier;
import funkin.play.modchartSystem.modifiers.HourGlassMods;
import funkin.play.modchartSystem.modifiers.AngleMods;
import funkin.play.modchartSystem.modifiers.*; // if only you worked ;_;

class ModConstants
{
  public static var MODCHART_VERSION:String = "v0.8.0a";

  public static var tooCloseToCameraFix:Float = 0.975; // dumb fix for preventing freak out on z math or something

  // If a mod tag is in this array, it will automatically invert the mod value
  // Best to only use this for more simple modcharts.
  public static var dadInvert:Array<String> = [
    "rotatez",
    "rotatey",
    "drunk",
    "drunkangle",
    "drunkangley",
    "tipsy",
    "tipsyx",
    "beat",
    "beatangley",
    "beatangle",
    "confusionoffset",
    "bumpyx",
    "bumpyangle",
    "bumpyangley",
    "bouncex",
    "bounceangley",
    "bounceangle",
    "digital",
    "digitalangle",
    "digitalangley",
    "linearx",
    "circx",
    "twirl",
    "dizzy",
    "zigzag",
    "spiralx",
    "spiralcosx",
    "tandrunk",
    "square",
    "saw",
    "noteskewx"
  ];

  public static var hideSomeDebugBois:Array<String> = [
    "showsubmods",
    "showzerovalue",
    "debugx",
    "debugy",
    "arrowpathred",
    "arrowpathgreen",
    "arrowpathblue",
    "spiralholds",
    "grain",
    "arrowpathgrain",
    "pathgrain",
    "arrowpathlength",
    "arrowpathbacklength",
    "showlanemods",
    "showallmods",
    "showextra",
    "arrowpath_notitg",
    "stealthglowred",
    "stealthglowblue",
    "stealthglowgreen",
    "arrowpathwidth",
    "noholdmathshortcut",
    "mathcutoff"
  ];

  public static var specialMods:Array<String> = [
    "showsubmods",
    "showzerovalue",
    "debugx",
    "debugy",
    "showlanemods",
    "showallmods",
    "showextra",
    "noholdmathshortcut",
    "invertmodvalues",
    "mathcutoff",
    "strumx",
    "strumy",
    "strumz",
    "zsort",
    "drive2",
    "spiralholds",
    "grain",
    "arrowpath",
    "arrowpath_notitg",
    "arrowpathbacklength",
    "arrowpathlength",
    "arrowpathgrain",
    "pathgrain",
    "zsort",
    "invertmodvalues",
    "drawdistance",
    "drawdistanceback",
    "straightholds",
    "longholds",
    "strumx",
    "strumy",
    "strumz"
  ];

  // Was going to use this for sorting out the new mod arrays (from mods_sorted to the new method).
  // Ended up just making them get dynamically added by testing if the mod math does anything cuz I was too lazy to make sure this is correct XD
  /*
    public static var noteMods:Array<String> = [
      "speedmod", "alphahold", "alphanote", "alpha", "stealth", "sudden", "hidden", "vanish", "blink", "tinyx", "tinyy", "tiny", "dizzy", "drunky", "drunk",
      "drunkz", "drunkangle", "drunkscale", "square", "squarey", "squarez", "squareangle", "squarescale", "saw", "sawy", "sawz", "sawspeed", "reverse",
      "spiralx", "spiraly", "spiralz", "tantornadoz", "tantornado", "tandrunk", "tandrunky", "tandrunkz", "tandrunkangle", "tandrunkscale", "beaty", "beatz",
      "beatangle", "beatscale", "beat", "confusionoffset", "confusion", "blacksphereflip", "blacksphere", "noteskewx", "tanbumpy", "tanbumpyy", "tanbumpyx",
      "tanbumpyangle", "tanbumpyscale", "bumpyx", "bumpyy", "bumpyz", "bumpy", "bumpyangle","bumpyangle", "bouncex", "bouncey", "bouncez", "bouncescale", "bounceangle",
      "digital", "digitaly", "digitalz", "digitalangle", "digitalscale"
    ];

    public static var strumMods:Array<String> = [
      "speedmod", "strumx", "strumy", "strumz", "x", "y", "z", "movex", "movey", "movez", "showsubmods", "showzerovalue", "drawdistance", "drawdistanceback",
      "debugx", "debugy", "grain", "spiralholds", "longholds", "straightholds", "alpha", "alphastrum", "dark", "drunk", "tinyx", "tinyy", "tiny", "tinystrum",
      "tinystrumy", "tinystrumx", "mini", "reverse", "drive", "centered", "square", "squarey", "squarez", "squarescale", "squareangle", "tantornadoz",
      "tantornado", "tandrunk", "tandrunky", "tandrunkz", "tandrunkangle", "tandrunkscale", "beaty", "beatz", "beatangle", "beatscale", "beat", "tantipsy",
      "tipsy", "tipsyx", "tipsyz", "tantipsyx", "tantipsyz", "tipsyangle", "tipsyscale", "confusionoffset", "confusion", "flip", "invert", "videogames",
      "blacksphereflip", "blacksphere", "waveyangle", "waveyx", "waveyscale", "waveyy", "waveyz", "strumrotatex", "strumrotatey", "strumrotatez", "noteskewx"
    ];

    public static var arrowPathMods:Array<String> = [
      "speedmod",
      "arrowpathgrain",
      "arrowpathstraighthold",
      "arrowpathred",
      "arrowpathgreen",
      "arrowpathblue",
      "arrowpathwidth",
      "arrowpath", "noteskewx"
    ];
   */
  // keep same as strumline, dumb fix for mfweanfwaionfwayuodwao
  public static final STRUMLINE_SIZE:Int = 104;
  public static final NOTE_SPACING:Int = STRUMLINE_SIZE + 8;
  public static final INITIAL_OFFSET = -0.275 * STRUMLINE_SIZE;

  // Sets the REAL hold note to this position - X.
  public static var holdNoteJankX:Float = 0;

  // Sets the REAL hold note to this position - Y.
  public static var holdNoteJankY:Float = 0;

  // size in pixels for each note
  public static var strumSize:Float = 112;

  // arrowpathScale
  public static var arrowPathScale:Float = (0.696774193548387 * 0.25);

  // the scale of each note, idfk lol
  public static var noteScale:Float = 0.696774193548387;

  // Just a silly way to check if a tag is actually a submod or not lol
  public static function isTagSub(tag:String):Bool
  {
    return StringTools.contains(tag, "__");
  }

  public static function blendModeFromString(blend:String):BlendMode
  {
    switch (blend.toLowerCase().trim())
    {
      case 'add':
        return ADD;
      case 'alpha':
        return ALPHA;
      case 'darken':
        return DARKEN;
      case 'difference':
        return DIFFERENCE;
      case 'erase':
        return ERASE;
      case 'hardlight':
        return HARDLIGHT;
      case 'invert':
        return INVERT;
      case 'layer':
        return LAYER;
      case 'lighten':
        return LIGHTEN;
      case 'multiply':
        return MULTIPLY;
      case 'overlay':
        return OVERLAY;
      case 'screen':
        return SCREEN;
      case 'shader':
        return SHADER;
      case 'subtract':
        return SUBTRACT;
    }
    return NORMAL;
  }

  public static function getDefaultStrumPosition(strumLine:Strumline, lane:Float):Vector3D
  {
    var strumBaseX:Float = strumLine.x + Strumline.INITIAL_OFFSET + (lane * Strumline.NOTE_SPACING);
    var strumBaseY:Float = strumLine.y;
    var strumBaseZ:Float = 0;

    @:privateAccess
    var strumlineOffsets = strumLine.noteStyle.getStrumlineOffsets();
    strumBaseX += strumlineOffsets[0];
    strumBaseY += strumlineOffsets[1];

    var wasHereOriginally:Vector3D = new Vector3D(strumBaseX, strumBaseY, strumBaseZ);
    return wasHereOriginally;
  }

  public static function rotateAround(origin:Vector2, point:Vector2, degrees:Float):Vector2
  {
    // public function rotateAround(origin, point, degrees):FlxBasePoint{
    // public function rotateAround(origin, point, degrees){
    var angle:Float = degrees * (Math.PI / 180);
    var ox = origin.x;
    var oy = origin.y;
    var px = point.x;
    var py = point.y;

    var qx = ox + FlxMath.fastCos(angle) * (px - ox) - FlxMath.fastSin(angle) * (py - oy);
    var qy = oy + FlxMath.fastSin(angle) * (px - ox) + FlxMath.fastCos(angle) * (py - oy);

    // point.x = qx;
    // point.y = qy;

    return (new Vector2(qx, qy));
    // return FlxBasePoint.weak(qx, qy);
    // return qx, qy;
  }

  public static function modAliasCheck(tag:String):String
  {
    var modName:String = tag.toLowerCase();

    // Remove all spaces!
    modName = StringTools.replace(modName, " ", "");

    // trace("in goes: " + modName);

    modName = StringTools.replace(modName, "rotx", "rotatex");
    modName = StringTools.replace(modName, "roty", "rotatey");
    modName = StringTools.replace(modName, "rotz", "rotatez");
    modName = StringTools.replace(modName, "rotationx", "rotatex");
    modName = StringTools.replace(modName, "rotationy", "rotatey");
    modName = StringTools.replace(modName, "rotationz", "rotatez");

    modName = StringTools.replace(modName, "cosspiral", "spiralcos");

    modName = StringTools.replace(modName, "confusionzoffset", "confusionoffset");

    if (modName == "anglez")
    {
      modName = "angle";
    }
    else if (modName == "noteangle")
    {
      modName = "notesangle";
    }
    else if (modName == "notesanglez")
    {
      modName = "notesangle";
    }
    else if (modName == "noteanglez")
    {
      modName = "notesangle";
    }
    else if (modName == "noteangley")
    {
      modName = "notesangley";
    }
    else if (modName == "noteanglex")
    {
      modName = "notesanglex";
    }
    modName = StringTools.replace(modName, "scaleholds", "scalehold");
    modName = StringTools.replace(modName, "scalestrums", "scalestrum");
    modName = StringTools.replace(modName, "scalenotes", "scalenote");

    modName = StringTools.replace(modName, "tinyholds", "tinyhold");

    modName = StringTools.replace(modName, "sawx", "saw");
    modName = StringTools.replace(modName, "sawtooth", "saw");
    modName = StringTools.replace(modName, "sawtoothx", "saw");
    modName = StringTools.replace(modName, "sawtoothy", "sawy");
    modName = StringTools.replace(modName, "sawtoothz", "sawz");
    modName = StringTools.replace(modName, "sawtoothscale", "sawscale");
    modName = StringTools.replace(modName, "sawtoothangle", "sawangle");

    modName = StringTools.replace(modName, "zigzagx", "zigzag");
    modName = StringTools.replace(modName, "tri", "zigzag");
    modName = StringTools.replace(modName, "trix", "zigzag");
    modName = StringTools.replace(modName, "triy", "zigzagy");
    modName = StringTools.replace(modName, "triz", "zigzagz");

    modName = StringTools.replace(modName, "holdgrain", "grain");
    modName = StringTools.replace(modName, "arrowpathgrain", "pathgrain");

    modName = StringTools.replace(modName, "cullholds", "cullsustain");
    modName = StringTools.replace(modName, "cullhold", "cullsustain");
    modName = StringTools.replace(modName, "cullarrowpaths", "cullpath");
    modName = StringTools.replace(modName, "cullarrowpath", "cullpath");

    modName = StringTools.replace(modName, "stealthred", "stealthglowred");
    modName = StringTools.replace(modName, "stealthgreen", "stealthglowgreen");
    modName = StringTools.replace(modName, "stealthblue", "stealthglowblue");

    modName = StringTools.replace(modName, "stealthstrum", "strumstealth");
    modName = StringTools.replace(modName, "stealthreceptor", "strumstealth");
    modName = StringTools.replace(modName, "receptorstealth", "strumstealth");

    modName = StringTools.replace(modName, "small", "tiny");

    modName = StringTools.replace(modName, "scrollspeedmult", "speedmod");

    modName = StringTools.replace(modName, "showzerovaluemods", "showzerovalue");
    modName = StringTools.replace(modName, "debugshowzeromods", "showzerovalue");
    modName = StringTools.replace(modName, "debugshowzerovaluemods", "showzerovalue");

    modName = StringTools.replace(modName, "debugshowsubmods", "showsubmods");
    modName = StringTools.replace(modName, "debugshowsubvaluemods", "showsubmods");
    modName = StringTools.replace(modName, "showsubvaluemods", "showsubmods");
    modName = StringTools.replace(modName, "showsubmodvaluemods", "showsubmods");

    modName = StringTools.replace(modName, "debugshowlanemods", "showlanemods");

    modName = StringTools.replace(modName, "debugshowallmods", "showallmods");
    modName = StringTools.replace(modName, "debugshoweverything", "showallmods");

    modName = StringTools.replace(modName, "hidesome", "showextra");
    modName = StringTools.replace(modName, "debughidesome", "showextra");
    modName = StringTools.replace(modName, "showutlity", "showextra");
    modName = StringTools.replace(modName, "showutility", "showextra");
    modName = StringTools.replace(modName, "showdebugextra", "showextra");
    modName = StringTools.replace(modName, "debugshowutility", "showextra");

    modName = StringTools.replace(modName, "debugoffsetx", "debugx");
    modName = StringTools.replace(modName, "debugoffsety", "debugy");

    modName = StringTools.replace(modName, "disableholdmathshortcut", "noholdmathshortcut");

    modName = StringTools.replace(modName, "notepath", "arrowpath");
    modName = StringTools.replace(modName, "arrowpath_notitgstyled", "arrowpath_notitg");
    modName = StringTools.replace(modName, "arrowpath_line", "arrowpath_notitg");
    modName = StringTools.replace(modName, "arrowpath_lined", "arrowpath_notitg");
    modName = StringTools.replace(modName, "arrowpath_linestyle", "arrowpath_notitg");
    modName = StringTools.replace(modName, "arrowpath_trueline", "arrowpath_notitg");

    modName = StringTools.replace(modName, "arrowpathsize", "arrowpathwidth");
    modName = StringTools.replace(modName, "arrowpathstraightholds", "arrowpathstraighthold");
    modName = StringTools.replace(modName, "arrowpathstraight", "arrowpathstraighthold");
    modName = StringTools.replace(modName, "arrowpathfrontlength", "arrowpathlength");

    modName = StringTools.replace(modName, "centered", "center");
    modName = StringTools.replace(modName, "centere", "center");
    modName = StringTools.replace(modName, "alwayscenter", "center2");

    modName = StringTools.replace(modName, "circanglez", "circangle");

    modName = StringTools.replace(modName, "bumpyz", "bumpy");

    modName = StringTools.replace(modName, "tornadox", "tornado");
    modName = StringTools.replace(modName, "hourglassx", "hourglass");

    modName = StringTools.replace(modName, "beatx", "beat");

    modName = StringTools.replace(modName, "squarex", "square");

    modName = StringTools.replace(modName, "drunkx", "drunk");
    modName = StringTools.replace(modName, "tandrunkx", "tandrunk");

    modName = StringTools.replace(modName, "tipsyy", "tipsy");
    modName = StringTools.replace(modName, "tantipsyy", "tantipsy");

    modName = StringTools.replace(modName, "waveystrum", "wavey");

    modName = StringTools.replace(modName, "blacksphere_flip", "blacksphereflip");

    modName = StringTools.replace(modName, "alphanotes", "alphanote");
    modName = StringTools.replace(modName, "alphaholds", "alphahold");
    modName = StringTools.replace(modName, "alphareceptor", "alphastrum");
    modName = StringTools.replace(modName, "alphareceptors", "alphastrum");
    modName = StringTools.replace(modName, "alphastrums", "alphastrum");

    modName = StringTools.replace(modName, "drawsize", "drawdistance");
    modName = StringTools.replace(modName, "renderdistance", "drawdistance");

    modName = StringTools.replace(modName, "renderdistanceforward", "drawdistance");
    modName = StringTools.replace(modName, "drawdistanceforward", "drawdistance");
    modName = StringTools.replace(modName, "renderdistanceforwards", "drawdistance");
    modName = StringTools.replace(modName, "drawdistanceforwards", "drawdistance");

    modName = StringTools.replace(modName, "drawdistancebackwards", "drawdistanceback");
    modName = StringTools.replace(modName, "renderdistancebackwards2", "drawdistanceback");
    modName = StringTools.replace(modName, "renderdistancebackwards", "drawdistanceback");
    modName = StringTools.replace(modName, "renderdistanceback", "drawdistanceback");

    modName = StringTools.replace(modName, "tinyholds", "tinyhold");

    modName = StringTools.replace(modName, "attenuatex", "attenuate");

    modName = StringTools.replace(modName, "threed", "3d");
    modName = StringTools.replace(modName, "3drenderer", "3d");
    modName = StringTools.replace(modName, "3dprojection", "3d");

    // trace("out goes: " + modName);

    return modName;
  }

  public static function invertValueCheck(tag:String, invertValues:Bool):Float
  {
    return (ModConstants.dadInvert.contains(tag) && invertValues) ? -1.0 : 1.0;
  }

  public static function getEaseFromString(str:String = "linear"):Null<Float->Float>
  {
    // return Reflect.field(FlxEase, str);
    // return Reflect.field(HazardEase, str);

    // dumb fix for reflect not seeing the default flxease stuff in the new hazardease class
    switch (str)
    {
      case "linear":
        return FlxEase.linear;

      case "sineIn":
        return FlxEase.sineIn;
      case "sineOut":
        return FlxEase.sineOut;
      case "sineInOut":
        return FlxEase.sineInOut;

      case "circOut":
        return FlxEase.circOut;
      case "circIn":
        return FlxEase.circIn;
      case "circInOut":
        return FlxEase.circInOut;

      case "quadInOut":
        return FlxEase.quadInOut;
      case "quadIn":
        return FlxEase.quadIn;
      case "quadOut":
        return FlxEase.quadOut;

      case "cubeIn":
        return FlxEase.cubeIn;
      case "cubeOut":
        return FlxEase.cubeOut;
      case "cubeInOut":
        return FlxEase.cubeInOut;

      case "quintInOut":
        return FlxEase.quintInOut;
      case "quintIn":
        return FlxEase.quintIn;
      case "quintOut":
        return FlxEase.quintOut;

      case "expoOut":
        return FlxEase.expoOut;
      case "expoIn":
        return FlxEase.expoIn;
      case "expoInOut":
        return FlxEase.expoInOut;

      case "backOut":
        return FlxEase.backOut;
      case "backIn":
        return FlxEase.backIn;
      case "backInOut":
        return FlxEase.backInOut;

      case "bounceOut":
        return FlxEase.bounceOut;
      case "bounceIn":
        return FlxEase.bounceIn;
      case "bounceInOut":
        return FlxEase.bounceInOut;

      case "elasticOut":
        return FlxEase.elasticOut;
      case "elasticIn":
        return FlxEase.elasticIn;
      case "elasticInOut":
        return FlxEase.elasticInOut;

      case "quartIn":
        return FlxEase.quartIn;
      case "quartInOut":
        return FlxEase.quartInOut;
      case "quartOut":
        return FlxEase.quartOut;

      case "smootherStepOut":
        return FlxEase.smootherStepOut;
      case "smootherStepIn":
        return FlxEase.smootherStepIn;
      case "smootherStepInOut":
        return FlxEase.smootherStepInOut;

      case "smoothStepIn":
        return FlxEase.smoothStepIn;
      case "smoothStepOut":
        return FlxEase.smoothStepOut;
      case "smoothStepInOut":
        return FlxEase.smoothStepInOut;

      default:
        /*
          var tag_:String = str.toLowerCase();
          var subModArr = null;
          if (StringTools.contains(tag_, "flip("))
          {
            var subModArr_part1 = tag_.split('(');
            var subModArr_part2 = subModArr_part1[1].split(')');
            str = subModArr_part2[0];

            tag_ = subModArr[0];
            lane = Std.parseInt(subModArr[1]);
          }
         */

        return Reflect.field(HazardEase, str);
    }
  }

  public static function modTag(tag:String = "drunk", target:ModHandler = null):String
  {
    var stringReturn = "unknown";

    if (target.customTweenerName == "???")
    {
      if (target == PlayState.instance.playerStrumline.mods)
      {
        stringReturn = "player";
      }
      else if (target == PlayState.instance.opponentStrumline.mods)
      {
        stringReturn = "opponent";
      }
    }
    else
    {
      stringReturn = target.customTweenerName;
    }

    stringReturn += "." + tag;
    return stringReturn;
  }

  public static function grabStrumModTarget(playerTarget:String = "bf"):ModHandler
  {
    var modsTarget:ModHandler = PlayState.instance.playerStrumline.mods;
    if (playerTarget == "dad" || playerTarget == "opponent" || playerTarget == "2")
    {
      modsTarget = PlayState.instance.opponentStrumline.mods;
      return modsTarget;
    }
    else if (playerTarget == "bf" || playerTarget == "boyfriend" || playerTarget == "1")
    {
      modsTarget = PlayState.instance.playerStrumline.mods;
      return modsTarget;
    }

    var k:Null<Int> = Std.parseInt(playerTarget);
    if (k != null)
    {
      k -= 1; // offset so it starts at player 1 instead of player 0.
      if (k > 0 && k < PlayState.instance.allStrumLines.length)
      {
        modsTarget = PlayState.instance.allStrumLines[k].mods;
        return modsTarget;
      }
    }

    PlayState.instance.modDebugNotif("Player '" + playerTarget + "' not found! Defaulting to BF.", FlxColor.ORANGE);

    return modsTarget;
  }

  // from Modcharting-Tools lol
  public static function getTimeFromBeat(beat:Float, conductor:Conductor = null):Float
  {
    if (conductor == null) conductor = Conductor.instance;

    if (beat <= 0) // Update v0.7.3a -> Allows for tweens to function before the song has begun!
    {
      var timmy:Float = 0;
      timmy = beat / (conductor.bpm / 60);
      timmy *= 1000;
      // trace(timmy);
      return timmy;
    }

    var totalTime:Float = 0;
    var curBpm = conductor.bpm;
    // if (PlayState.SONG != null)
    //    curBpm = PlayState.SONG.bpm;
    for (i in 0...Math.floor(beat))
    {
      if (conductor.timeChanges.length > 0)
      {
        for (j in 0...conductor.timeChanges.length)
        {
          if (totalTime >= conductor.timeChanges[j].timeStamp) curBpm = conductor.timeChanges[j].bpm;
        }
      }
      totalTime += (60 / curBpm) * 1000;
    }

    var leftOverBeat = beat - Math.floor(beat);
    totalTime += (60 / curBpm) * 1000 * leftOverBeat;

    // trace(totalTime);
    return totalTime;
  }

  // Call this on a ZSprite to apply it's perspective! MAKE SURE IT'S SCALE AND X AND Y IS RESET BEFORE DOING THIS CUZ THIS OVERRIDES THOSE VALUES
  public static function applyPerspective(note:ZSprite, ?noteWidth:Float, ?noteHeight:Float):Void
  {
    // try
    // {
    if (noteWidth == null) noteWidth = note.width;
    if (noteHeight == null) noteHeight = note.height;

    var pos:Vector3D = new Vector3D(note.x + (noteWidth / 2), note.y + (noteHeight / 2), note.z * 0.001);

    var thisNotePos:Vector3D = perspectiveMath_OLD(pos, -(noteWidth * 0.5), -(noteHeight * 0.5));

    // var pos:Vector4 = new Vector4(note.x + (noteWidth / 2), note.y + (noteHeight / 2), note.z * 0.001, 0.0);
    // var thisNotePos:Vector4 = perspectiveMath(pos);

    note.x = thisNotePos.x;
    note.y = thisNotePos.y;

    var noteScaleX = note.scale.x;
    var noteScaleY = note.scale.y;
    // if (thisNotePos.z * -1 != 0)
    if (thisNotePos.z != 0)
    {
      noteScaleY *= (1 / -thisNotePos.z);
      noteScaleX *= (1 / -thisNotePos.z);
    }

    note.scale.set(noteScaleX, noteScaleY);

    // for z sorting lol
    // note.zIndex = note.z * -1;
    // }
    // catch (e)
    // {
    //  trace("OH GOD OH FUCK IT NEARLY DIED CUZ OF: " + e.toString());
    // }
  }

  public static function fastTan(rad:Float):Float
  {
    return FlxMath.fastSin(rad) / FlxMath.fastCos(rad);
  }

  public static var zNear:Float = 0.0;
  public static var zFar:Float = 100.0;
  public static var FOV:Float = 90.0; // FOR SOME REASON, MATH BREAK IF NOT 90. WTF?

  // lol? https://github.com/4mbr0s3-2/Schmovin/blob/main/note_mods/NoteModPerspective.hx
  public static function perspectiveMath(pos:Vector4):Vector4
  {
    try
    {
      var fov:Float = FOV;
      fov *= (Math.PI / 180.0);
      var screenRatio = 1;
      var near = zNear;
      var far = zFar;

      var screenRatio = 1;

      var outPos = pos.clone();
      var halfScreenOffset = new Vector4(FlxG.width / 2, FlxG.height / 2);

      var perspectiveZ = outPos.z - 1;
      if (perspectiveZ > 0) perspectiveZ = 0; // To prevent coordinate overflow :/

      var x = outPos.x / fastTan(fov / 2);
      var y = outPos.y * screenRatio / fastTan(fov / 2);

      var a = (near + far) / (near - far);
      var b = 2 * near * far / (near - far);
      var z = a * perspectiveZ + b;

      return new Vector4(x / z, y / z, z, outPos.w).add(halfScreenOffset);
    }
    catch (e)
    {
      trace("OH GOD OH FUCK IT NEARLY DIED CUZ OF: \n" + e.toString());
      return pos;
    }
  }

  // https://github.com/TheZoroForce240/FNF-Modcharting-Tools/blob/main/source/modcharting/ModchartUtil.hx
  public static function perspectiveMath_OLD(pos:Vector3D, offsetX:Float = 0, offsetY:Float = 0):Vector3D
  {
    // TODO - REDO THIS MATH! CRASHES FOR SUSTAINS FOR SOME REASON AND ALSO DOESN'T WORK IF ANY OF THE VARIABLES CHANGE (LIKE FOV, ZNEAR, ZFAR, ETC)
    try
    {
      var _FOV:Float = ModConstants.FOV;

      _FOV *= (Math.PI / 180.0);

      /* math from opengl lol
        found from this website https://ogldev.org/www/tutorial12/tutorial12.html
       */

      var newz:Float = pos.z;
      // Too close to camera!
      if (newz > zNear + ModConstants.tooCloseToCameraFix)
      {
        newz = zNear + ModConstants.tooCloseToCameraFix;
      }
      // else if (newz < (zFar * -1)) // Too far from camera!
      // {
      //  culled = true;
      // }
      newz = newz - 1;

      var zRange:Float = zNear - zFar;
      // var tanHalfFOV:Float = Math.tan(_FOV * 0.5 * (Math.PI / 180.0));

      var tanHalfFOV:Float = FlxMath.fastSin(_FOV * 0.5) / FlxMath.fastCos(_FOV * 0.5);

      // if (pos.z > 1) // if above 1000 z basically
      //  newz = 0; // should stop weird mirroring with high z values

      // var m00 = 1/(tanHalfFOV);
      // var m11 = 1/tanHalfFOV;
      // var m22 = (-zNear - zFar) / zRange; //isnt this just 1 lol
      // var m23 = 2 * zFar * zNear / zRange;
      // var m32 = 1;

      var xOffsetToCenter:Float = pos.x - (FlxG.width * 0.5); // so the perspective focuses on the center of the screen
      var yOffsetToCenter:Float = pos.y - (FlxG.height * 0.5);

      var zPerspectiveOffset:Float = (newz + (2 * zFar * zNear / zRange));

      // divide by zero check
      if (zPerspectiveOffset == 0) zPerspectiveOffset = 0.001;

      // xOffsetToCenter += (offsetX / (1/-zPerspectiveOffset));
      // yOffsetToCenter += (offsetY / (1/-zPerspectiveOffset));
      xOffsetToCenter += (offsetX * -zPerspectiveOffset);
      yOffsetToCenter += (offsetY * -zPerspectiveOffset);

      xOffsetToCenter += (0 * -zPerspectiveOffset);
      yOffsetToCenter += (0 * -zPerspectiveOffset);

      var xPerspective:Float = xOffsetToCenter * (1 / tanHalfFOV);
      var yPerspective:Float = yOffsetToCenter * tanHalfFOV;
      xPerspective /= -zPerspectiveOffset;
      yPerspective /= -zPerspectiveOffset;

      pos.x = xPerspective + (FlxG.width * 0.5); // offset it back to normal
      pos.y = yPerspective + (FlxG.height * 0.5);
      pos.z = zPerspectiveOffset;

      // pos.z -= 1;
      // pos = perspectiveMatrix.transformVector(pos);

      return pos;
    }
    catch (e)
    {
      trace("OH GOD OH FUCK IT NEARLY DIED CUZ OF: \n" + e.toString());
      return pos;
    }
  }

  public static function createNewCustomMod(name:String, defaultBaseValue:Float = 0):CustomModifier
  {
    var modName:String = name.toLowerCase();

    // check if the name is okay to use
    var testIfModAlreadyExists:Modifier = createNewMod(modName, false);
    if (!testIfModAlreadyExists.fuck || ModConstants.isTagSub(modName))
    {
      if (PlayState.instance != null) PlayState.instance.modDebugNotif(name + " is not a valid mod name", FlxColor.RED);
      else
        trace(name + " is not a valid mod name ");
      return null;
    }

    var newMod:CustomModifier = new CustomModifier(modName, defaultBaseValue);
    return newMod;
  }

  // Use this to get
  public static function createNewMod(name:String, notif:Bool = true):Modifier
  {
    var tag:String = name.toLowerCase();
    var tag_:String = tag;
    var subModArr = null;
    var lane:Int = -1;
    if (StringTools.contains(tag_, "--"))
    {
      subModArr = tag_.split('--');
      tag_ = subModArr[0];
      lane = Std.parseInt(subModArr[1]);
    }

    var newMod:Modifier;
    // lmfao
    switch (tag_)
    {
      // special mods
      case "custompath":
        newMod = new CustomPathMod(tag);
      case "orient":
        newMod = new OrientMod(tag);
      case "zsort":
        newMod = new ZSortMod(tag);
      case "3d":
        newMod = new ThreeDProjection(tag);
      case "cull":
        newMod = new CullAllModifier(tag);
      case "cullsustain":
        newMod = new CullSustainModifier(tag);
      case "cullstrum":
        newMod = new CullStrumModifier(tag);
      case "cullnote":
        newMod = new CullNotesModifier(tag);
      case "cullpath":
        newMod = new CullArrowPathModifier(tag);

      case "bangarang":
        newMod = new BangarangMod(tag);
      case "mathcutoff":
        newMod = new MathCutOffMod(tag);
      case "noholdmathshortcut":
        newMod = new DisableHoldMathShortCutMod(tag);
      case "invertmodvalues":
        newMod = new InvertModValues(tag);
      case "drawdistanceback":
        newMod = new DrawDistanceBackMod(tag);
      case "drawdistance":
        newMod = new DrawDistanceMod(tag);

      // hold mods
      case "old3dholds":
        newMod = new Old3DHoldsMod(tag);
      case "spiralholds":
        newMod = new SpiralHoldsMod(tag);
      case "longholds":
        newMod = new LongHoldsMod(tag);
      case "straightholds":
        newMod = new StraightHoldsMod(tag);
      case "grain":
        newMod = new HoldGrainMod(tag);

      // speed mods
      case "speed" | "speedmod": // forgot the name lol
        newMod = new SpeedMod(tag);
      case "slowdown":
        newMod = new SlowDownMod(tag);
      case "brake":
        newMod = new BrakeMod(tag);
      case "boost":
        newMod = new BoostMod(tag);
      case "wave":
        newMod = new WaveMod(tag);
      case "reverse":
        newMod = new ReverseMod(tag);

      // column mods
      case "invert":
        newMod = new InvertMod(tag);
      case "flip":
        newMod = new FlipMod(tag);
      case "videogames":
        newMod = new VideoGamesMod(tag);
      case "blacksphereflip":
        newMod = new BlackSphereFlipMod(tag);
      case "blacksphere":
        newMod = new BlackSphereInvertMod(tag);

      // move mods
      case "movex":
        newMod = new MoveXMod(tag);
      case "movey":
        newMod = new MoveYMod(tag);
      case "moveyd":
        newMod = new MoveYDMod(tag);
      case "movez":
        newMod = new MoveZMod(tag);

      case "strumx":
        newMod = new StrumXMod(tag);
      case "strumy":
        newMod = new StrumYMod(tag);
      // case "strumyd":
      //  newMod = new StrumYDMod(tag);
      case "strumz":
        newMod = new StrumZMod(tag);

      case "x":
        newMod = new MoveXMod_true(tag);
      case "y":
        newMod = new MoveYMod_true(tag);
      case "yd":
        newMod = new MoveYDMod_true(tag);
      case "z":
        newMod = new MoveZMod_true(tag);

      case "centerx":
        newMod = new CenteredXMod(tag);
      case "center2":
        newMod = new AlwaysCenterMod(tag);
      case "center":
        newMod = new CenteredMod(tag);
      case "centernotes":
        newMod = new CenteredNotesMod(tag);
      case "drive":
        newMod = new DriveMod(tag);
      case "drive2":
        newMod = new Drive2Mod(tag);
      case "jump":
        newMod = new JumpMod(tag);

      // skew mods
      case "noteskewx":
        newMod = new NotesSkewXMod(tag);
      case "noteskewy":
        newMod = new NotesSkewYMod(tag);
      case "strumskewx":
        newMod = new StrumSkewXMod(tag);
      case "strumskewy":
        newMod = new StrumSkewYMod(tag);

      // scale mods
      case "scale":
        newMod = new ScaleModifier(tag);
      case "scalex":
        newMod = new ScaleXModifier(tag);
      case "scaley":
        newMod = new ScaleYModifier(tag);
      case "scalez":
        newMod = new ScaleZModifier(tag);

      case "scalestrum":
        newMod = new ScaleStrumsModifier(tag);
      case "scalestrumx":
        newMod = new ScaleXStrumsModifier(tag);
      case "scalestrumy":
        newMod = new ScaleYStrumsModifier(tag);

      case "scalenote":
        newMod = new ScaleNotesModifier(tag);
      case "scalenotex":
        newMod = new ScaleXNotesModifier(tag);
      case "scalenotey":
        newMod = new ScaleYNotesModifier(tag);
      case "scalehold":
        newMod = new ScaleHoldsModifier(tag);

      case "tiny":
        newMod = new TinyModifier(tag);
      case "tinyhold":
        newMod = new TinyHoldsModifier(tag);
      case "tinystrum":
        newMod = new TinyStrumModifier(tag);
      case "tinynote":
        newMod = new TinyNotesModifier(tag);
      case "tinynotex":
        newMod = new TinyNotesXModifier(tag);
      case "tinynotey":
        newMod = new TinyNotesYModifier(tag);
      case "tinynotez":
        newMod = new TinyNotesZModifier(tag);
      case "tinystrumx":
        newMod = new TinyStrumXModifier(tag);
      case "tinystrumy":
        newMod = new TinyStrumYModifier(tag);
      case "tinystrumz":
        newMod = new TinyStrumZModifier(tag);
      case "tinyx":
        newMod = new TinyXModifier(tag);
      case "tinyy":
        newMod = new TinyYModifier(tag);
      case "tinyz":
        newMod = new TinyZModifier(tag);

      // confusion mods
      case "confusion":
        newMod = new ConfusionMod(tag);
      case "confusionoffset":
        newMod = new ConfusionZOffsetMod(tag);
      case "confusionyoffset":
        newMod = new ConfusionYOffsetMod(tag);
      case "confusionxoffset":
        newMod = new ConfusionXOffsetMod(tag);

      case "notesconfusionoffset":
        newMod = new NotesConfusionZOffsetMod(tag);
      case "notesconfusionyoffset":
        newMod = new NotesConfusionYOffsetMod(tag);
      case "notesconfusionxoffset":
        newMod = new NotesConfusionXOffsetMod(tag);

      case "angle":
        newMod = new AngleZOffsetMod(tag);
      case "angley":
        newMod = new AngleYOffsetMod(tag);
      case "anglex":
        newMod = new AngleXOffsetMod(tag);

      case "notesangle":
        newMod = new NotesAngleZOffsetMod(tag);
      case "notesangley":
        newMod = new NotesAngleYOffsetMod(tag);
      case "notesanglex":
        newMod = new NotesAngleXOffsetMod(tag);

      case "dizzy":
        newMod = new DizzyMod(tag);
      case "twirl":
        newMod = new TwirlMod(tag);
      case "roll":
        newMod = new RollMod(tag);
      case "dizzy2":
        newMod = new Dizzy2Mod(tag);
      case "twirl2":
        newMod = new Twirl2Mod(tag);
      case "roll2":
        newMod = new Roll2Mod(tag);

      // rotate mods
      case "rotatex":
        newMod = new RotateXModifier(tag);
      case "rotatey":
        newMod = new RotateYMod(tag);
      case "rotatez":
        newMod = new RotateZMod(tag);
      case "strumrotatex":
        newMod = new StrumRotateXMod(tag);
      case "strumrotatey":
        newMod = new StrumRotateYMod(tag);
      case "strumrotatez":
        newMod = new StrumRotateZMod(tag);
      case "notesrotatex":
        newMod = new NotesRotateXModifier(tag);
      case "notesrotatey":
        newMod = new NotesRotateYMod(tag);
      case "notesrotatez":
        newMod = new NotesRotateZMod(tag);

      // stealth mods
      case "oldstealthholds":
        newMod = new UseOldStealthHoldsModifier(tag);
      case "stealthglowred":
        newMod = new StealthGlowRedMod(tag);
      case "stealthglowgreen":
        newMod = new StealthGlowGreenMod(tag);
      case "stealthglowblue":
        newMod = new StealthGlowBlueMod(tag);
      case "dark":
        newMod = new DarkMod(tag);
      case "strumstealth":
        newMod = new StrumStealthMod(tag);
      case "stealth":
        newMod = new StealthMod(tag);
      case "hidden":
        newMod = new HiddenMod(tag);
      case "sudden":
        newMod = new SuddenMod(tag);
      case "vanish":
        newMod = new VanishMod(tag);
      case "blink":
        newMod = new BlinkMod(tag);
      case "holdstealth":
        newMod = new StealthHoldsMod(tag);

      // alpha mods (a part of stealthmods.hx)
      case "alpha":
        newMod = new AlphaModifier(tag);
      case "alphanote":
        newMod = new AlphaNotesModifier(tag);
      case "alphahold":
        newMod = new AlphaHoldsModifier(tag);
      case "alphastrum":
        newMod = new AlphaStrumModifier(tag);
      case "alphasplash":
        newMod = new AlphaNoteSplashModifier(tag);
      case "alphaholdcover":
        newMod = new AlphaHoldCoverModifier(tag);

      // drunk mods
      case "drunk":
        newMod = new DrunkXMod(tag);
      case "drunky":
        newMod = new DrunkYMod(tag);
      case "drunkz":
        newMod = new DrunkZMod(tag);
      case "drunkangle":
        newMod = new DrunkAngleMod(tag);
      case "drunkscale":
        newMod = new DrunkScaleMod(tag);
      case "drunkscalex":
        newMod = new DrunkScaleXMod(tag);
      case "drunkscaley":
        newMod = new DrunkScaleYMod(tag);
      case "drunkspeed":
        newMod = new DrunkSpeedMod(tag);
      case "drunkangley":
        newMod = new DrunkAngleYMod(tag);
      case "drunkanglex":
        newMod = new DrunkAngleXMod(tag);

      case "tandrunk":
        newMod = new TanDrunkXMod(tag);
      case "tandrunky":
        newMod = new TanDrunkYMod(tag);
      case "tandrunkz":
        newMod = new TanDrunkZMod(tag);
      case "tandrunkangle":
        newMod = new TanDrunkAngleMod(tag);
      case "tandrunkscale":
        newMod = new TanDrunkScaleMod(tag);

      // tipsy mods
      case "tipsyx":
        newMod = new TipsyXMod(tag);
      case "tipsy":
        newMod = new TipsyYMod(tag);
      case "tipsyz":
        newMod = new TipsyZMod(tag);
      case "tipsyangle":
        newMod = new TipsyAngleMod(tag);
      case "tipsyskewx":
        newMod = new TipsySkewXMod(tag);
      case "tipsyscale":
        newMod = new TipsyScaleMod(tag);
      case "tipsyskewy":
        newMod = new TipsySkewYMod(tag);

      case "tantipsyx":
        newMod = new TanTipsyXMod(tag);
      case "tantipsy":
        newMod = new TanTipsyYMod(tag);
      case "tantipsyz":
        newMod = new TanTipsyZMod(tag);
      case "tantipsyangle":
        newMod = new TanTipsyAngleMod(tag);
      case "tantipsyscale":
        newMod = new TanTipsyScaleMod(tag);

      // beat mods
      case "beat":
        newMod = new BeatXMod(tag);
      case "beaty":
        newMod = new BeatYMod(tag);
      case "beatz":
        newMod = new BeatZMod(tag);
      case "beatangle":
        newMod = new BeatAngleMod(tag);
      case "beatanglex":
        newMod = new BeatAngleXMod(tag);
      case "beatangley":
        newMod = new BeatAngleYMod(tag);
      case "beatscale":
        newMod = new BeatScaleMod(tag);
      case "beatscalex":
        newMod = new BeatScaleXMod(tag);
      case "beatscaley":
        newMod = new BeatScaleYMod(tag);
      case "beatskewx":
        newMod = new BeatSkewXMod(tag);
      case "beatskewy":
        newMod = new BeatSkewYMod(tag);
      case "beatspeed":
        newMod = new BeatSpeedMod(tag);

      // cosecant mods
      case "cosecantx":
        newMod = new CosecantXMod(tag);
      case "cosecanty":
        newMod = new CosecantYMod(tag);
      case "cosecantz":
        newMod = new CosecantZMod(tag);
      case "cosecantangle":
        newMod = new CosecantAngleMod(tag);
      case "cosecantscale":
        newMod = new CosecantScaleMod(tag);
      case "cosecantscaley":
        newMod = new CosecantScaleYMod(tag);
      case "cosecantscalex":
        newMod = new CosecantScaleXMod(tag);

      // spiral mods
      case "spiralx":
        newMod = new SpiralXMod(tag);
      case "spiraly":
        newMod = new SpiralYMod(tag);
      case "spiralz":
        newMod = new SpiralZMod(tag);
      case "spiralangle":
        newMod = new SpiralAngleZMod(tag);
      case "spiralspeed":
        newMod = new SpiralSpeedMod(tag);
      case "spiralscale":
        newMod = new SpiralScaleMod(tag);

      case "spiralcosx":
        newMod = new SpiralCosXMod(tag);
      case "spiralcosy":
        newMod = new SpiralCosYMod(tag);
      case "spiralcosz":
        newMod = new SpiralCosZMod(tag);
      case "spiralcosangle":
        newMod = new SpiralCosAngleZMod(tag);
      case "spiralcosspeed":
        newMod = new SpiralCosSpeedMod(tag);
      case "spiralcosscale":
        newMod = new SpiralCosScaleMod(tag);

      // tornado mods
      case "tornado":
        newMod = new TornadoXMod(tag);
      case "tornadoy":
        newMod = new TornadoYMod(tag);
      case "tornadoz":
        newMod = new TornadoZMod(tag);
      case "tornadoangle":
        newMod = new TornadoAngleMod(tag);
      case "tornadoscale":
        newMod = new TornadoScaleMod(tag);
      case "tornadoscalex":
        newMod = new TornadoScaleXMod(tag);
      case "tornadoscaley":
        newMod = new TornadoScaleYMod(tag);
      case "tornadoskewx":
        newMod = new TornadoSkewXMod(tag);
      case "tornadoskewy":
        newMod = new TornadoSkewYMod(tag);

      case "tantornado":
        newMod = new TanTornadoXMod(tag);
      case "tantornadoy":
        newMod = new TanTornadoYMod(tag);
      case "tantornadoz":
        newMod = new TanTornadoZMod(tag);
      case "tantornadoangle":
        newMod = new TanTornadoAngleMod(tag);
      case "tantornadoscale":
        newMod = new TanTornadoScaleMod(tag);

      case "hourglass":
        newMod = new HourGlassX(tag);
      case "hourglassy":
        newMod = new HourGlassY(tag);
      case "hourglassz":
        newMod = new HourGlassZ(tag);
      case "hourglassanglex":
        newMod = new HourGlassAngleX(tag);
      case "hourglassangley":
        newMod = new HourGlassAngleY(tag);
      case "hourglassanglez":
        newMod = new HourGlassAngleZ(tag);
      case "hourglassskewx":
        newMod = new HourGlassSkewX(tag);
      case "hourglassskewy":
        newMod = new HourGlassSkewY(tag);
      case "hourglassscalex":
        newMod = new HourGlassScaleX(tag);
      case "hourglassscaley":
        newMod = new HourGlassScaleY(tag);
      case "hourglassscale":
        newMod = new HourGlassScale(tag);

      // saw mods
      case "saw":
        newMod = new SawtoothXMod(tag);
      case "sawy":
        newMod = new SawtoothYMod(tag);
      case "sawz":
        newMod = new SawtoothZMod(tag);
      case "sawangle":
        newMod = new SawtoothAngleMod(tag);
      case "sawanglex":
        newMod = new SawtoothAngleXMod(tag);
      case "sawangley":
        newMod = new SawtoothAngleYMod(tag);
      case "sawskewx":
        newMod = new SawtoothSkewXMod(tag);
      case "sawskewy":
        newMod = new SawtoothSkewYMod(tag);
      case "sawscale":
        newMod = new SawtoothScaleMod(tag);
      case "sawscaley":
        newMod = new SawtoothScaleYMod(tag);
      case "sawscalex":
        newMod = new SawtoothScaleXMod(tag);
      case "sawspeed":
        newMod = new SawtoothSpeedMod(tag);

      // zigzag mods
      case "zigzag":
        newMod = new ZigZagXMod(tag);
      case "zigzagy":
        newMod = new ZigZagYMod(tag);
      case "zigzagz":
        newMod = new ZigZagZMod(tag);
      case "zigzagangle":
        newMod = new ZigZagAngleMod(tag);
      case "zigzaganglex":
        newMod = new ZigZagAngleXMod(tag);
      case "zigzagangley":
        newMod = new ZigZagAngleYMod(tag);
      case "zigzagscale":
        newMod = new ZigZagScaleMod(tag);
      case "zigzagscalex":
        newMod = new ZigZagScaleXMod(tag);
      case "zigzagscaley":
        newMod = new ZigZagScaleYMod(tag);
      case "zigzagskewx":
        newMod = new ZigZagSkewXMod(tag);
      case "zigzagskewy":
        newMod = new ZigZagSkewYMod(tag);
      case "zigzagspeed":
        newMod = new ZigZagSpeedMod(tag);

      // square mods
      case "squareskewx":
        newMod = new SquareSkewXMod(tag);
      case "squareskewy":
        newMod = new SquareSkewYMod(tag);
      case "square":
        newMod = new SquareXMod(tag);
      case "squarey":
        newMod = new SquareYMod(tag);
      case "squarez":
        newMod = new SquareZMod(tag);
      case "squarescale":
        newMod = new SquareScaleMod(tag);
      case "squareangle":
        newMod = new SquareAngleMod(tag);
      case "squarespeed":
        newMod = new SquareSpeedMod(tag);

      // digital mods
      case "digital" | "digitalx":
        newMod = new DigitalXMod(tag);
      case "digitaly":
        newMod = new DigitalYMod(tag);
      case "digitalz":
        newMod = new DigitalZMod(tag);
      case "digitalangle":
        newMod = new DigitalAngleMod(tag);
      case "digitalanglex":
        newMod = new DigitalAngleXMod(tag);
      case "digitalangley":
        newMod = new DigitalAngleYMod(tag);
      case "digitalscale":
        newMod = new DigitalScaleMod(tag);
      case "digitalskewx":
        newMod = new DigitalSkewXMod(tag);
      case "digitalskewy":
        newMod = new DigitalSkewYMod(tag);
      case "digitalspeed":
        newMod = new DigitalSpeedMod(tag);

      // bounce mods
      case "bouncex":
        newMod = new BounceXMod(tag);
      case "bouncey":
        newMod = new BounceYMod(tag);
      case "bouncez":
        newMod = new BounceZMod(tag);
      case "bounceangle":
        newMod = new BounceAngleMod(tag);
      case "bounceanglex":
        newMod = new BounceAngleXMod(tag);
      case "bounceangley":
        newMod = new BounceAngleYMod(tag);
      case "bouncescale":
        newMod = new BounceScaleMod(tag);
      case "bouncescalex":
        newMod = new BounceScaleXMod(tag);
      case "bouncescaley":
        newMod = new BounceScaleYMod(tag);
      case "bounceskewx":
        newMod = new BounceSkewXMod(tag);
      case "bounceskewy":
        newMod = new BounceSkewYMod(tag);
      case "bouncespeed":
        newMod = new BounceSpeedMod(tag);

      case "cosbouncex":
        newMod = new CosBounceXMod(tag);
      case "cosbouncey":
        newMod = new CosBounceYMod(tag);
      case "cosbouncez":
        newMod = new CosBounceZMod(tag);
      case "cosbounceangle":
        newMod = new CosBounceAngleMod(tag);
      case "cosbounceanglex":
        newMod = new CosBounceAngleXMod(tag);
      case "cosbounceangley":
        newMod = new CosBounceAngleYMod(tag);
      case "cosbouncescale":
        newMod = new CosBounceScaleMod(tag);
      case "cosbouncescalex":
        newMod = new CosBounceScaleXMod(tag);
      case "cosbouncescaley":
        newMod = new CosBounceScaleYMod(tag);
      case "cosbounceskewx":
        newMod = new CosBounceSkewXMod(tag);
      case "cosbounceskewy":
        newMod = new CosBounceSkewYMod(tag);

      case "tanbouncex":
        newMod = new TanBounceXMod(tag);
      case "tanbouncey":
        newMod = new TanBounceYMod(tag);
      case "tanbouncez":
        newMod = new TanBounceZMod(tag);
      case "tanbounceangle":
        newMod = new TanBounceAngleMod(tag);
      case "tanbouncescale":
        newMod = new TanBounceScaleMod(tag);
      case "tanbounceskewx":
        newMod = new TanBounceSkewXMod(tag);
      case "tanbounceskewy":
        newMod = new TanBounceSkewYMod(tag);

      // bumpy mods
      case "bumpyx":
        newMod = new BumpyXMod(tag);
      case "bumpyy":
        newMod = new BumpyYMod(tag);
      case "bumpy":
        newMod = new BumpyZMod(tag);
      case "bumpyangle":
        newMod = new BumpyAngleMod(tag);
      case "bumpyanglex":
        newMod = new BumpyAngleXMod(tag);
      case "bumpyangley":
        newMod = new BumpyAngleYMod(tag);
      case "bumpyscale":
        newMod = new BumpyScaleMod(tag);
      case "bumpyscalex":
        newMod = new BumpyScaleXMod(tag);
      case "bumpyscaley":
        newMod = new BumpyScaleYMod(tag);
      case "bumpyskewx":
        newMod = new BumpySkewXMod(tag);
      case "bumpyskewy":
        newMod = new BumpySkewYMod(tag);
      case "bumpyspeed":
        newMod = new BumpySpeedMod(tag);

      case "cosbumpy":
        newMod = new CosBumpyZMod(tag);
      case "cosbumpyy":
        newMod = new CosBumpyYMod(tag);
      case "cosbumpyx":
        newMod = new CosBumpyXMod(tag);
      case "cosbumpyangle":
        newMod = new CosBumpyAngleMod(tag);
      case "cosbumpyanglex":
        newMod = new CosBumpyAngleXMod(tag);
      case "cosbumpyangley":
        newMod = new CosBumpyAngleYMod(tag);
      case "cosbumpyskewx":
        newMod = new CosBumpySkewXMod(tag);
      case "cosbumpyskewy":
        newMod = new CosBumpySkewYMod(tag);
      case "cosbumpyscale":
        newMod = new CosBumpyScaleMod(tag);
      case "cosbumpyscalex":
        newMod = new CosBumpyScaleXMod(tag);
      case "cosbumpyscaley":
        newMod = new CosBumpyScaleYMod(tag);

      case "tanbumpyx":
        newMod = new TanBumpyXMod(tag);
      case "tanbumpyy":
        newMod = new TanBumpyYMod(tag);
      case "tanbumpy":
        newMod = new TanBumpyZMod(tag);
      case "tanbumpyangle":
        newMod = new TanBumpyAngleMod(tag);
      case "tanbumpyscale":
        newMod = new TanBumpyScaleMod(tag);
      case "tanbumpyskewx":
        newMod = new TanBumpySkewXMod(tag);
      case "tanbumpyskewy":
        newMod = new TanBumpySkewYMod(tag);

      // linear mods
      case "linearspeed":
        newMod = new LinearSpeedMod(tag);
      case "linearx":
        newMod = new LinearXMod(tag);
      case "lineary":
        newMod = new LinearYMod(tag);
      case "linearz":
        newMod = new LinearZMod(tag);
      case "linearangle":
        newMod = new LinearAngleMod(tag);
      case "linearscale":
        newMod = new LinearScaleMod(tag);
      case "linearscalex":
        newMod = new LinearScaleXMod(tag);
      case "linearscaley":
        newMod = new LinearScaleYMod(tag);
      case "linearskewx":
        newMod = new LinearSkewXMod(tag);
      case "linearskewy":
        newMod = new LinearSkewYMod(tag);
      case "scalelinear":
        newMod = new ScaleLinearLegacyMod(tag);

      // circ mods
      case "circspeed":
        newMod = new CircSpeedMod(tag);
      case "circx":
        newMod = new CircXMod(tag);
      case "circy":
        newMod = new CircYMod(tag);
      case "circz":
        newMod = new CircZMod(tag);
      case "circangle":
        newMod = new CircAngleMod(tag);
      case "circangley":
        newMod = new CircAngleYMod(tag);
      case "circanglex":
        newMod = new CircAngleXMod(tag);
      case "circscale":
        newMod = new CircScaleMod(tag);
      case "circscalex":
        newMod = new CircScaleXMod(tag);
      case "circscaley":
        newMod = new CircScaleYMod(tag);
      case "circskewx":
        newMod = new CircSkewXMod(tag);
      case "circskewy":
        newMod = new CircSkewYMod(tag);

      // extra mods
      case "attenuate":
        newMod = new AttenuateXMod(tag);
      case "attenuatey":
        newMod = new AttenuateYMod(tag);
      case "attenuatez":
        newMod = new AttenuateZMod(tag);
      case "attenuateangle":
        newMod = new AttenuateAngleMod(tag);
      case "attenuateskewx":
        newMod = new AttenuateSkewYMod(tag);
      case "attenuateskewy":
        newMod = new AttenuateSkewXMod(tag);

      // Snap mods
      case "snap":
        newMod = new GridXYZModifier(tag);
      case "snapx":
        newMod = new GridXModifier(tag);
      case "snapy":
        newMod = new GridYModifier(tag);
      case "snapz":
        newMod = new GridZModifier(tag);
      case "snapstrum":
        newMod = new GridStrumXYZModifier(tag);
      case "snapstrumx":
        newMod = new GridStrumXModifier(tag);
      case "snapstrumy":
        newMod = new GridStrumYModifier(tag);
      case "snapstrumz":
        newMod = new GridStrumZModifier(tag);
      case "snapangle":
        newMod = new GridAngleModifier(tag);

      // wavey mods
      case "waveyx":
        newMod = new WaveyXMod(tag);
      case "waveyy":
        newMod = new WaveyYMod(tag);
      case "waveyz":
        newMod = new WaveyZMod(tag);
      case "waveyangle":
        newMod = new WaveyAngleMod(tag);
      case "waveyscale":
        newMod = new WaveyScaleMod(tag);
      case "waveyscalex":
        newMod = new WaveyScaleXMod(tag);
      case "waveyscaley":
        newMod = new WaveyScaleYMod(tag);
      case "waveyskewx":
        newMod = new WaveySkewXMod(tag);
      case "waveyskewy":
        newMod = new WaveySkewYMod(tag);

      case "tanwaveyx":
        newMod = new TanWaveyXMod(tag);
      case "tanwaveyy":
        newMod = new TanWaveyYMod(tag);
      case "tanwaveyz":
        newMod = new TanWaveyZMod(tag);
      case "tanwaveyangle":
        newMod = new TanWaveyAngleMod(tag);
      case "tanwaveyscale":
        newMod = new TanWaveyScaleMod(tag);
      case "tanwaveyskewx":
        newMod = new TanWaveySkewXMod(tag);
      case "tanwaveyskewy":
        newMod = new TanWaveySkewYMod(tag);

      // offset mods
      case "noteoffsetx":
        newMod = new NoteOffsetXMod(tag);
      case "noteoffsety":
        newMod = new NoteOffsetYMod(tag);
      case "noteoffsetz":
        newMod = new NoteOffsetZMod(tag);
      case "holdoffsetx":
        newMod = new HoldOffsetXMod(tag);
      case "holdoffsety":
        newMod = new HoldOffsetYMod(tag);
      case "holdoffsetz":
        newMod = new HoldOffsetZMod(tag);
      case "strumoffsety":
        newMod = new StrumOffsetYMod(tag);
      case "strumoffsetx":
        newMod = new StrumOffsetXMod(tag);
      case "strumoffsetz":
        newMod = new StrumOffsetZMod(tag);
      case "arrowpathoffsetx":
        newMod = new ArrowPathOffsetXMod(tag);
      case "arrowpathoffsety":
        newMod = new ArrowPathOffsetYMod(tag);
      case "arrowpathoffsetz":
        newMod = new ArrowPathOffsetZMod(tag);

      case "meshpivotoffsetx":
        newMod = new MeshPivotOffsetX(tag);
      case "meshpivotoffsety":
        newMod = new MeshPivotOffsetY(tag);
      case "meshpivotoffsetz":
        newMod = new MeshPivotOffsetZ(tag);

      case "meshskewoffsetx":
        newMod = new MeshSkewOffsetX(tag);
      case "meshskewoffsety":
        newMod = new MeshSkewOffsetY(tag);
      case "meshskewoffsetz":
        newMod = new MeshSkewOffsetZ(tag);

      // arowpath mods
      case "spiralpaths":
        newMod = new SpiralPathsMod(tag);
      case "arrowpath":
        newMod = new ArrowpathMod(tag);
      case "arrowpathwidth":
        newMod = new ArrowpathWidthMod(tag);
      case "arrowpathstraighthold":
        newMod = new ArrowpathStraightHoldMod(tag);
      case "pathgrain":
        newMod = new ArrowpathGrainMod(tag);
      case "arrowpathlength":
        newMod = new ArrowpathFrontLengthMod(tag);
      case "arrowpathbacklength":
        newMod = new ArrowpathBackLengthMod(tag);
      case "arrowpathred":
        newMod = new ArrowpathRedMod(tag);
      case "arrowpathgreen":
        newMod = new ArrowpathGreenMod(tag);
      case "arrowpathblue":
        newMod = new ArrowpathBlueMod(tag);
      case "arrowpath_notitg":
        newMod = new NotITG_ArrowPathMod(tag);

      // col tint mods
      case "notered":
        newMod = new RedNotesColMod(tag);
      case "notegreen":
        newMod = new GreenNotesColMod(tag);
      case "noteblue":
        newMod = new BlueNotesColMod(tag);
      case "strumred":
        newMod = new RedStrumColMod(tag);
      case "strumgreen":
        newMod = new GreenStrumColMod(tag);
      case "strumblue":
        newMod = new BlueStrumColMod(tag);

      // debug mods
      case "debugx":
        newMod = new DebugXMod(tag);
      case "debugy":
        newMod = new DebugYMod(tag);
      case "debugalpha":
        newMod = new DebugAlphaMod(tag);
      case "showallmods":
        newMod = new DebugTxtAllShow(tag);
      case "showsubmods":
        newMod = new DebugTxtSubShow(tag);
      case "showlanemods":
        newMod = new DebugTxtLaneShow(tag);
      case "showextra":
        newMod = new DebugTxtExtraShow(tag);
      case "showzerovalue":
        newMod = new DebugTxtZeroValueShow(tag);

      // default: // Not recognised, assume it's a custom mod
      //  newMod = new CustomModifier(tag);

      default:
        // Alright, we don't know wtf this mod is, let the player know.
        newMod = new Modifier(tag);
        newMod.fuck = true;

        if (notif)
        {
          if (PlayState.instance != null) PlayState.instance.modDebugNotif(tag + " mod is unknown", FlxColor.ORANGE);
          trace(tag + " mod is unknown");
        }
    }

    newMod.targetLane = lane;

    return newMod;
  }
}
