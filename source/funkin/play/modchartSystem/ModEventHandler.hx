package funkin.play.modchartSystem;

import flixel.FlxG;
// funkin stuff
import funkin.play.PlayState;
import funkin.Conductor;
import funkin.play.song.Song;
import funkin.Preferences;
import funkin.util.Constants;
import funkin.play.notes.Strumline;
import funkin.Paths;
import flixel.util.FlxColor;
// Math and utils
import StringTools;
import flixel.util.FlxStringUtil;
import flixel.math.FlxMath;
import funkin.util.SortUtil;
import flixel.util.FlxSort;
// tween
import flixel.tweens.FlxTween;
// import flixel.tweens.FlxTweenManager;
import flixel.tweens.FlxEase;
// mod lol
import funkin.play.modchartSystem.ModConstants;
import funkin.play.modchartSystem.ModTimeEvent;
import funkin.play.modchartSystem.ModHandler;
// import funkin.play.modchartSystem.Modifier;
import funkin.play.modchartSystem.modifiers.BaseModifier;
import funkin.modding.events.ScriptEvent;
import funkin.play.modchartSystem.HazardEase;
import funkin.play.notes.StrumlineNote;

class ModEventHandler
{
  // public var modResetFuncs:Map<String, Void> = new Map<String, Void>();
  public var modResetFuncs:Array<Void->Void> = [];

  public var modEvents:Array<ModTimeEvent> = [];
  public var tweenManager:FlxTweenManager;

  public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();

  // how many custom playfields are there? TODO: Make this split between player and opponent controlled?
  public var customPlayfields:Int = 0;
  public var customPlayfieldsOLD:Bool = false;

  // If set to true, then MOST mods will be divided by 100% when being added into the timeline. This is so you can treat it like NotITG lmao
  public var percentageMods:Bool = false;

  // If set to true, then some mods will be inverted for opponent. Defaults to false.
  public var invertForOpponent:Bool = false;

  public function new()
  {
    // modchartTweens = ["testtween" => null];
    // modchartTweens.remove("testtween");
    modEvents = new Array();
    tweenManager = new FlxTweenManager();
  }

  // Call this to add events to the events array (so stuff can happen lol)
  public function setupEvents():Void
  {
    addModsFromEventList();
  }

  public function clearEvents():Void
  {
    for (key in modchartTweens.keys())
    {
      modchartTweens.get(key).cancel();
      modchartTweens.remove(key);
    }
    // for (key in modResetFuncs.keys())
    // {
    //   modResetFuncs.remove(key);
    // }
    modResetFuncs = new Array();

    for (modEvent in modEvents)
    {
      modEvent.hasTriggered = false;
    }
    tweenManager.clear();
    bullshitCounter = 0;

    modEvents = new Array();

    // wake everyone back up as that is the default!
    for (strum in PlayState.instance.allStrumLines)
    {
      strum.asleep = false;
      strum.mods.resetModValues();
      strum.mods.clearMods();
      strum.mods.addMod('speedmod', 1, 1);
    }
  }

  var songTime:Float = 0;
  var timeBetweenBeats:Float = 0;
  var timeBetweenBeats_ms:Float = 0;
  var beatTime:Float = 0;
  var lastReportedSongTime:Float = 0.0;

  public function update(elapsed:Float):Void
  {
    songTime = Conductor.instance.songPosition;
    timeBetweenBeats = Conductor.instance.beatLengthMs / 1000;
    timeBetweenBeats_ms = Conductor.instance.beatLengthMs;
    beatTime = (songTime / 1000) * (Conductor.instance.bpm / 60);

    // we went, BACK IN TIME?!
    if (songTime < lastReportedSongTime)
    {
      resetMods(); // Just reset everything and let the event handler put everything back.
    }

    var timeBetweenLastReport:Float = (songTime - lastReportedSongTime) / 1000; // Because the elapsed from flxg or the playstate doesn't account for lagspikes? okay, sure.
    // trace("customElapsed: " + timeBetweenLastReport);
    tweenManager.update(timeBetweenLastReport); // should be automatically paused when you pause in game

    // tweenManager.update(elapsed); // should be automatically paused when you pause in game
    handleEvents();

    lastReportedSongTime = songTime;
  }

