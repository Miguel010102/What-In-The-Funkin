package funkin.play.notes;

import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.FlxG;
import funkin.play.notes.notestyle.NoteStyle;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import funkin.play.notes.NoteHoldCover;
import funkin.play.notes.NoteSplash;
import funkin.play.notes.NoteSprite;
import funkin.play.notes.SustainTrail;
import funkin.data.song.SongData.SongNoteData;
import funkin.ui.options.PreferencesMenu;
import funkin.util.SortUtil;
import funkin.modding.events.ScriptEvent;
//
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import funkin.play.modchartSystem.ModHandler;
import funkin.play.modchartSystem.ModConstants;
import funkin.graphics.ZSprite;
import funkin.play.modchartSystem.HazardArrowpath;
import funkin.Paths;
import funkin.play.modchartSystem.NoteData;

/**
 * A group of sprites which handles the receptor, the note splashes, and the notes (with sustains) for a given player.
 */
class Strumline extends FlxSpriteGroup
{
  public static final DIRECTIONS:Array<NoteDirection> = [NoteDirection.LEFT, NoteDirection.DOWN, NoteDirection.UP, NoteDirection.RIGHT];
  public static final STRUMLINE_SIZE:Int = 104;
  public static final NOTE_SPACING:Int = STRUMLINE_SIZE + 8;

  // Positional fixes for new strumline graphics.
  public static final INITIAL_OFFSET = -0.275 * STRUMLINE_SIZE;
  public static final NUDGE:Float = 2.0;

  public static final KEY_COUNT:Int = 4;
  static final NOTE_SPLASH_CAP:Int = 6;

  static var RENDER_DISTANCE_MS(get, never):Float;

  static function get_RENDER_DISTANCE_MS():Float
  {
    return FlxG.height / 0.45;
  }

  /**
   * The thingy used to control modifiers.
   */
  public var mods:ModHandler;

  // Set to true for opponent and player strumline cuz they already have their inputs set properly.
  // public var skipmeforcontrolslol:Bool = false;
  // made public so scripts can easily refer to this lol
  public var isActuallyPlayerStrum:Bool = false;

  // If set to true, this strumline will just be set to do the bare minimum work for performance.
  public var asleep(default, set):Bool = false;

  private var wasDebugVisible:Bool = false;

  // if true, will automatically hide this strumline when set to sleep!
  public var hideOnSleep:Bool = true;

  function set_asleep(value:Bool):Bool
  {
    wasDebugVisible = txtActiveMods.visible;
    asleep = value;
    if (hideOnSleep)
    {
      this.visible = !asleep;
      if (!value) txtActiveMods.visible = wasDebugVisible;
    }
    return asleep;
  }

  public function requestMeshCullUpdateForNotes(forNotes:Bool = false):Void
  {
    if (!createdNoteMeshes) return;

    if (forNotes)
    {
      for (note in notes.members)
      {
        if (note?.mesh != null)
        {
          var c:String = note.noteModData?.whichStrumNote?.strumExtraModData?.cullModeNotes ?? "none";
          // note.mesh.cullMode = c;
          note.mesh.hazCullMode = c;
        }
      }
      for (note in notesVwoosh.members)
      {
        if (note?.mesh != null)
        {
          var c:String = note.noteModData?.whichStrumNote?.strumExtraModData?.cullModeNotes ?? "none";
          // note.mesh.cullMode = c;
          note.mesh.hazCullMode = c;
        }
      }
    }
    else
    {
      for (note in holdNotes.members)
      {
        // note.cullMode = note.whichStrumNote?.strumExtraModData?.cullModeSustain ?? "none";
        note.hazCullMode = note.whichStrumNote?.strumExtraModData?.cullModeSustain ?? "none";
      }
      for (note in holdNotesVwoosh.members)
      {
        note.hazCullMode = note.whichStrumNote?.strumExtraModData?.cullModeSustain ?? "none";

        // note.cullMode = note.whichStrumNote?.strumExtraModData?.cullModeSustain ?? "none";
      }
    }
  }

  public var createdNoteMeshes:Bool = false;

  public function requestNoteMeshCreation():Void
  {
    if (createdNoteMeshes) return;

    for (note in notes.members)
    {
      note.setupMesh();
    }
    for (note in notesVwoosh.members)
    {
      note.setupMesh();
    }
    strumlineNotes.forEach(function(note:StrumlineNote) {
      note.setupMesh();
    });
    createdNoteMeshes = true;
  }

  public var arrowPaths:FlxTypedSpriteGroup<SustainTrail>;

  var notitgPaths:Array<HazardArrowpath> = [];
  // var arrowPaths_SPRITES:FlxTypedSpriteGroup<ZSprite>;
  var notitgPathSprite:ZSprite;

  public var sustainGraphicWidth:Null<Float> = null;
  // when set to true, arrowpath will be like NotITG. Will require different values for size
  public var notitgStyledPath:Bool = false;

  var notitgPath:HazardArrowpath;

  /**
   * Whether this strumline is controlled by the player's inputs.
   * False means it's controlled by the opponent or Bot Play.
   */
  public var isPlayer:Bool;

  /**
   * Usually you want to keep this as is, but if you are using a Strumline and
   * playing a sound that has it's own conductor, set this (LatencyState for example)
   */
  public var conductorInUse(get, set):Conductor;

  // Used in-game to control the scroll speed within a song
  public var scrollSpeed:Float = 1.0;

  public function resetScrollSpeed():Void
  {
    scrollSpeed = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
  }

  var _conductorInUse:Null<Conductor>;

  function get_conductorInUse():Conductor
  {
    if (_conductorInUse == null) return Conductor.instance;
    return _conductorInUse;
  }

  function set_conductorInUse(value:Conductor):Conductor
  {
    return _conductorInUse = value;
  }

  /**
   * The notes currently being rendered on the strumline.
   * This group iterates over this every frame to update note positions.
   * The PlayState also iterates over this to calculate user inputs.
   */
  public var notes:FlxTypedSpriteGroup<NoteSprite>;

  public var holdNotes:FlxTypedSpriteGroup<SustainTrail>;

  public var onNoteIncoming:FlxTypedSignal<NoteSprite->Void>;

  public var strumlineNotes:FlxTypedSpriteGroup<StrumlineNote>;
  public var noteSplashes:FlxTypedSpriteGroup<NoteSplash>;
  public var noteHoldCovers:FlxTypedSpriteGroup<NoteHoldCover>;

  public var notesVwoosh:FlxTypedSpriteGroup<NoteSprite>;
  public var holdNotesVwoosh:FlxTypedSpriteGroup<SustainTrail>;

  final noteStyle:NoteStyle;

  /**
   * The note data for the song. Should NOT be altered after the song starts,
   * so we can easily rewind.
   */
  var noteData:Array<SongNoteData> = [];

  var nextNoteIndex:Int = -1;

  var heldKeys:Array<Bool> = [];

