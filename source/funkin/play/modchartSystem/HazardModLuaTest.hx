package funkin.play.modchartSystem;

import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import funkin.play.notes.Strumline;
import funkin.play.notes.StrumlineNote;
import funkin.play.modchartSystem.ModHandler;
import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.system.FlxSound;
import flixel.FlxState;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.play.modchartSystem.NoteData;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.graphics.ZSprite;

using StringTools;

class HazardModLuaTest
{
  public var lua:State = null;
  public var scriptName:String = '';

  public var file:String = '';
  public var folder:String = '';

  public static var hscript:HScript = null;

  public function initHaxeModule()
  {
    if (hscript == null)
    {
      trace('initializing haxe interp for: $scriptName');
      hscript = new HScript(); // TO DO: Fix issue with 2 scripts not being able to use the same variable names
    }
  }

  public function new(script:String, fi:String, fo:String)
  {
    lua = LuaL.newstate();
    LuaL.openlibs(lua);
    Lua.init_callbacks(lua);
    try
    {
      var result:Dynamic = LuaL.dofile(lua, script);
      var resultStr:String = Lua.tostring(lua, result);
      if (resultStr != null && result != 0)
      {
        trace('Error on lua script! ' + resultStr);
        #if windows
        lime.app.Application.current.window.alert(resultStr, 'Error on lua script!');
        #else
        luaTrace('Error loading lua script: "$script"\n' + resultStr, true, false, FlxColor.RED);
        #end
        lua = null;
        return;
      }
    }
    catch (e:Dynamic)
    {
      trace(e);
      return;
    }
    scriptName = script;
    file = fi;
    folder = fo;
    trace('lua file loaded succesfully:' + script);

    set('curBpm', Conductor.instance.bpm);
    set('songPos', Conductor.instance.songPosition);

    set('measureLength', Conductor.instance.measureLengthMs);
    set('beatLength', Conductor.instance.beatLengthMs);
    set('stepLength', Conductor.instance.stepLengthMs);

    set('strumSize', ModConstants.strumSize);

    set('modchartVersion', ModConstants.MODCHART_VERSION);
    set('gameVersion', Constants.VERSION);

    set('difficulty', PlayState.instance.currentChart.difficulty);
    set('songName', PlayState.instance.currentChart.songName);

    set('scriptName', scriptName);

    // set('crochet', Conductor.crochet);
    // set('stepCrochet', Conductor.stepCrochet);
    // set('songLength', FlxG.sound.music.length);
    // set('songName', PlayState.SONG.song);
    // set('difficulty', PlayState.storyDifficulty);
    // var difficultyName:String = CoolUtil.difficulties[PlayState.storyDifficulty];
    // set('difficultyName', difficultyName);
    set('screenWidth', FlxG.width);
    set('screenHeight', FlxG.height);
    set('sw', FlxG.width);
    set('sh', FlxG.height);
    set('downscroll', Preferences.downscroll);
    set('downScroll', Preferences.downscroll);
    set('scrollSpeed', PlayState.instance.currentChart.scrollSpeed);

    // TODO:
    // FUNCS, FUNC_TWEEN, AND PERFRAME
    // OTHER LUA EVENT STUFF LOL

    Lua_helper.add_callback(lua, "tween",
      function(startBeat:Float, lengthInBeats:Float, easeToUse:String, modValue:Float, modName:String, playerTarget:String = "all") {
        // trace("WOW! WE NEED TWEEN: " + modName);
        modName = ModConstants.modAliasCheck(modName);

        // trace("ease name : " + easeToUse);
        // trace("ease to use : " + ModConstants.getEaseFromString(easeToUse));
        if (playerTarget == "both" || playerTarget == "all")
        {
          for (customStrummer in PlayState.instance.allStrumLines)
          {
            PlayState.instance.modchartEventHandler.tweenModEvent(customStrummer.mods, startBeat, lengthInBeats, ModConstants.getEaseFromString(easeToUse),
              modValue, modName);
          }
        }
        else
        {
          var modsTarget = ModConstants.grabStrumModTarget(playerTarget);

          PlayState.instance.modchartEventHandler.tweenModEvent(modsTarget, startBeat, lengthInBeats, ModConstants.getEaseFromString(easeToUse), modValue,
            modName);
        }
      });

    // copy and paste of tween function lmfao
    Lua_helper.add_callback(lua, "ease",
      function(startBeat:Float, lengthInBeats:Float, easeToUse:String, modValue:Float, modName:String, playerTarget:String = "all") {
        // trace("WOW! WE NEED TWEEN: " + modName);
        modName = ModConstants.modAliasCheck(modName);

        // trace("ease name : " + easeToUse);
        // trace("ease to use : " + ModConstants.getEaseFromString(easeToUse));
        if (playerTarget == "both" || playerTarget == "all")
        {
          for (customStrummer in PlayState.instance.allStrumLines)
          {
            PlayState.instance.modchartEventHandler.tweenModEvent(customStrummer.mods, startBeat, lengthInBeats, ModConstants.getEaseFromString(easeToUse),
              modValue, modName);
          }
        }
        else
        {
          var modsTarget = ModConstants.grabStrumModTarget(playerTarget);

          PlayState.instance.modchartEventHandler.tweenModEvent(modsTarget, startBeat, lengthInBeats, ModConstants.getEaseFromString(easeToUse), modValue,
            modName);
        }
      });

    Lua_helper.add_callback(lua, "setasleep", function(time:Float, playerTarget:String, newSleepState:Bool = false) {
      if (playerTarget == "both" || playerTarget == "all")
      {
        for (customStrummer in PlayState.instance.allStrumLines)
        {
          PlayState.instance.modchartEventHandler.funcModEvent(customStrummer.mods, time, function() {
            customStrummer.asleep = newSleepState;
          });
        }
      }
      else
      {
        var modsTarget = ModConstants.grabStrumModTarget(playerTarget);
        PlayState.instance.modchartEventHandler.funcModEvent(modsTarget, time, function() {
          modsTarget.strum.asleep = newSleepState;
        });
      }
    });

    Lua_helper.add_callback(lua, "setdefault", function(modValue:Float, modName:String, playerTarget:String = "all") {
      modName = ModConstants.modAliasCheck(modName);

      if (playerTarget == "both" || playerTarget == "all")
      {
        for (customStrummer in PlayState.instance.allStrumLines)
        {
          customStrummer.mods.setDefaultModVal(modName, modValue);
        }
      }
      else
      {
        var modsTarget = ModConstants.grabStrumModTarget(playerTarget);

        modsTarget.setDefaultModVal(modName, modValue);
      }
    });

    Lua_helper.add_callback(lua, "set", function(startBeat:Float, modValue:Float, modName:String, playerTarget:String = "all") {
      // trace("WOW! WE NEED SET: " + modName);
      modName = ModConstants.modAliasCheck(modName);

      if (playerTarget == "both" || playerTarget == "all")
      {
        for (customStrummer in PlayState.instance.allStrumLines)
        {
          PlayState.instance.modchartEventHandler.setModEvent(customStrummer.mods, startBeat, modValue, modName);
        }
      }
      else
      {
        var modsTarget = ModConstants.grabStrumModTarget(playerTarget);

        PlayState.instance.modchartEventHandler.setModEvent(modsTarget, startBeat, modValue, modName);
      }
    });

    Lua_helper.add_callback(lua, "add",
      function(startBeat:Float, lengthInBeats:Float, easeToUse:String, modValue:Float, modName:String, playerTarget:String = "all") {
        // trace("WOW! WE NEED ADD: " + modName);

        modName = ModConstants.modAliasCheck(modName);
        if (playerTarget == "both" || playerTarget == "all")
        {
          for (customStrummer in PlayState.instance.allStrumLines)
          {
            PlayState.instance.modchartEventHandler.addModEvent(customStrummer.mods, startBeat, lengthInBeats, ModConstants.getEaseFromString(easeToUse),
              modValue, modName);
          }
        }
        else
        {
          var modsTarget = ModConstants.grabStrumModTarget(playerTarget);

          PlayState.instance.modchartEventHandler.addModEvent(modsTarget, startBeat, lengthInBeats, ModConstants.getEaseFromString(easeToUse), modValue,
            modName);
        }
      });

    Lua_helper.add_callback(lua, "reset", function(startBeat:Float, playerTarget:String = "all") {
      if (playerTarget == "both" || playerTarget == "all")
      {
        for (customStrummer in PlayState.instance.allStrumLines)
        {
          PlayState.instance.modchartEventHandler.resetModEvent(customStrummer.mods, startBeat);
        }
      }
      else
      {
        var modsTarget = ModConstants.grabStrumModTarget(playerTarget);
        PlayState.instance.modchartEventHandler.resetModEvent(modsTarget, startBeat);
      }
    });

    Lua_helper.add_callback(lua, "percentageMode", function(newval:Bool = false) {
      trace("set percentage mode to: " + newval);
      PlayState.instance.modchartEventHandler.percentageMods = newval;
    });

    Lua_helper.add_callback(lua, "invertForDad", function(newval:Bool = false) {
      trace("set invert mode to: " + newval);
      PlayState.instance.modchartEventHandler.invertForOpponent = newval;
    });

    Lua_helper.add_callback(lua, "centerPlayer", function(pointless:String = "") {
      trace("attempting to center player 0");
      var playerStrumline:Strumline = PlayState.instance.playerStrumline;
      if (playerStrumline != null)
      {
        playerStrumline.x = (FlxG.width / 2 - playerStrumline.width / 2);
      }
    });
    Lua_helper.add_callback(lua, "hideOpponent", function(pointless:String = "") {
      trace("attempting to hide opponent");
      var opponentStrumline = PlayState.instance.opponentStrumline;
      if (opponentStrumline != null)
      {
        opponentStrumline.x = -999;
        for (arrow in opponentStrumline.members)
        {
          arrow.visible = false;
        }
      }
    });
    Lua_helper.add_callback(lua, "centerOpponent", function(pointless:String = "") {
      trace("attempting to center opponent");
      var playerStrumline:FlxSprite = PlayState.instance.opponentStrumline;
      if (playerStrumline != null)
      {
        playerStrumline.x = (FlxG.width / 2 - playerStrumline.width / 2);
      }
    });
    Lua_helper.add_callback(lua, "hidePlayer", function(pointless:String = "") {
      trace("attempting to hide player");
      var opponentStrumline:Strumline = PlayState.instance.playerStrumline;
      if (opponentStrumline != null)
      {
        opponentStrumline.x = -999;
        for (arrow in opponentStrumline.members)
        {
          arrow.visible = false;
        }
      }
    });

    // legacy function, just use the grain mod
    Lua_helper.add_callback(lua, "setGrain", function(newGrainValue:Float = 80, playerTarget:String = "all") {
      if (playerTarget == "both" || playerTarget == "all")
      {
        for (strumLine in PlayState.instance.allStrumLines)
        {
          // strumLine.mods.holdGrain = newGrainValue;
          for (lane in 0...Strumline.KEY_COUNT)
          {
            var whichStrum:StrumlineNote = strumLine.getByIndex(lane);
            whichStrum.strumExtraModData.holdGrain = newGrainValue;
          }
        }
      }
      else
      {
        var modsTarget = ModConstants.grabStrumModTarget(playerTarget);

        for (lane in 0...Strumline.KEY_COUNT)
        {
          var whichStrum:StrumlineNote = modsTarget.strum.getByIndex(lane);
          whichStrum.strumExtraModData.holdGrain = newGrainValue;
        }
      }
      trace("set grain to: " + newGrainValue);
    });

    // legacy function, use createNewPlayer
    Lua_helper.add_callback(lua, "customStrumAmount", function(newval:Int = 0) {
      PlayState.instance.modchartEventHandler.customPlayfieldsOLD = true;
      PlayState.instance.modchartEventHandler.customPlayfields = newval;
      trace("set customplayfields to: " + PlayState.instance.modchartEventHandler.customPlayfields);
    });

    Lua_helper.add_callback(lua, "createNewPlayer", function(playerControlled:Bool, ?noteStyle:String) {
      PlayState.instance.constructNewStrumLine(playerControlled, noteStyle);
    });

    // todo -> make custom playstate console
    Lua_helper.add_callback(lua, "trace", function(text:String, startBeat:Float = -64) {
      PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
        PlayState.instance.modDebugNotif(text);
        // luaTrace(text);
        // trace(text);
      });
    });

    Lua_helper.add_callback(lua, "aftSetup", function(startBeat:Float = -95) {
      if (PlayState.instance.luaAFT_Capture != null)
      {
        // PlayState.instance.modDebugNotif("Can only have one Lua AFT!");
        // trace("Lua already added!");
        luaTrace("Only one Lua AFT sprite can exist.", FlxColor.ORANGE);
        return;
      }
      if (startBeat == -95)
      {
        PlayState.instance.setUpLuaAft();
      }
      else
      {
        PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
          PlayState.instance.setUpLuaAft();
        });
      }
    });

    Lua_helper.add_callback(lua, "aftCaptureAlpha", function(startBeat:Float, v:Float) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
        PlayState.instance.luaAFT_Capture.alpha = v;
        trace("oh hey, we alpha cap", v);
      });
    });

    Lua_helper.add_callback(lua, "aftSpriteAlpha", function(startBeat:Float, v:Float) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
        PlayState.instance.luaAFT_sprite.alpha = v;
        trace("oh hey, we alpha spr", v);
      });
    });

    Lua_helper.add_callback(lua, "aftAlpha", function(startBeat:Float, v:Float) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
        // PlayState.instance.luaAFT_Capture.alpha = v;
        PlayState.instance.luaAFT_sprite.alpha = v;
        trace("oh hey, we alpha it", v);
      });
    });

    Lua_helper.add_callback(lua, "aftRecursive", function(startBeat:Float, v:Bool) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
        PlayState.instance.luaAFT_Capture.recursive = v;
      });
    });
    Lua_helper.add_callback(lua, "aftUpdateRate", function(startBeat:Float, v:Float, trueValue:Bool = false) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      if (trueValue)
      {
        PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
          PlayState.instance.luaAFT_Capture.updateRate = v;
        });
      }
      else
      {
        PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
          PlayState.instance.luaAFT_Capture.targetFps(v);
        });
      }
    });
    Lua_helper.add_callback(lua, "aftBlend", function(startBeat:Float, b:String) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
        PlayState.instance.luaAFT_Capture.blendMode = b;
      });
    });
    Lua_helper.add_callback(lua, "aftSize", function(startBeat:Float, s:Float) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, function() {
        PlayState.instance.luaAFT_sprite.setGraphicSize(Std.int(PlayState.instance.luaAFT_Capture.w * s));
        trace("oh hey, we resized it");
      });
    });

    Lua_helper.add_callback(lua, "aftTweenAlpha", function(startBeat:Float, lengthInBeats:Float, easeToUse:String, modValue:Float) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcTweenModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, lengthInBeats,
        ModConstants.getEaseFromString(easeToUse), PlayState.instance.luaAFT_Capture.alpha, modValue, function(v) {
          // PlayState.instance.luaAFT_Capture.alpha = v;
          PlayState.instance.luaAFT_sprite.alpha = v;
          return v;
      }, "luaAFT_alpha");
    });

    Lua_helper.add_callback(lua, "aftTweenSize", function(startBeat:Float, lengthInBeats:Float, easeToUse:String, modValue:Float) {
      if (PlayState.instance.luaAFT_Capture == null)
      {
        // PlayState.instance.modDebugNotif("No lua aft sprite!");
        // trace("No lua aft!");
        luaTrace("Lua AFT sprite not created!", FlxColor.RED);
        return;
      }
      PlayState.instance.modchartEventHandler.funcTweenModEvent(ModConstants.grabStrumModTarget("bf"), startBeat, lengthInBeats,
        ModConstants.getEaseFromString(easeToUse), 1, modValue, function(v) {
          PlayState.instance.luaAFT_sprite.setGraphicSize(Std.int(PlayState.instance.luaAFT_Capture.w * v));
          return v;
      }, "luaAFT_scale");
    });

    // Stolen from Funkin Lua
    Lua_helper.add_callback(lua, "addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
      #if hscript
      initHaxeModule();
      try
      {
        var str:String = '';
        if (libPackage.length > 0) str = libPackage + '.';

        hscript.variables.set(libName, Type.resolveClass(str + libName));
      }
      catch (e:Dynamic)
      {
        luaTrace(scriptName + ":" + lastCalledFunction + " - " + e, false, false, FlxColor.RED);
      }
      #else
      luaTrace("HScript isn't supported on this platform!", false, false, FlxColor.RED);
      #end
    });

    Lua_helper.add_callback(lua, "runHaxeCode", function(codeToRun:String) {
      var retVal:Dynamic = null;

      #if hscript
      initHaxeModule();
      try
      {
        retVal = hscript.execute(codeToRun);
      }
      catch (e:Dynamic)
      {
        luaTrace(scriptName + ":" + lastCalledFunction + " - " + e, false, false, FlxColor.RED);
      }
      #else
      luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
      #end

      if (retVal != null && !isOfTypes(retVal, [Bool, Int, Float, String, Array])) retVal = null;
      if (retVal == null) Lua.pushnil(lua);
      return retVal;
    });

    Lua_helper.add_callback(lua, "createSprite", function(tag:String, imagePath:String,) {
      var newSpr:FlxSprite = new FlxSprite(0, 0);
      newSpr.loadGraphic(Paths.image(imagePath));
      newSpr.scrollFactor.set();
      PlayState.instance.customLuaSprites.set(tag, newSpr);
      PlayState.instance.add(newSpr);
    });

    call('onCreate', []);
  }

  public static function isOfTypes(value:Any, types:Array<Dynamic>)
  {
    for (type in types)
    {
      if (Std.isOfType(value, type)) return true;
    }
    return false;
  }

  /*
    function grabStrumModTarget(playerTarget:String = "bf"):ModHandler
    {
      var modsTarget:ModHandler = PlayState.instance.playerStrumline.mods;
      var k:Null<Int> = Std.parseInt(playerTarget);
      if (k != null && k < PlayState.instance.customStrumLines.length)
      {
        modsTarget = PlayState.instance.customStrumLines[k].mods;
      }
      else if (playerTarget == "dad" || playerTarget == "opponent")
      {
        modsTarget = PlayState.instance.opponentStrumline.mods;
      }
      return modsTarget;
    }
   */
  public static function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false, color:FlxColor = FlxColor.WHITE):Void
  {
    // if (ignoreCheck || getBool('luaDebugMode'))
    // {
    //  if (deprecated && !getBool('luaDeprecatedWarnings'))
    //  {
    //    return;
    //  }
    // PlayState.instance.addTextToDebug(text, color);
    PlayState.instance.modDebugNotif(text, color);
    trace(text);
    // }
  }

  function getErrorMessage(status:Int):String
  {
    #if LUA_ALLOWED
    var v:String = Lua.tostring(lua, -1);
    Lua.pop(lua, 1);

    if (v != null) v = v.trim();
    if (v == null || v == "")
    {
      switch (status)
      {
        case Lua.LUA_ERRRUN:
          return "Runtime Error";
        case Lua.LUA_ERRMEM:
          return "Memory Allocation Error";
        case Lua.LUA_ERRERR:
          return "Critical Error";
      }
      return "Unknown Error";
    }

    return v;
    #end
    return null;
  }

  function typeToString(type:Int):String
  {
    #if LUA_ALLOWED
    switch (type)
    {
      case Lua.LUA_TBOOLEAN:
        return "boolean";
      case Lua.LUA_TNUMBER:
        return "number";
      case Lua.LUA_TSTRING:
        return "string";
      case Lua.LUA_TTABLE:
        return "table";
      case Lua.LUA_TFUNCTION:
        return "function";
    }
    if (type <= Lua.LUA_TNIL) return "nil";
    #end
    return "unknown";
  }

  var lastCalledFunction:String = '';

  public function call(func:String, args:Array<Dynamic>):Dynamic
  {
    // if (closed) return Function_Continue;

    lastCalledFunction = func;
    try
    {
      if (lua == null) return Function_Continue;

      Lua.getglobal(lua, func);
      var type:Int = Lua.type(lua, -1);

      if (type != Lua.LUA_TFUNCTION)
      {
        if (type > Lua.LUA_TNIL) luaTrace("ERROR (" + func + "): attempt to call a " + typeToString(type) + " value", false, false, FlxColor.RED);

        Lua.pop(lua, 1);
        return Function_Continue;
      }

      for (arg in args)
        Convert.toLua(lua, arg);
      var status:Int = Lua.pcall(lua, args.length, 1, 0);

      // Checks if it's not successful, then show a error.
      if (status != Lua.LUA_OK)
      {
        var error:String = getErrorMessage(status);
        luaTrace("ERROR (" + func + "): " + error, false, false, FlxColor.RED);
        return Function_Continue;
      }

      // If successful, pass and then return the result.
      var result:Dynamic = cast Convert.fromLua(lua, -1);
      if (result == null) result = Function_Continue;

      Lua.pop(lua, 1);
      return result;
    }
    catch (e:Dynamic)
    {
      trace(e);
    }
    return Function_Continue;
  }

  public static var Function_Stop:Dynamic = "##PSYCHLUA_FUNCTIONSTOP";
  public static var Function_Continue:Dynamic = "##PSYCHLUA_FUNCTIONCONTINUE";
  public static var Function_StopLua:Dynamic = "##PSYCHLUA_FUNCTIONSTOPLUA";

  function set(variable:String, data:Dynamic):Void
  {
    if (lua == null)
    {
      return;
    }

    Convert.toLua(lua, data);
    Lua.setglobal(lua, variable);
  }

  public function stop():Void
  {
    if (lua == null)
    {
      return;
    }

    Lua.close(lua);
    lua = null;
  }
}