  // Add a custom mod, make sure this is done BEFORE events are sorted!
  public function addCustomMod(playerTarget:String, mod:CustomModifier, makeCopy:Bool = false):Void
  {
    // check if the name is valid. For now, just checks if its sub lol
    if (ModConstants.isTagSub(mod.tag))
    {
      PlayState.instance.modDebugNotif(mod.tag + " is not a valid custom mod name!", FlxColor.RED);
      return;
    }

    // Add it to the mod handlers
    if (playerTarget == "both" || playerTarget == "all")
    {
      for (customStrummer in PlayState.instance.allStrumLines)
      {
        customStrummer.mods.addCustomMod(mod, makeCopy);
      }
    }
    else
    {
      var modsTarget = ModConstants.grabStrumModTarget(playerTarget);
      modsTarget.addCustomMod(mod, makeCopy);
    }
  }

  // Call this to scan and preload all mods which will be used by the song.
  function addModsFromEventList():Void
  {
    // Sorts the event in chronological order
    modEvents.sort(function(a, b) {
      if (a.startingBeat < b.startingBeat) return -1;
      else if (a.startingBeat > b.startingBeat) return 1;
      else
      {
        // if (a.startingBeat == b.startingBeat) return (a.style == "reset" && !(b.style == "reset") ? 1 : -1); // Same as mirin so reset gets priority!
        return 0;
      }
    });

    // Adding mods to the modHandlers!
    for (i in 0...modEvents.length)
    {
      var timeEventTest = modEvents[i];

      if (timeEventTest.style == "func" || timeEventTest.style == "func_tween" || timeEventTest.style == "reset" || timeEventTest.style == "perframe") continue;

      // check if sub first to avoid adding a subvalue as a mod!
      if (ModConstants.isTagSub(timeEventTest.modName)) continue;
      if (!timeEventTest.target.modifiers.exists(timeEventTest.modName))
      {
        timeEventTest.target.addMod(timeEventTest.modName, 0.0, 0.0);
        var mmm:Float = ModConstants.invertValueCheck(timeEventTest.modName, timeEventTest.target.invertValues);
        timeEventTest.target.modifiers.get(timeEventTest.modName).setVal(0.0 * mmm);
      }
    }

    PlayState.instance.playerStrumline.mods.sortMods();
    PlayState.instance.opponentStrumline.mods.sortMods();
    for (customStrummer in PlayState.instance.customStrumLines)
    {
      customStrummer.mods.sortMods();
    }
  }

  function modchartTweenCancel(tag:String):Void
  {
    if (modchartTweens.exists(tag))
    {
      modchartTweens.get(tag).cancel();
      modchartTweens.remove(tag);
      // trace("killing tween from tweenCancelFunc - " + tag);
    }
  }

  var bullshitCounter:Int = 0;