  public function new(noteStyle:NoteStyle, isPlayer:Bool, modchartSong:Bool = false)
  {
    super();

    this.isPlayer = isPlayer;
    isActuallyPlayerStrum = isPlayer;
    this.noteStyle = noteStyle;

    if (modchartSong)
    {
      this.arrowPaths = new FlxTypedSpriteGroup<SustainTrail>();
      this.arrowPaths.zIndex = 8;
      this.add(this.arrowPaths);

      notitgPathSprite = new ZSprite();
      notitgPathSprite.x = 0;
      notitgPathSprite.y = 0;
      this.notitgPathSprite.zIndex = 8;
      this.add(notitgPathSprite);

      if (PlayState.instance != null)
      {
        if (PlayState.instance.allStrumSprites != null && PlayState.instance.noteRenderMode)
        {
          PlayState.instance.allStrumSprites.add(notitgPathSprite);
        }
      }
    }

    this.strumlineNotes = new FlxTypedSpriteGroup<StrumlineNote>();
    this.strumlineNotes.zIndex = 10;
    this.add(this.strumlineNotes);

    // Hold notes are added first so they render behind regular notes.
    this.holdNotes = new FlxTypedSpriteGroup<SustainTrail>();
    this.holdNotes.zIndex = 20;
    this.add(this.holdNotes);

    this.holdNotesVwoosh = new FlxTypedSpriteGroup<SustainTrail>();
    this.holdNotesVwoosh.zIndex = 21;
    this.add(this.holdNotesVwoosh);

    this.notes = new FlxTypedSpriteGroup<NoteSprite>();
    this.notes.zIndex = 30;
    this.add(this.notes);

    this.notesVwoosh = new FlxTypedSpriteGroup<NoteSprite>();
    this.notesVwoosh.zIndex = 31;
    this.add(this.notesVwoosh);

    this.noteHoldCovers = new FlxTypedSpriteGroup<NoteHoldCover>(0, 0, 4);
    this.noteHoldCovers.zIndex = 40;
    this.add(this.noteHoldCovers);

    this.noteSplashes = new FlxTypedSpriteGroup<NoteSplash>(0, 0, NOTE_SPLASH_CAP);
    this.noteSplashes.zIndex = 50;
    this.add(this.noteSplashes);

    if (modchartSong)
    {
      setupModStuff();
    }

    this.refresh();

    this.onNoteIncoming = new FlxTypedSignal<NoteSprite->Void>();
    resetScrollSpeed();

    for (i in 0...KEY_COUNT)
    {
      var child:StrumlineNote = new StrumlineNote(noteStyle, isPlayer, DIRECTIONS[i]);
      child.x = getXPos(DIRECTIONS[i]);
      child.x += INITIAL_OFFSET;
      child.y = 0;
      noteStyle.applyStrumlineOffsets(child);
      this.strumlineNotes.add(child);

      child.weBelongTo = this;
      if (PlayState.instance != null)
      {
        if (PlayState.instance.allStrumSprites != null && PlayState.instance.noteRenderMode)
        {
          PlayState.instance.allStrumSprites.add(child);
        }
      }
    }

    for (i in 0...KEY_COUNT)
    {
      heldKeys.push(false);
    }

    // This MUST be true for children to update!
    this.active = true;
  }

  public function setupModStuff():Void
  {
    if (mods == null)
    {
      this.mods = new ModHandler(!isPlayer);
      this.mods.strum = this;
    }

    if (txtActiveMods == null)
    {
      this.txtActiveMods = new FlxText(this.x, this.y, 0, 'wtf', 20);
      this.txtActiveMods.x += (1.5 * Strumline.NOTE_SPACING);
      // this.txtActiveMods.y += (Preferences.downscroll ? -200 : 200);
      // errrr, wtf lol?
      this.txtActiveMods.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      this.txtActiveMods.borderSize = 2;
      this.txtActiveMods.zIndex = 66;
      this.add(this.txtActiveMods);
    }
  }

  public function refresh():Void
  {
    sort(SortUtil.byZIndex, FlxSort.ASCENDING);
  }