class HScript
{
  public static var parser:Parser = new Parser();

  public var interp:Interp;

  public var variables(get, never):Map<String, Dynamic>;

  function get_variables()
  {
    return interp.variables;
  }

  public function new()
  {
    interp = new Interp();
    interp.variables.set('FlxG', FlxG);
    interp.variables.set('FlxSprite', FlxSprite);
    interp.variables.set('ZSprite', ZSprite);
    interp.variables.set('FlxCamera', FlxCamera);
    interp.variables.set('FlxTimer', FlxTimer);
    interp.variables.set('FlxTween', FlxTween);
    interp.variables.set('FlxEase', FlxEase);
    interp.variables.set('PlayState', PlayState);
    interp.variables.set('game', PlayState.instance);
    interp.variables.set('Paths', Paths);
    interp.variables.set('Conductor', Conductor);
    interp.variables.set('StringTools', StringTools);
    interp.variables.set('Std', Std);
    interp.variables.set('eh', PlayState.instance.modchartEventHandler);

    interp.variables.set('FlxMath', FlxMath);
    interp.variables.set('Math', Math);

    interp.variables.set("ModConstants", Type.resolveClass("funkin.play.modchartSystem.ModConstants"));
    interp.variables.set("BaseModifier", Type.resolveClass("funkin.play.modchartSystem.modifiers.BaseModifier"));
    interp.variables.set("CustomModifier", Type.resolveClass("funkin.play.modchartSystem.modifiers.CustomModifier"));
    interp.variables.set("NoteData", Type.resolveClass("funkin.play.modchartSystem.NoteData"));
    interp.variables.set('ModHandler', ModHandler);
    interp.variables.set('ModEventHandler', ModEventHandler);

    interp.variables.set('Preferences', Preferences);
    interp.variables.set('downScroll', Preferences.downscroll);

    interp.variables.set("FlxTypedSpriteGroup", Type.resolveClass("flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup"));

    interp.variables.set('createSprGroup', function(variableTag:String, addToGame:Bool = true) {
      var grp:FlxTypedSpriteGroup<FlxSprite> = null;

      if (PlayState.instance.variables.exists(variableTag))
      {
        grp = PlayState.instance.variables.get(variableTag);
      }
      else
      {
        var grp:FlxTypedSpriteGroup<FlxSprite> = new FlxTypedSpriteGroup<FlxSprite>(0, 0);
        grp.scrollFactor.set();
        // grp.scrollFactor.set();
        if (addToGame)
        {
          PlayState.instance.variables.set(variableTag, grp);
          PlayState.instance.add(grp);
        }
      }
      return grp;
    });
    interp.variables.set('addToSprGrp', function(variableTag_Grp:String, toAdd:FlxSprite) {
      var grp:FlxTypedSpriteGroup<FlxSprite> = null;
      if (PlayState.instance.variables.exists(variableTag_Grp)) grp = PlayState.instance.variables.get(variableTag_Grp);
      if (grp != null)
      {
        grp.add(toAdd);
      }
      return grp;
    });

    // interp.variables.set('FlxColor', FlxColor);
    // interp.variables.set('HazardAFT', HazardAFT);

    interp.variables.set('getSpr', function(name:String) {
      var result:FlxSprite = null;
      if (PlayState.instance.customLuaSprites.exists(name)) result = PlayState.instance.customLuaSprites.get(name);
      return result;
    });

    interp.variables.set('createSpr', function(tag:String, imagePath:String, addToGame:Bool = true) {
      var newSpr:FlxSprite = new FlxSprite(0, 0);
      newSpr.loadGraphic(Paths.image(imagePath));
      newSpr.scrollFactor.set();
      if (addToGame)
      {
        PlayState.instance.customLuaSprites.set(tag, newSpr);
        PlayState.instance.add(newSpr);
      }
      return newSpr;
    });

    interp.variables.set('createZSpr', function(tag:String, imagePath:String, addToGame:Bool = true) {
      var newSpr:ZSprite = new ZSprite(0, 0);
      newSpr.loadGraphic(Paths.image(imagePath));
      newSpr.scrollFactor.set();
      if (addToGame)
      {
        PlayState.instance.customLuaSprites.set(tag, newSpr);
        PlayState.instance.add(newSpr);
      }
      return newSpr;
    });

    interp.variables.set('createCustomMod', function(modName:String, defaultBaseValue:Float = 0) {
      if (PlayState.instance.modchartEventHandler == null)
      {
        HazardModLuaTest.luaTrace("Custom Mod could not be created as this song isn't a modchart song!", false, false, FlxColor.RED);
        return null;
      }
      var newMod:CustomModifier = ModConstants.createNewCustomMod(modName, defaultBaseValue);
      return newMod;
    });

    // createSubMod("steps", 4.0);

    interp.variables.set('setResetEvent', function(func:Void->Void) {
      if (PlayState.instance.modchartEventHandler != null)
      {
        PlayState.instance.modchartEventHandler.modResetFuncs.push(func);
      }
    });
    interp.variables.set('addResetEvent', function(func:Void->Void) {
      if (PlayState.instance.modchartEventHandler != null)
      {
        PlayState.instance.modchartEventHandler.modResetFuncs.push(func);
      }
    });

    interp.variables.set('addUpdate', function(func:Float->Void) {
      if (PlayState.instance.perframeFunctions != null)
      {
        PlayState.instance.perframeFunctions.push(func);
      }
    });

    interp.variables.set('setVar', function(name:String, value:Dynamic) {
      PlayState.instance.variables.set(name, value);
    });
    interp.variables.set('getVar', function(name:String) {
      var result:Dynamic = null;
      if (PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
      return result;
    });
    interp.variables.set('removeVar', function(name:String) {
      if (PlayState.instance.variables.exists(name))
      {
        PlayState.instance.variables.remove(name);
        return true;
      }
      return false;
    });
  }

  public function execute(codeToRun:String):Dynamic
  {
    @:privateAccess
    HScript.parser.line = 1;
    HScript.parser.allowTypes = true;
    return interp.execute(HScript.parser.parseString(codeToRun));
  }
}