  // HERE BE MAGIC
  // Tween a mod from one value to another.
  function tweenMod(target:ModHandler, modName:String, newValue:Float, time:Float, easeToUse:Null<Float->Float>, type:String = "tween"):FlxTween
  {
    // FunkinSound.playOnce(Paths.sound("pauseEnable"), 1.0);

    var _tag:String = modName.toLowerCase();
    var realTag:String = ModConstants.modTag(modName.toLowerCase(), target);

    // trace("// !Triggered a tween! \\");
    // trace("Tween tag: " + realTag);
    // trace("Mod to tween: " + _tag);
    // trace("-------------------------");

    bullshitCounter++;
    var isAdd:Bool = type == "add";
    if (!isAdd)
    {
      modchartTweenCancel(realTag);
    }

    var mmm = ModConstants.invertValueCheck(_tag, target.invertValues);
    newValue *= mmm;

    var isSub:Bool = false;
    var subModArr = null;

    if (ModConstants.isTagSub(_tag))
    {
      isSub = true;
      subModArr = _tag.split('__');
      // _tag = subModArr[1];
    }

    if (isAdd)
    {
      if (isSub)
      {
        realTag += "#suba" + bullshitCounter;
      }
      else
      {
        // so every add tween has it's own unique tag so they don't fight over each other. Though is kinda pointless for now until I figure out additive tweens properly lmfao
        realTag += "#a" + bullshitCounter;
      }
    }

    if (isSub)
    {
      var mod:Modifier = target.modifiers.get(subModArr[0]);
      if (mod != null)
      {
        var tween:FlxTween = tweenManager.num(mod.getSubVal(subModArr[1]), newValue, time,
          {
            ease: easeToUse,
            onComplete: function(twn:FlxTween) {
              modchartTweens.remove(realTag);
              mod.setSubVal(subModArr[1], newValue * easeToUse(1));
            }
          }, function(v) {
            mod.setSubVal(subModArr[1], v);
          });

        modchartTweens.set(realTag, tween);
        return tween;
      }
      else
      {
        return null;
      }
    }

    var mod:Modifier = target.modifiers.get(_tag);
    if (mod != null)
    {
      var tween:FlxTween = tweenManager.num(mod.currentValue, newValue, time,
        {
          ease: easeToUse,
          onComplete: function(twn:FlxTween) {
            modchartTweens.remove(realTag);
            mod.currentValue = newValue * easeToUse(1); // UPDATE V0.6 -> FOR EASES LIKE BOUNCE AND POP TO WORK!
          }
        }, function(v) {
          mod.currentValue = v;
        });

      modchartTweens.set(realTag, tween);
      return tween;
    }
    else
    {
      return null;
    }
  }

  // Tween a mod from one value to another.
  function tweenAddMod(target:ModHandler, modName:String, addValue:Float, time:Float, easeToUse:Null<Float->Float>):FlxTween
  {
    // FunkinSound.playOnce(Paths.sound("pauseEnable"), 1.0);

    var _tag:String = modName.toLowerCase();
    var realTag:String = ModConstants.modTag(modName.toLowerCase(), target);

    bullshitCounter++;
    var mmm = ModConstants.invertValueCheck(_tag, target.invertValues);
    addValue *= mmm;

    var isSub:Bool = false;
    var subModArr = null;

    if (ModConstants.isTagSub(_tag))
    {
      isSub = true;
      subModArr = _tag.split('__');
      // _tag = subModArr[1];
    }

    if (isSub)
    {
      realTag += "+s" + bullshitCounter;
    }
    else
    {
      // so every add tween has it's own unique tag so they don't fight over each other. Though is kinda pointless for now until I figure out additive tweens properly lmfao
      realTag += "+m" + bullshitCounter;
    }

    if (isSub)
    {
      var mod:Modifier = target.modifiers.get(subModArr[0]);
      if (mod != null)
      {
        var totalAdded:Float = 0;
        // var initialValue:Float = mod.getSubVal(subModArr[1]);
        var lastReportedChange:Float = 0;
        var tween:FlxTween = tweenManager.num(0, 1, time,
          {
            ease: FlxEase.linear,
            onComplete: function(twn:FlxTween) {
              modchartTweens.remove(realTag);
              // mod.setSubVal(subModArr[1], initialValue + (addValue * easeToUse(1)));
            }
          }, function(t) {
            var v:Float = addValue * easeToUse(t); // ???, cuz for some silly reason tweenValue was being set incorrectly by the tween function / manager? I don't know lmfao
            // mod.currentValue = mod.currentValue + (v - lastReportedChange);
            mod.setSubVal(subModArr[1], mod.getSubVal(subModArr[1]) + (v - lastReportedChange));
            lastReportedChange = v;
            totalAdded = v;
          });

        modchartTweens.set(realTag, tween);
        return tween;
      }
      else
      {
        return null;
      }
    }

    var mod:Modifier = target.modifiers.get(_tag);
    if (mod != null)
    {
      // var initialValue:Float = mod.currentValue;
      var lastReportedChange:Float = 0;
      var tween:FlxTween = tweenManager.num(0, 1, time,
        {
          ease: FlxEase.linear,
          onComplete: function(twn:FlxTween) {
            modchartTweens.remove(realTag);
          }
        }, function(t) {
          var v:Float = addValue * easeToUse(t); // ???, cuz for some silly reason tweenValue was being set incorrectly by the tween function / manager? I don't know lmfao
          mod.currentValue = mod.currentValue + (v - lastReportedChange);
          lastReportedChange = v;
        });

      modchartTweens.set(realTag, tween);
      return tween;
    }
    else
    {
      return null;
    }
  }