  override function get_width():Float
  {
    return KEY_COUNT * Strumline.NOTE_SPACING;
  }

  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);
    if (asleep) return;

    if (mods != null)
    {
      if (!generatedArrowPaths && drawArrowPaths)
      {
        notitgPaths = [];
        notitgPath = new HazardArrowpath(this);
        notitgPathSprite.loadGraphic(notitgPath.bitmap);

        for (i in 0...KEY_COUNT)
        {
          var holdNoteSprite:SustainTrail = new SustainTrail(0, 0, noteStyle, true, this);
          // holdNoteSprite.makeGraphic(10, 20, FlxColor.WHITE);
          this.arrowPaths.add(holdNoteSprite);
          holdNoteSprite.weBelongTo = this;

          if (PlayState.instance.allStrumSprites != null && PlayState.instance.noteRenderMode)
          {
            PlayState.instance.allStrumSprites.add(holdNoteSprite);
          }

          holdNoteSprite.parentStrumline = this;
          holdNoteSprite.noteData = null;
          holdNoteSprite.strumTime = 0;
          holdNoteSprite.noteDirection = i;

          var whichStrumNote:StrumlineNote = getByIndex(i);
          holdNoteSprite.alpha = whichStrumNote?.strumExtraModData?.arrowPathAlpha ?? 0;
          holdNoteSprite.fullSustainLength = holdNoteSprite.sustainLength = whichStrumNote.strumExtraModData.arrowpathLength
            + whichStrumNote.strumExtraModData.arrowpathBackwardsLength;

          holdNoteSprite.missedNote = false;
          holdNoteSprite.hitNote = false;
          holdNoteSprite.visible = true;
        }
        generatedArrowPaths = true;
      }

      mods.update(elapsed);
      updateSpecialMods();
      updateStrums();
      updateNotes();
      updateArrowPaths(elapsed);
      updateModDebug();
      updatePerspective();
    }
    else
    {
      updateNotes();
    }
  }

  function updateSpecialMods():Void
  {
    for (lane in 0...KEY_COUNT)
    {
      for (mod in mods.mods_special)
      {
        if (mod.targetLane != -1 && lane != mod.targetLane) continue;
        mod.specialMath(lane, this);
      }
    }
  }

  var generatedArrowPaths:Bool = false;

  // if set to false, will skip arrowpath update logic
  public var drawArrowPaths:Bool = true;

  function updateArrowPaths(elapsed:Float):Void
  {
    if (!generatedArrowPaths) return;
    if (!drawArrowPaths) return;

    notitgPathSprite.visible = notitgStyledPath;
    if (notitgStyledPath)
    {
      notitgPath.updateAFT();

      var isPixel:Bool = noteStyle.id.toLowerCase() == "pixel"; // dumb fucking fix lmfao
      notitgPathSprite.x = isPixel ? -12 : 0; // temp fix lmao

      notitgPathSprite.y = 0;

      arrowPaths.forEach(function(note:SustainTrail) {
        note.visible = false;
      });
      return;
    }

    arrowPaths.forEach(function(note:SustainTrail) {
      note.x = ModConstants.holdNoteJankX;
      note.y = ModConstants.holdNoteJankY;

      note.visible = drawArrowPaths;
      // note.alpha = arrowPathAlpha[note.noteDirection];
      var whichStrumNote:StrumlineNote = getByIndex(note.noteDirection);
      note.alpha = whichStrumNote?.strumExtraModData?.arrowPathAlpha ?? 0;
      // ay -= whichStrumNote.strumExtraModData.alphaHoldCoverMod;

      {
        note.fullSustainLength = note.sustainLength = whichStrumNote.strumExtraModData.arrowpathLength
          + whichStrumNote.strumExtraModData.arrowpathBackwardsLength;

        // note.fullSustainLength = arrowpathLength[note.noteDirection % KEY_COUNT] + arrowpathBackwardsLength[note.noteDirection % KEY_COUNT];
        // note.sustainLength = arrowpathLength[note.noteDirection % KEY_COUNT] + arrowpathBackwardsLength[note.noteDirection % KEY_COUNT];

        note.strumTime = Conductor.instance?.songPosition ?? 0;
        note.strumTime -= whichStrumNote?.strumExtraModData?.arrowpathBackwardsLength ?? 0;
        note.updateClipping();
      }
    });
  }

  function updatePerspective():Void
  {
    if (mods == null) return;

    sortNoteSprites();

    for (note in holdNotes)
    {
      note.updateClipping();
      // ModConstants.applyPerspective(note);
    }

    strumlineNotes.forEach(function(note:StrumlineNote) {
      if (!(note.noteModData?.whichStrumNote?.strumExtraModData?.threeD ?? false)) ModConstants.applyPerspective(note);
    });

    for (note in notes)
    {
      if (!(note.noteModData?.whichStrumNote?.strumExtraModData?.threeD ?? false)) ModConstants.applyPerspective(note);
      // ModConstants.applyPerspective(note);
    }
    for (cover in noteHoldCovers)
    {
      if (cover.alive)
      {
        cover.applyPerspective();
      }
    }
    for (splash in noteSplashes)
    {
      if (splash.alive)
      {
        ModConstants.applyPerspective(splash, splash.width / 2.2, splash.height / 2.2);
      }
    }
  }

  public function getStrumOffsetX():Float
  {
    @:privateAccess
    return noteStyle._data.assets.noteStrumline.offsets[0];
  }

  public function getStrumOffsetY():Float
  {
    @:privateAccess
    return noteStyle._data.assets.noteStrumline.offsets[1];
  }

  function setStrumPos(note:StrumlineNote):Void
  {
    note.x = getXPos(note.direction);
    note.x += this.x;
    note.x += Strumline.INITIAL_OFFSET;
    note.y = this.y;
    note.alpha = 1;
    note.angle = 0;
    var isPixel:Bool = noteStyle.id.toLowerCase() == "pixel"; // dumb fucking fix lmfao
    var sizeMod:Float = isPixel ? dumbfuckingpixelnotesfix : 1;

    note.scale.set(ModConstants.noteScale * sizeMod, ModConstants.noteScale * sizeMod);
    note.z = 0.0;

    note.skew.x = 0;
    note.skew.y = 0;

    noteStyle.applyStrumlineOffsets(note);

    note.resetStealthGlow(true);
    note.noteModData.defaultValues();
    note.noteModData.setValuesFromZSprite(note);
    note.noteModData.direction = note.direction;
    note.noteModData.whichStrumNote = note;
    note.noteModData.noteType = "receptor";

    note.noteModData.curPos = 0;
    note.noteModData.curPos_unscaled = 0;

    var ohgod:Float = note.strumExtraModData.strumPos; // mods.strumPos[note.direction];
    note.strumDistance = ohgod;
    note.noteModData.strumPosition = ohgod;
  }

  // public var orientExtraMath:Array<Float> = [0, 0, 0, 0];

  function updateStrums_single(note:StrumlineNote, timeOffset:Float = 0):Void
  {
    if (note.strumDistance != 0 || timeOffset != 0)
    {
      note.noteModData.strumTime = Conductor.instance?.songPosition ?? 0;
      note.noteModData.strumTime += note.noteModData.strumPosition + timeOffset;

      note.noteModData.curPos_unscaled = calculateNoteYPos(note.noteModData.strumTime, false) * -1;
      for (mod in mods.mods_speed)
      {
        if (mod.targetLane != -1 && note.direction != mod.targetLane) continue;
        note.noteModData.speedMod *= mod.speedMath(note.noteModData.direction, note.noteModData.curPos_unscaled, this, false);
      }
      note.noteModData.curPos = calculateNoteYPos(note.noteModData.strumTime, false) * note.noteModData.speedMod * -1;
      for (mod in mods.mods_strums)
      {
        if (mod.targetLane != -1 && note.noteModData.direction != mod.targetLane) continue;
        mod.strumMath(note.noteModData, this);
      }

      note.noteModData.setStrumPosWasHere(); // for rotate mods to still function as intended

      note.noteModData.y += note.noteModData.curPos; // move it like a regular note

      if (!mods.mathCutOffCheck(note.noteModData.curPos, note.noteModData.direction))
      {
        for (mod in mods.mods_notes)
        {
          if (mod.targetLane != -1 && note.noteModData.direction != mod.targetLane) continue;
          mod.noteMath(note.noteModData, this, false);
        }
      }
      note.noteModData.strumPosOffsetThingy.x = note.noteModData.strumPosWasHere.x - note.noteModData.x;
      note.noteModData.strumPosOffsetThingy.y = note.noteModData.strumPosWasHere.y - note.noteModData.y;
      note.noteModData.strumPosOffsetThingy.z = note.noteModData.strumPosWasHere.z - note.noteModData.z;
    }
    else
    {
      for (mod in mods.mods_strums)
      {
        if (mod.targetLane != -1 && note.noteModData.direction != mod.targetLane) continue;
        mod.strumMath(note.noteModData, this);
      }
    }
    note.applyNoteData(note.noteModData);
    note.updateLastKnownPos();
    note.noteModData.lastKnownPosition = note.lastKnownPosition;
    note.updateStealthGlow();

    // for mesh shenaniguns
    if (note.mesh != null)
    {
      note.mesh.pivotOffsetX = note.noteModData.meshOffsets_PivotX;
      note.mesh.pivotOffsetY = note.noteModData.meshOffsets_PivotY;
      note.mesh.pivotOffsetZ = note.noteModData.meshOffsets_PivotZ;
      note.mesh.skewX_offset = note.noteModData.meshOffsets_SkewX;
      note.mesh.skewY_offset = note.noteModData.meshOffsets_SkewY;
      note.mesh.skewZ_offset = note.noteModData.meshOffsets_SkewZ;
    }
  }

  function updateStrums():Void
  {
    // var i:Int = 0;
    strumlineNotes.forEach(function(note:StrumlineNote) {
      setStrumPos(note);

      note.updateLastKnownPos();
      note.noteModData.lastKnownPosition = note.lastKnownPosition;

      if (note.strumExtraModData.orientExtraMath != 0)
      {
        updateStrums_single(note, note.strumExtraModData.orientExtraMath);
        setStrumPos(note);
      }
      updateStrums_single(note);
      // i++;
    });

    // if (strumlineNotes.members.length > 1) strumlineNotes.members.insertionSort(compareNoteSprites.bind(FlxSort.ASCENDING));

    for (cover in noteHoldCovers)
    {
      if (cover.alive)
      {
        noteCoverSetPos(cover);
      }
    }

    for (splash in noteSplashes)
    {
      if (splash.alive)
      {
        noteSplashSetPos(splash, splash.DIRECTION);
      }
    }
  }

  /**
   * The FlxText which displays the current active mods
   */
  public var txtActiveMods:FlxText;

  public var hideZeroValueMods:Bool = true;
  public var hideSubMods:Bool = true;
  public var debugHideUtil:Bool = true;
  public var debugHideLane:Bool = true;
  public var debugShowALL:Bool = false;
  public var debugNeedsUpdate:Bool = true; // V0.7a -> Now no longer updates every frame! Only updates when needed. Will be further optimised later!

  function updateModDebug():Void
  {
    if (txtActiveMods.visible == false || txtActiveMods.alpha < 0) return;
    if (!debugNeedsUpdate) return;
    var newString = "-:Mods:-\n";
    if (isActuallyPlayerStrum)
    {
      if (!isPlayer) // if isPlayer is set to false, even though it was created to be a player strum, then display it as using botplay!
      {
        newString += "\n";
        newString += "-BOTPLAY-";
      }
      if (PlayState.instance.isPracticeMode)
      {
        newString += "\n";
        newString += "-PRACTICE-";
      }
    }
    else
    {
      newString += "\n";
      newString += "-CPU-";
    }
    if (mods.invertValues)
    {
      newString += "\n";
      newString += "-INVERTED MOD VALUES-";
    }
    newString += "\n";
    newString += "-ScrollSpeed: " + PlayState.instance.currentChart.scrollSpeed + "-";

    // for (mod in modifiers){
    for (mod in mods.mods_all)
    {
      var modVal = FlxMath.roundDecimal(mod.currentValue, 2);
      if (modVal == 0 && hideZeroValueMods && !debugShowALL) continue;
      if (ModConstants.hideSomeDebugBois.contains(mod.tag) && debugHideUtil && !debugShowALL) continue;
      if (StringTools.contains(mod.tag, "--") && debugHideLane && !debugShowALL) continue;
      newString += "\n";
      newString += mod.tag + ": " + Std.string(modVal);
      if (!hideSubMods || debugShowALL)
      {
        for (key in mod.subValues.keys())
        {
          newString += "\n-";
          newString += key + ": " + Std.string(mod.getSubVal(key));
        }
      }
    }

    // Don't update if nothing changed (?)
    if (txtActiveMods.text != newString)
    {
      txtActiveMods.text = newString;
      txtActiveMods.x = this.x;
      txtActiveMods.x += (2.0 * Strumline.NOTE_SPACING);
      txtActiveMods.x -= txtActiveMods.width / 2;
      // txtActiveMods.y = this.y + (Preferences.downscroll ? -375 : 375);
      // v0.6.8a adjusted upscroll mod position to be further up the screen (like up arrow, up)
      txtActiveMods.y = this.y + (Preferences.downscroll ? -375 : 200);

      txtActiveMods.x += mods.debugTxtOffsetX;
      txtActiveMods.y += mods.debugTxtOffsetY;
    }
    debugNeedsUpdate = false;
  }

  /**
   * Returns `true` if no notes are in range of the strumline and the player can spam without penalty.
   */
  public function mayGhostTap():Bool
  {
    // TODO: Refine this. Only querying "can be hit" is too tight but "is being rendered" is too loose.
    // Also, if you just hit a note, there should be a (short) period where this is off so you can't spam.

    // If there are any notes on screen, we can't ghost tap.
    return notes.members.filter(function(note:NoteSprite) {
      return note != null && note.alive && !note.hasBeenHit;
    }).length == 0;
  }

  /**
   * Return notes that are within `Constants.HIT_WINDOW` ms of the strumline.
   * @return An array of `NoteSprite` objects.
   */
  public function getNotesMayHit():Array<NoteSprite>
  {
    return notes.members.filter(function(note:NoteSprite) {
      return note != null && note.alive && !note.hasBeenHit && note.mayHit;
    });
  }

  /**
   * Return hold notes that are within `Constants.HIT_WINDOW` ms of the strumline.
   * @return An array of `SustainTrail` objects.
   */
  public function getHoldNotesHitOrMissed():Array<SustainTrail>
  {
    return holdNotes.members.filter(function(holdNote:SustainTrail) {
      return holdNote != null && holdNote.alive && (holdNote.hitNote || holdNote.missedNote);
    });
  }

  public function getNoteSprite(noteData:SongNoteData):NoteSprite
  {
    if (noteData == null) return null;

    for (note in notes.members)
    {
      if (note == null) continue;
      if (note.alive) continue;

      if (note.noteData == noteData) return note;
    }

    return null;
  }

  public function getHoldNoteSprite(noteData:SongNoteData):SustainTrail
  {
    if (noteData == null || ((noteData.length ?? 0.0) <= 0.0)) return null;

    for (holdNote in holdNotes.members)
    {
      if (holdNote == null) continue;
      if (holdNote.alive) continue;

      if (holdNote.noteData == noteData) return holdNote;
    }

    return null;
  }

  /**
   * Call this when resetting the playstate.
   */
  public function vwooshNotes():Void
  {
    for (note in notes.members)
    {
      if (note == null) continue;
      if (!note.alive) continue;

      notes.remove(note);
      notesVwoosh.add(note);

      note.vwooshing = true;

      var targetY:Float = FlxG.height + note.y;
      if (Preferences.downscroll) targetY = 0 - note.height;

      // check for 3D
      if (note.mesh != null)
      {
        FlxTween.tween(note.mesh, {y: targetY}, 0.498,
          {
            ease: FlxEase.expoIn
          });
      }

      FlxTween.tween(note, {y: targetY}, 0.5,
        {
          ease: FlxEase.expoIn,
          onComplete: function(twn) {
            note.kill();
            notesVwoosh.remove(note, true);
            note.destroy();
          }
        });
    }

    for (holdNote in holdNotes.members)
    {
      if (holdNote == null) continue;
      if (!holdNote.alive) continue;

      holdNotes.remove(holdNote);
      holdNotesVwoosh.add(holdNote);

      var targetY:Float = FlxG.height + holdNote.y;
      if (Preferences.downscroll) targetY = 0 - holdNote.height;
      FlxTween.tween(holdNote, {y: targetY}, 0.5,
        {
          ease: FlxEase.expoIn,
          onComplete: function(twn) {
            holdNote.kill();
            holdNotesVwoosh.remove(holdNote, true);
            holdNote.destroy();
          }
        });
    }
  }

  /**
   * For a note's strumTime, calculate its Y position relative to the strumline.
   * NOTE: Assumes Conductor and PlayState are both initialized.
   * @param strumTime
   * @return Float
   */
  public function calculateNoteYPos(strumTime:Float, vwoosh:Bool = true):Float
  {
    // Make the note move faster visually as it moves offscreen.
    // var vwoosh:Float = (strumTime < Conductor.songPosition) && vwoosh ? 2.0 : 1.0;
    // ^^^ commented this out... do NOT make it move faster as it moves offscreen!
    var vwoosh:Float = 1.0;

    return
      Constants.PIXELS_PER_MS * (conductorInUse.songPosition - strumTime - Conductor.instance.inputOffset) * scrollSpeed * vwoosh * (Preferences.downscroll ? 1 : -1);
  }

  var dumbfuckingpixelnotesfix:Float = 8;
  var dumbMagicNumberForX:Float = 28;

  public function getNoteXOffset():Float
  {
    return dumbMagicNumberForX;
  }

  public function getNoteYOffset():Float
  {
    return -INITIAL_OFFSET;
  }

  function setNotePos(note:NoteSprite, vwoosh:Bool = false):Void
  {
    note.noteModData.defaultValues();
    note.color = FlxColor.WHITE;
    note.noteModData.strumTime = note.strumTime;
    note.noteModData.direction = note.direction % KEY_COUNT;
    note.noteModData.whichStrumNote = getByIndex(note.noteModData.direction);
    var timmy:Float = note.strumTime - note.noteModData.whichStrumNote.strumExtraModData.strumPos;

    note.noteModData.curPos_unscaled = calculateNoteYPos(timmy, vwoosh);
    for (mod in mods.mods_speed)
    {
      if (mod.targetLane != -1 && note.direction != mod.targetLane) continue;
      note.noteModData.speedMod *= mod.speedMath(note.noteModData.direction, note.noteModData.curPos_unscaled, this, false);
    }
    note.noteModData.curPos = calculateNoteYPos(timmy, vwoosh) * note.noteModData.speedMod;

    var isPixel:Bool = noteStyle.id.toLowerCase() == "pixel"; // dumb fucking fix lmfao
    var sizeMod:Float = isPixel ? dumbfuckingpixelnotesfix : 1;

    note.noteModData.angleZ = note.noteModData.whichStrumNote.angle;
    note.noteModData.x = note.noteModData.whichStrumNote.x + note.noteModData.getNoteXOffset();
    note.noteModData.y = note.noteModData.whichStrumNote.y + note.noteModData.getNoteYOffset() + note.noteModData.curPos;
    note.noteModData.z = note.noteModData.whichStrumNote.z;

    if (isPixel)
    {
      note.noteModData.x -= note.noteModData.getNoteXOffset();
      note.noteModData.y -= 10;
    }
    note.scale.set(ModConstants.noteScale * sizeMod, ModConstants.noteScale * sizeMod);
    note.noteModData.scaleX = note.scale.x;
    note.noteModData.scaleY = note.scale.y;

    if (!mods.mathCutOffCheck(note.noteModData.curPos, note.noteModData.direction))
    {
      for (mod in mods.mods_notes)
      {
        if (mod.targetLane != -1 && note.noteModData.direction != mod.targetLane) continue;
        mod.noteMath(note.noteModData, this, vwoosh);
      }

      for (mod in note.noteModData.noteMods)
      {
        if (mod.targetLane != -1 && note.noteModData.direction != mod.targetLane) continue;
        mod.noteMath(note.noteModData, this, vwoosh);
      }
    }
    note.noteModData.funnyOffMyself();

    note.applyNoteData(note.noteModData);
    note.updateLastKnownPos();
    note.noteModData.lastKnownPosition = note.lastKnownPosition;

    // for mesh shenaniguns
    if (note.mesh != null)
    {
      note.mesh.pivotOffsetX = note.noteModData.meshOffsets_PivotX;
      note.mesh.pivotOffsetY = note.noteModData.meshOffsets_PivotY;
      note.mesh.pivotOffsetZ = note.noteModData.meshOffsets_PivotZ;
      note.mesh.skewX_offset = note.noteModData.meshOffsets_SkewX;
      note.mesh.skewY_offset = note.noteModData.meshOffsets_SkewY;
      note.mesh.skewZ_offset = note.noteModData.meshOffsets_SkewZ;
    }

    note.updateStealthGlow();
    // perspective applied in applyperspective part of update routine
  }

  function updateNotes():Void
  {
    if (noteData.length == 0) return;

    // Ensure note data gets reset if the song happens to loop.
    // NOTE: I had to remove this line because it was causing notes visible during the countdown to be placed multiple times.
    // I don't remember what bug I was trying to fix by adding this.
    // if (conductorInUse.currentStep == 0) nextNoteIndex = 0;

    var songStart:Float = PlayState.instance?.startTimestamp ?? 0.0;
    var hitWindowStart:Float = conductorInUse.songPosition - Constants.HIT_WINDOW_MS;
    var renderWindowStart:Float = conductorInUse.songPosition + RENDER_DISTANCE_MS;

    for (noteIndex in nextNoteIndex...noteData.length)
    {
      var note:Null<SongNoteData> = noteData[noteIndex];

      if (note == null) continue; // Note is blank
      if (note.time < songStart || note.time < hitWindowStart)
      {
        // Note is in the past, skip it.
        nextNoteIndex = noteIndex + 1;
        continue;
      }

      var drawDistanceForward:Float = 1;
      if (mods != null)
      {
        var whichStrumNote:StrumlineNote = getByIndex(note.getDirection() % KEY_COUNT);
        drawDistanceForward = 1 + (whichStrumNote?.strumExtraModData?.drawdistanceForward ?? 0);
      }
      var renderWindowStart_EDITED:Float = conductorInUse.songPosition + (RENDER_DISTANCE_MS * drawDistanceForward);

      if (note.time > renderWindowStart_EDITED) break; // Note is too far ahead to render

      var noteSprite = buildNoteSprite(note);

      if (note.length > 0)
      {
        noteSprite.holdNoteSprite = buildHoldNoteSprite(note);
      }

      nextNoteIndex = noteIndex + 1; // Increment the nextNoteIndex rather than splicing the array, because splicing is slow.

      onNoteIncoming.dispatch(noteSprite);
    }

    // Update rendering of notes.
    for (note in notes.members)
    {
      if (note == null || !note.alive) continue;

      var vwoosh:Bool = note.holdNoteSprite == null;
      // Set the note's position.
      if (mods != null)
      {
        setNotePos(note, false);

        var drawDistanceBackkk:Float = 1;
        if (mods != null)
        {
          drawDistanceBackkk = 1 + (note?.noteModData?.whichStrumNote?.strumExtraModData?.drawdistanceBack ?? 0);
        }

        var renderWindowEnd = note.strumTime + Constants.HIT_WINDOW_MS + (RENDER_DISTANCE_MS / 8 * drawDistanceBackkk);
        // If the note is missed
        // if desaturated, ,eisofnoaunawdabwo
        if ((note.handledMiss || note.hasBeenHit) && conductorInUse.songPosition >= renderWindowEnd)
        {
          killNote(note);
        }
      }
      else
      {
        note.y = this.y - INITIAL_OFFSET + calculateNoteYPos(note.strumTime, vwoosh);

        // If the note is miss
        var isOffscreen = Preferences.downscroll ? note.y > FlxG.height : note.y < -note.height;
        if (note.handledMiss && isOffscreen)
        {
          killNote(note);
        }
      }
    }
    var isPixel:Bool = noteStyle.id.toLowerCase() == "pixel"; // dumb fucking fix lmfao

    // Update rendering of hold notes.
    for (holdNote in holdNotes.members)
    {
      if (holdNote == null || !holdNote.alive) continue;

      if (conductorInUse.songPosition > holdNote.strumTime && holdNote.hitNote && !holdNote.missedNote)
      {
        if (isPlayer && !isKeyHeld(holdNote.noteDirection))
        {
          // Stopped pressing the hold note.
          playStatic(holdNote.noteDirection);
          holdNote.missedNote = true;
          holdNote.visible = true;
          holdNote.alpha = 0.0; // Completely hide the dropped hold note.
        }
      }

      var drawDistanceBack:Float = 1;
      if (mods != null)
      {
        drawDistanceBack = 1.0 + (holdNote?.whichStrumNote?.strumExtraModData?.drawdistanceBack ?? 0.0);
      }
      var renderWindowEnd = holdNote.strumTime + holdNote.fullSustainLength + Constants.HIT_WINDOW_MS + (RENDER_DISTANCE_MS / 8 * drawDistanceBack);

      if (holdNote.missedNote && conductorInUse.songPosition >= renderWindowEnd)
      {
        // Hold note is offscreen, kill it.
        holdNote.visible = false;
        holdNote.kill(); // Do not destroy! Recycling is faster.
      }
      else if (holdNote.hitNote && holdNote.sustainLength <= 0)
      {
        // Hold note is completed, kill it.
        if (isKeyHeld(holdNote.noteDirection))
        {
          playPress(holdNote.noteDirection);
        }
        else
        {
          playStatic(holdNote.noteDirection);
        }

        if (holdNote.cover != null && isPlayer)
        {
          holdNote.cover.playEnd();
        }
        else if (holdNote.cover != null)
        {
          // *lightning* *zap* *crackle*
          holdNote.cover.visible = false;
          holdNote.cover.kill();
        }

        holdNote.visible = false;
        holdNote.kill();
      }
      else if (holdNote.missedNote && (holdNote.fullSustainLength > holdNote.sustainLength))
      {
        // Hold note was dropped before completing, keep it in its clipped state.
        holdNote.visible = true;

        var yOffset:Float = (holdNote.fullSustainLength - holdNote.sustainLength) * Constants.PIXELS_PER_MS;

        var vwoosh:Bool = false;
        if (mods != null)
        {
          holdNote.x = ModConstants.holdNoteJankX + (isPixel ? -dumbMagicNumberForX : 0);
          holdNote.y = ModConstants.holdNoteJankY + (isPixel ? -12 : 0);
        }
        else
        {
          if (Preferences.downscroll)
          {
            holdNote.y = this.y - INITIAL_OFFSET + calculateNoteYPos(holdNote.strumTime, vwoosh) - holdNote.height + STRUMLINE_SIZE / 2;
          }
          else
          {
            holdNote.y = this.y - INITIAL_OFFSET + calculateNoteYPos(holdNote.strumTime, vwoosh) + yOffset + STRUMLINE_SIZE / 2;
          }
        }

        // Clean up the cover.
        if (holdNote.cover != null)
        {
          holdNote.cover.visible = false;
          holdNote.cover.kill();
        }
      }
      else if (conductorInUse.songPosition > holdNote.strumTime && holdNote.hitNote)
      {
        // Hold note is currently being hit, clip it off.
        holdConfirm(holdNote.noteDirection);
        holdNote.visible = true;

        holdNote.sustainLength = (holdNote.strumTime + holdNote.fullSustainLength) - conductorInUse.songPosition;

        if (holdNote.sustainLength <= 10)
        {
          holdNote.visible = false;
        }

        if (mods != null)
        {
          holdNote.x = ModConstants.holdNoteJankX + (isPixel ? -dumbMagicNumberForX : 0);
          holdNote.y = ModConstants.holdNoteJankY + (isPixel ? -12 : 0);
        }
        else
        {
          if (Preferences.downscroll)
          {
            holdNote.y = this.y - INITIAL_OFFSET - holdNote.height + STRUMLINE_SIZE / 2;
          }
          else
          {
            holdNote.y = this.y - INITIAL_OFFSET + STRUMLINE_SIZE / 2;
          }
        }
      }
      else
      {
        // Hold note is new, render it normally.
        holdNote.visible = true;
        var vwoosh:Bool = false;
        if (mods != null)
        {
          holdNote.x = ModConstants.holdNoteJankX + (isPixel ? -dumbMagicNumberForX : 0);
          holdNote.y = ModConstants.holdNoteJankY + (isPixel ? -12 : 0);
        }
        else
        {
          if (Preferences.downscroll)
          {
            holdNote.y = this.y - INITIAL_OFFSET + calculateNoteYPos(holdNote.strumTime, vwoosh) - holdNote.height + STRUMLINE_SIZE / 2;
          }
          else
          {
            holdNote.y = this.y - INITIAL_OFFSET + calculateNoteYPos(holdNote.strumTime, vwoosh) + STRUMLINE_SIZE / 2;
          }
        }
      }
    }

    // Update rendering of pressed keys.
    for (dir in DIRECTIONS)
    {
      if (isKeyHeld(dir) && getByDirection(dir).getCurrentAnimation() == "static")
      {
        playPress(dir);
      }
    }
  }

  /**
   * Called when the PlayState skips a large amount of time forward or backward.
   */
  public function handleSkippedNotes():Void
  {
    // By calling clean(), we remove all existing notes so they can be re-added.
    clean();
    // By setting noteIndex to 0, the next update will skip past all the notes that are in the past.
    nextNoteIndex = 0;
  }

  public function onBeatHit():Void
  {
    if (mods == null) sortNoteSprites(); // default sorting is done every beat for some reason lol
  }

  public function sortNoteSprites():Void
  {
    if (notes.members.length > 1) notes.members.insertionSort(compareNoteSprites.bind(FlxSort.ASCENDING));

    if (holdNotes.members.length > 1) holdNotes.members.insertionSort(compareHoldNoteSprites.bind(FlxSort.ASCENDING));

    if (strumlineNotes.members.length > 1 && mods != null) strumlineNotes.members.insertionSort(compareStrums.bind(FlxSort.ASCENDING));

    // if (strumlineNotes_Visual.members.length > 1) strumlineNotes_Visual.members.insertionSort(compareNoteSprites.bind(FlxSort.ASCENDING));
  }

  public function pressKey(dir:NoteDirection):Void
  {
    heldKeys[dir] = true;
  }

  public function releaseKey(dir:NoteDirection):Void
  {
    heldKeys[dir] = false;
  }

  public function isKeyHeld(dir:NoteDirection):Bool
  {
    return heldKeys[dir];
  }

  /**
   * Called when the song is reset.
   * Removes any special animations and the like.
   * Doesn't reset the notes from the chart, that's handled by the PlayState.
   */
  public function clean():Void
  {
    for (note in notes.members)
    {
      if (note == null) continue;
      killNote(note);
    }

    for (holdNote in holdNotes.members)
    {
      if (holdNote == null) continue;
      holdNote.kill();
    }

    for (splash in noteSplashes)
    {
      if (splash == null) continue;
      splash.kill();
    }

    for (cover in noteHoldCovers)
    {
      if (cover == null) continue;
      cover.kill();
    }

    heldKeys = [false, false, false, false];

    for (dir in DIRECTIONS)
    {
      playStatic(dir);
    }
    resetScrollSpeed();
  }

  public function applyNoteData(data:Array<SongNoteData>):Void
  {
    this.notes.clear();

    this.noteData = data.copy();
    this.nextNoteIndex = 0;

    // Sort the notes by strumtime.
    this.noteData.insertionSort(compareNoteData.bind(FlxSort.ASCENDING));
  }

  /**
   * @param note The note to hit.
   * @param removeNote True to remove the note immediately, false to make it transparent and let it move offscreen.
   */
  public function hitNote(note:NoteSprite, removeNote:Bool = true):Void
  {
    playConfirm(note.direction);
    note.hasBeenHit = true;

    if (removeNote)
    {
      killNote(note);
    }
    else
    {
      note.alpha = 0.5;
      note.desaturate();
    }

    if (note.holdNoteSprite != null)
    {
      note.holdNoteSprite.hitNote = true;
      note.holdNoteSprite.missedNote = false;
      note.holdNoteSprite.alpha = 1.0;

      note.holdNoteSprite.sustainLength = (note.holdNoteSprite.strumTime + note.holdNoteSprite.fullSustainLength) - conductorInUse.songPosition;
    }
  }

  public function killNote(note:NoteSprite):Void
  {
    if (note == null) return;
    note.visible = false;
    notes.remove(note, false);
    note.kill();

    if (note.holdNoteSprite != null)
    {
      note.holdNoteSprite.missedNote = true;
      note.holdNoteSprite.visible = false;
    }
  }

  public function getByIndex(index:Int):StrumlineNote
  {
    var returnValue:StrumlineNote = this.strumlineNotes.members[index];
    if (mods != null)
    {
      strumlineNotes.forEach(function(note:StrumlineNote) {
        if (note.direction == index)
        {
          returnValue = note;
        }
      });
    }
    return returnValue;
  }

  public function getByDirection(direction:NoteDirection):StrumlineNote
  {
    return getByIndex(DIRECTIONS.indexOf(direction));
  }

  public function playStatic(direction:NoteDirection):Void
  {
    getByDirection(direction).playStatic();
  }

  public function playPress(direction:NoteDirection):Void
  {
    getByDirection(direction).playPress();
  }

  public function playConfirm(direction:NoteDirection):Void
  {
    getByDirection(direction).playConfirm();
  }

  public function holdConfirm(direction:NoteDirection):Void
  {
    getByDirection(direction).holdConfirm();
  }

  public function isConfirm(direction:NoteDirection):Bool
  {
    return getByDirection(direction).isConfirm();
  }

  public function playNoteSplash(direction:NoteDirection):Void
  {
    // TODO: Add a setting to disable note splashes.
    // if (Settings.noSplash) return;
    if (!noteStyle.isNoteSplashEnabled()) return;

    var splash:NoteSplash = this.constructNoteSplash();

    if (splash != null)
    {
      splash.play(direction);

      if (mods != null)
      {
        noteSplashSetPos(splash, direction);
      }
      else
      {
        splash.x = this.x;
        splash.x += getXPos(direction);
        splash.x += INITIAL_OFFSET;
        splash.y = this.y;
        splash.y -= INITIAL_OFFSET;
        splash.y += 0;
      }
    }
  }

  function noteCoverSetPos(cover:NoteHoldCover):Void
  {
    // var whichStrumNote = strumlineNotes.group.members[cover.holdNote.noteDirection % KEY_COUNT];
    var whichStrumNote:StrumlineNote = getByIndex(cover.holdNoteDir % KEY_COUNT);

    cover.x = whichStrumNote.x;
    cover.y = whichStrumNote.y;

    cover.x -= (112.0 / 1.4);
    cover.y -= (112.0 / 1.5);

    // cover.z = whichStrumNote.z; // copy Z!
    cover.scale.set(1.0, 1.0);

    var ay:Float = whichStrumNote.alpha;
    ay -= whichStrumNote.strumExtraModData.alphaHoldCoverMod;
    // ay -= alphaHoldCoverMod[cover.holdNoteDir % KEY_COUNT];

    if (cover.glow != null)
    {
      cover.glow.x = cover.x;
      cover.glow.y = cover.y;
      cover.glow.z = 0;
      cover.glow.scale.set(1.0, 1.0);
      cover.glow.z = whichStrumNote.z;
      cover.glow.alpha = ay;
      cover.glow.skew.x = whichStrumNote.skew.x;
      cover.glow.skew.y = whichStrumNote.skew.y;
    }
    if (cover.sparks != null)
    {
      cover.sparks.x = cover.x;
      cover.sparks.y = cover.y;
      cover.sparks.z = 0;
      cover.sparks.scale.set(1.0, 1.0);
      cover.sparks.z = whichStrumNote.z;
      cover.sparks.alpha = ay;
      cover.sparks.skew.x = whichStrumNote.skew.x;
      cover.sparks.skew.y = whichStrumNote.skew.y;
    }
  }

  function noteSplashSetPos(splash:NoteSplash, direction:Int):Void
  {
    // var funny:Float = (FlxMath.fastSin(conductorInUse.songPosition / 1000) + 1) * 0.5;

    // var whichStrumNote = strumlineNotes.group.members[direction % KEY_COUNT];
    var whichStrumNote:StrumlineNote = getByIndex(direction % KEY_COUNT);
    splash.x = whichStrumNote.x;
    splash.y = whichStrumNote.y;
    splash.x += 26;
    splash.y += 17;
    splash.z = whichStrumNote.z; // copy Z!
    // splash.scale.set(funny, funny);
    splash.scale.set(1, 1);

    var ay:Float = whichStrumNote.alpha;
    ay -= whichStrumNote.strumExtraModData.alphaSplashMod;
    // ay -= alphaSplashMod[direction % KEY_COUNT];

    splash.alpha = ay;
    splash.skew.x = whichStrumNote.skew.x;
    splash.skew.y = whichStrumNote.skew.y;
  }

  public function playNoteHoldCover(holdNote:SustainTrail):Void
  {
    // TODO: Add a setting to disable note splashes.
    // if (Settings.noSplash) return;
    if (!noteStyle.isHoldNoteCoverEnabled()) return;

    var cover:NoteHoldCover = this.constructNoteHoldCover();

    if (cover != null)
    {
      cover.holdNote = holdNote;
      holdNote.cover = cover;
      cover.visible = true;

      cover.playStart();

      cover.x = this.x;
      cover.x += getXPos(holdNote.noteDirection);
      cover.x += STRUMLINE_SIZE / 2;
      cover.x -= cover.width / 2;
      cover.x += -12; // Manual tweaking because fuck.

      cover.y = this.y;
      cover.y += INITIAL_OFFSET;
      cover.y += STRUMLINE_SIZE / 2;
      cover.y += -96; // Manual tweaking because fuck.
    }
  }

  public function buildNoteSprite(note:SongNoteData):NoteSprite
  {
    var noteSprite:NoteSprite = constructNoteSprite();

    if (noteSprite != null)
    {
      noteSprite.direction = note.getDirection();
      noteSprite.noteData = note;

      noteSprite.x = this.x;
      noteSprite.x += getXPos(DIRECTIONS[note.getDirection() % KEY_COUNT]);
      noteSprite.x -= NUDGE;
      // noteSprite.x += INITIAL_OFFSET;
      noteSprite.y = -9999;

      if (noteSprite.mesh == null && createdNoteMeshes) noteSprite.setupMesh();

      if (noteSprite.mesh != null)
      {
        noteSprite.mesh.hazCullMode = getByIndex(noteSprite.direction).strumExtraModData?.cullModeNotes ?? "none";
        // noteSprite.mesh.cullMode = getByIndex(noteSprite.direction).strumExtraModData?.cullModeNotes ?? "none";
      }
    }

    return noteSprite;
  }

  public function buildHoldNoteSprite(note:SongNoteData):SustainTrail
  {
    var holdNoteSprite:SustainTrail = constructHoldNoteSprite();

    if (holdNoteSprite != null)
    {
      holdNoteSprite.parentStrumline = this;
      holdNoteSprite.noteData = note;
      holdNoteSprite.strumTime = note.time;
      holdNoteSprite.noteDirection = note.getDirection();
      holdNoteSprite.fullSustainLength = note.length;
      holdNoteSprite.sustainLength = note.length;
      holdNoteSprite.missedNote = false;
      holdNoteSprite.hitNote = false;
      holdNoteSprite.visible = true;
      holdNoteSprite.alpha = 1.0;

      holdNoteSprite.x = this.x;
      holdNoteSprite.x += getXPos(DIRECTIONS[note.getDirection() % KEY_COUNT]);
      holdNoteSprite.x += STRUMLINE_SIZE / 2;
      holdNoteSprite.x -= holdNoteSprite.width / 2;
      holdNoteSprite.y = -9999;

      holdNoteSprite.whichStrumNote = getByIndex(holdNoteSprite.noteDirection);

      holdNoteSprite.hazCullMode == holdNoteSprite.whichStrumNote?.strumExtraModData?.cullModeSustain ?? "none";
      // holdNoteSprite.cullMode == holdNoteSprite.whichStrumNote?.strumExtraModData?.cullModeSustain ?? "none";
    }

    return holdNoteSprite;
  }

  /**
   * Custom recycling behavior.
   */
  function constructNoteSplash():NoteSplash
  {
    var result:NoteSplash = null;

    // If we haven't filled the pool yet...
    if (noteSplashes.length < noteSplashes.maxSize)
    {
      // Create a new note splash.
      result = new NoteSplash();
      this.noteSplashes.add(result);
      result.weBelongTo = this;
      if (PlayState.instance != null)
      {
        if (PlayState.instance.allStrumSprites != null && PlayState.instance.noteRenderMode)
        {
          PlayState.instance.allStrumSprites.add(result);
        }
      }
    }
    else
    {
      // Else, find a note splash which is inactive so we can revive it.
      result = this.noteSplashes.getFirstAvailable();

      if (result != null)
      {
        result.revive();
      }
      else
      {
        // The note splash pool is full and all note splashes are active,
        // so we just pick one at random to destroy and restart.
        result = FlxG.random.getObject(this.noteSplashes.members);
      }
    }

    return result;
  }

  /**
   * Custom recycling behavior.
   */
  function constructNoteHoldCover():NoteHoldCover
  {
    var result:NoteHoldCover = null;

    // If we haven't filled the pool yet...
    if (noteHoldCovers.length < noteHoldCovers.maxSize)
    {
      // Create a new note hold cover.
      result = new NoteHoldCover();
      this.noteHoldCovers.add(result);
    }
    else
    {
      // Else, find a note splash which is inactive so we can revive it.
      result = this.noteHoldCovers.getFirstAvailable();

      if (result != null)
      {
        result.revive();
      }
      else
      {
        // The note hold cover pool is full and all note hold covers are active,
        // so we just pick one at random to destroy and restart.
        result = FlxG.random.getObject(this.noteHoldCovers.members);
      }
    }

    return result;
  }

  /**
   * Custom recycling behavior.
   */
  function constructNoteSprite():NoteSprite
  {
    var result:NoteSprite = null;

    // Else, find a note which is inactive so we can revive it.
    result = this.notes.getFirstAvailable();

    if (result != null)
    {
      // Revive and reuse the note.
      result.revive();
    }
    else
    {
      // The note sprite pool is full and all note splashes are active.
      // We have to create a new note.
      result = new NoteSprite(noteStyle);
      this.notes.add(result);
      result.weBelongTo = this;

      if (PlayState.instance != null)
      {
        if (PlayState.instance.allStrumSprites != null && PlayState.instance.noteRenderMode)
        {
          PlayState.instance.allStrumSprites.add(result);
        }
      }
    }

    return result;
  }

  /**
   * Custom recycling behavior.
   */
  function constructHoldNoteSprite():SustainTrail
  {
    var result:SustainTrail = null;

    // Else, find a note which is inactive so we can revive it.
    result = this.holdNotes.getFirstAvailable();

    if (result != null)
    {
      // Revive and reuse the note.
      result.revive();
    }
    else
    {
      // The note sprite pool is full and all note splashes are active.
      // We have to create a new note.
      result = new SustainTrail(0, 0, noteStyle, false, this);
      this.holdNotes.add(result);
      if (PlayState.instance != null)
      {
        if (PlayState.instance.allStrumSprites != null && PlayState.instance.noteRenderMode)
        {
          PlayState.instance.allStrumSprites.add(result);
        }
      }
    }

    return result;
  }

  function getXPos(direction:NoteDirection):Float
  {
    return switch (direction)
    {
      case NoteDirection.LEFT: 0;
      case NoteDirection.DOWN: 0 + (1 * Strumline.NOTE_SPACING);
      case NoteDirection.UP: 0 + (2 * Strumline.NOTE_SPACING);
      case NoteDirection.RIGHT: 0 + (3 * Strumline.NOTE_SPACING);
      default: 0;
    }
  }

  /**
   * Apply a small animation which moves the arrow down and fades it in.
   * Only plays at the start of Free Play songs.
   *
   * Note that modifying the offset of the whole strumline won't have the
   * @param arrow The arrow to animate.
   * @param index The index of the arrow in the strumline.
   */
  function fadeInArrow(index:Int, arrow:StrumlineNote):Void
  {
    arrow.y -= 10;
    arrow.alpha = 0.0;
    FlxTween.tween(arrow, {y: arrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * index)});
  }

  public function fadeInArrows():Void
  {
    for (index => arrow in this.strumlineNotes.members.keyValueIterator())
    {
      fadeInArrow(index, arrow);
    }
  }

  function compareNoteData(order:Int, a:SongNoteData, b:SongNoteData):Int
  {
    return FlxSort.byValues(order, a.time, b.time);
  }

  function compareZSprites(order:Int, a:ZSprite, b:ZSprite):Int
  {
    return FlxSort.byValues(order, a?.z, b?.z);
  }

  function compareStrums(order:Int, a:StrumlineNote, b:StrumlineNote):Int
  {
    if (mods != null && zSortMode)
    {
      return FlxSort.byValues(order, a?.z, b?.z);
    }
    else
    {
      return FlxSort.byValues(order, a?.direction, b?.direction);
    }
  }

  public var zSortMode:Bool = true;

  // NoteSprite
  function compareNoteSprites(order:Int, a:NoteSprite, b:NoteSprite):Int
  {
    if (mods != null && zSortMode)
    {
      return FlxSort.byValues(order, a?.z, b?.z);
    }
    else
    {
      return FlxSort.byValues(order, a?.strumTime, b?.strumTime);
    }
  }

  function compareHoldNoteSprites(order:Int, a:SustainTrail, b:SustainTrail):Int
  {
    if (mods != null && zSortMode)
    {
      return FlxSort.byValues(order, a?.z, b?.z);
    }
    else
    {
      return FlxSort.byValues(order, a?.strumTime, b?.strumTime);
    }
  }
}