  public function triggerResetFuncs():Void
  {
    for (resetFunc in modResetFuncs)
    {
      resetFunc();
    }
  }

  // Call this function to resetEvents!
  public function resetMods():Void
  {
    // trace("------------------------");
    // trace("// !MOD EVENTS RESET! \\");
    // trace("------------------------");

    for (key in modchartTweens.keys())
    {
      modchartTweens.get(key).cancel();
      modchartTweens.remove(key);
    }
    triggerResetFuncs();

    for (modEvent in modEvents)
    {
      modEvent.hasTriggered = false;
    }
    tweenManager.clear();
    bullshitCounter = 0;

    // wake everyone back up as that is the default!
    for (strum in PlayState.instance.allStrumLines)
    {
      strum.asleep = false;
      strum.mods.resetModValues();

      strum.strumlineNotes.forEach(function(note:StrumlineNote) {
        note.resetStealthGlow();
      });
    }
    PlayState.instance.dispatchEvent(new ScriptEvent(MODCHART_RESET));
  }

  function handleEvents():Void
  {
    for (i in 0...modEvents.length)
    {
      var modEvent:ModTimeEvent = modEvents[i];
      if (modEvent.hasTriggered) continue;
      var tween:FlxTween = null;

      // If beat time is PAST the event!
      if (beatTime >= modEvent.startingBeat + modEvent.timeInBeats
        && !(modEvent.style == "func" && modEvent.persist)
        && modEvent.style != "reset")
      {
        modEvent.hasTriggered = true;
        if (!modEvent.persist) continue; // lol

        // trace("==! LATE !   Event Trigger   ! LATE !==");
        switch (modEvent.style)
        {
          case "add":
            tween = tweenAddMod(modEvent.target, modEvent.modName, modEvent.gotoValue, 0.001, modEvent.easeToUse);
          case "add_old":
            var modToTween:Modifier;
            if (modEvent.target.modifiers.exists(modEvent.modName))
            {
              modToTween = modEvent.target.modifiers.get(modEvent.modName);
            }
            else
            {
              continue; // next event please
            }

            modEvent.target.setModVal(modEvent.modName,
              modToTween.currentValue + (modEvent.gotoValue * (modEvent?.easeToUse(1) ?? 1))); // get mod and add to it lol
          case "func_tween":
            if (modEvent.modName != null)
            {
              modchartTweenCancel(modEvent.modName.toLowerCase());
            }
            modEvent.tweenFunky(modEvent.gotoValue * (modEvent?.easeToUse(1) ?? 1));
            continue;

          case "set":
            modEvent.target.setModVal(modEvent.modName, modEvent.gotoValue ?? 0.0);
            continue;
          case "tween":
            modEvent.target.setModVal(modEvent.modName, modEvent.gotoValue * (modEvent?.easeToUse(1) ?? 0.0));
            continue;
          default:
            modEvent.target.setModVal(modEvent.modName, modEvent.gotoValue ?? 0.0);
            continue;
        }
      }
      else if (beatTime >= modEvent.startingBeat) // Trigger the event, and set the tween to be at the proper position!
      {
        modEvent.hasTriggered = true;
        // trace("==   Event Trigger   ==");
        // trace("Type : " + modEvent.style);
        switch (modEvent.style)
        {
          case "reset":
            resetMods_ForTarget(modEvent.target);
            continue;
          case "set":
            modEvent.target.setModVal(modEvent.modName, modEvent.gotoValue ?? 0.0);
            continue;
          case "tween":
            // FunkinSound.playOnce(Paths.sound("pauseDisable"), 1.0);
            tween = tweenMod(modEvent.target, modEvent.modName, modEvent.gotoValue, timeBetweenBeats * modEvent.timeInBeats, modEvent.easeToUse, "tween");

          case "add":
            // FunkinSound.playOnce(Paths.sound("pauseEnable"), 1.0);
            tween = tweenAddMod(modEvent.target, modEvent.modName, modEvent.gotoValue, timeBetweenBeats * modEvent.timeInBeats, modEvent.easeToUse);
          case "add_old":
            // FunkinSound.playOnce(Paths.sound("pauseEnable"), 1.0);
            var modToTween;
            if (modEvent.target.modifiers.exists(modEvent.modName))
            {
              modToTween = modEvent.target.modifiers.get(modEvent.modName);
            }
            else
            {
              trace("ERROR, COULDN'T ADD TO MOD, I DIDN'T EXIST! " + modEvent.modName);
              continue;
            }

            tween = tweenMod(modEvent.target, modEvent.modName, modToTween.currentValue + modEvent.gotoValue, timeBetweenBeats * modEvent.timeInBeats,
              modEvent.easeToUse, "add");
          case "func":
            if (modEvent.modName != null) modchartTweenCancel(modEvent.modName.toLowerCase());
            modEvent.triggerFunction();
            continue;
          case "func_tween":
            var tweenTagged:Bool = false;
            if (modEvent.modName != null)
            {
              tweenTagged = true;
              modchartTweenCancel(modEvent.modName.toLowerCase());
            }
            tween = tweenManager.num(modEvent.startValue, modEvent.gotoValue, timeBetweenBeats * modEvent.timeInBeats,
              {
                ease: modEvent.easeToUse,
                onComplete: function(twn:FlxTween) {
                  if (tweenTagged) modchartTweens.remove(modEvent.modName.toLowerCase());
                  modEvent.tweenFunky(modEvent.gotoValue * (modEvent?.easeToUse(1) ?? 1));
                }
              }, function(v) {
                modEvent.tweenFunky(v);
              });
            if (tweenTagged) modchartTweens.set(modEvent.modName.toLowerCase(), tween);

            // trace("funky tween triggered! was tagged? - " + (tweenTagged ? modEvent.modName.toLowerCase() : "nope"));
        }
      }
      if (tween != null)
      {
        var addAmount:Float = ((songTime - ModConstants.getTimeFromBeat(modEvent.startingBeat)) * 0.001);
        // trace("Tween Funny! " + addAmount);
        @:privateAccess
        tween._secondsSinceStart += addAmount;
        @:privateAccess
        tween.update(0);
      }
    }
  }

  // Call this to reset all mod values and cancel any existing tweens for this player!
  public function resetMods_ForTarget(target:ModHandler):Void
  {
    var lookForInString:String = "player.";
    if (target.isDad) lookForInString = "opponent.";

    // For now, we just clear ALL tweens lol
    for (key in modchartTweens.keys())
    {
      // trace("checking " + key + " for " + lookForInString);
      if (StringTools.contains(key, lookForInString))
      {
        modchartTweens.get(key).cancel();
        modchartTweens.remove(key);
        // trace("stopping this tween cuz reset lol - " + key);
      }
    }
    target.resetModValues();
  }

  // Use these funcs to manage events timeline!
  // Event to reset all mods to default at this beatTime!
  public function resetModEvent(target:ModHandler, startTime:Float):Void
  {
    var timeEventTest:ModTimeEvent = new ModTimeEvent();
    timeEventTest.startingBeat = startTime;
    timeEventTest.style = "reset";
    if (target == null) target = PlayState.instance.playerStrumline.mods;

    timeEventTest.target = target;
    modEvents.push(timeEventTest);
  }

  // Event to set a mod value at this beatTime!
  public function setModEvent(target:ModHandler, startTime:Float, value:Float, modName:String):Void
  {
    addModEventToTimeline(target, startTime, 0, ModConstants.getEaseFromString("linear"), value, modName, "set");
  }

  // Event to trigger a tween between current mod value to value at beatTime
  public function tweenModEvent(target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, value:Float, modName:String):Void
  {
    addModEventToTimeline(target, startTime, length, ease, value, modName, "tween");
    // FunkinSound.playOnce(Paths.sound("pauseDisable"), 1.0);
  }

  // Same as tween, but adds the value onto the current value instead of replacing it sorta deal
  public function addModEvent(target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, value:Float, modName:String):Void
  {
    addModEventToTimeline(target, startTime, length, ease, value, modName, "add");
    // FunkinSound.playOnce(Paths.sound("pauseDisable"), 1.0);
  }

  // Event to trigger a function at this beatTime!
  public function funcModEvent(target:ModHandler, startTime:Float, funky:Void->Void, ?tweenName:String = null, ?persist:Bool = true):Void
  {
    addModEventToTimeline(target, startTime, 1, ModConstants.getEaseFromString("linear"), 0, tweenName, "func", persist, funky);
  }

  // Event to trigger a function at this beatTime!
  public function funcTweenModEvent(target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, startValue:Float, endValue:Float, funky,
      ?tweenName:String = null, ?persist:Bool = true):Void
  {
    // addModEventToTimeline(startTime, 0, FlxEase.linear, 0, tweenName, "func", persist, funky);

    var timeEventTest = new ModTimeEvent();
    if (tweenName != null) timeEventTest.modName = tweenName.toLowerCase();
    else
      timeEventTest.modName = null;

    if (target == null)
    {
      target = PlayState.instance.playerStrumline.mods;
      // trace("null target when trying to add mod, defaulting to player!");
      PlayState.instance.modDebugNotif("null target for funcTween,\ndefaulting to player.", FlxColor.ORANGE);
    }

    timeEventTest.startingBeat = startTime;
    timeEventTest.timeInBeats = length;
    timeEventTest.startValue = startValue;
    timeEventTest.gotoValue = endValue;
    if (ease == null) ease = FlxEase.linear;
    timeEventTest.persist = persist;
    timeEventTest.easeToUse = ease;
    timeEventTest.style = "func_tween";
    timeEventTest.funcTween = funky;
    modEvents.push(timeEventTest);
    // trace("funky tween added!");
  }

  public function addModEventToTimeline(?target:ModHandler, startTime:Float, length:Float, ease:Null<Float->Float>, value:Float, modName:String, type:String,
      ?persist:Bool = true, ?funky:Void->Void = null):Void
  {
    var timeEventTest:ModTimeEvent = new ModTimeEvent();
    if (modName != null) timeEventTest.modName = modName.toLowerCase();
    timeEventTest.gotoValue = value;
    timeEventTest.startingBeat = startTime;
    timeEventTest.timeInBeats = length;

    timeEventTest.persist = persist;

    // default to target BF for now
    if (target == null)
    {
      target = PlayState.instance.playerStrumline.mods;
      PlayState.instance.modDebugNotif("null target for funcTween,\ndefaulting to player.", FlxColor.ORANGE);
      // trace("null target when trying to add mod, defaulting to player!");
    }

    timeEventTest.target = target;

    if (ease == null)
    {
      ease = FlxEase.linear;
      PlayState.instance.modDebugNotif("no ease defined.\nDefaulting to linear.", FlxColor.ORANGE);
      // trace("no ease, default to null");
    }
    timeEventTest.easeToUse = ease;

    if (type == null)
    {
      type = "tween";
    }
    timeEventTest.style = type;

    // if (funky != null)
    // {
    timeEventTest.funcToCall = funky;
    // }

    modEvents.push(timeEventTest);

    /* Unused now lol

      // check if sub first to avoid adding a subvalue as a mod!
      if (isTagSub(timeEventTest.modName)) return;

      // And if the mod doesn't exist, add it!
      // Eventually will do this on beat 0 or countdown start to scan for all mods used in the song and added them automatically instead of mid-song
      if (!modifiers.exists(timeEventTest.modName))
      {
        // FunkinSound.playOnce(Paths.sound("pauseDisable"), 1.0);
        addMod(timeEventTest.modName, timeEventTest.gotoValue, 0.0); // try and add the mod lol
        var mmm = invertValueCheck(timeEventTest.modName);
        modifiers.get(timeEventTest.modName).setVal(timeEventTest.gotoValue * mmm);
      }
     */
  }
}
