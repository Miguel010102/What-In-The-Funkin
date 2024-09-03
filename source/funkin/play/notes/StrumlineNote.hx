package funkin.play.notes;

import funkin.play.notes.notestyle.NoteStyle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import funkin.play.notes.NoteSprite;
import funkin.graphics.ZSprite;
import funkin.graphics.shaders.HSVShader;
import funkin.play.modchartSystem.NoteData;
import funkin.play.modchartSystem.StrumExtraData;
import funkin.graphics.ZProjectSprite_Note;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxBasic;

/**
 * The actual receptor that you see on screen.
 */
class StrumlineNote extends ZSprite
{
  public var mesh:ZProjectSprite_Note;

  var hsvShader:HSVShader;

  public var noteModData:NoteData;
  public var strumExtraModData:StrumExtraData;
  public var strumDistance(default, set):Float;

  function set_strumDistance(value:Float):Float
  {
    this.strumDistance = value;
    if (noteModData != null) noteModData.strumPosition = this.strumDistance;
    return this.strumDistance;
  }

  public var isPlayer(default, null):Bool;

  public var direction(default, set):NoteDirection;

  var confirmHoldTimer:Float = -1;

  static final CONFIRM_HOLD_TIME:Float = 0.1;

  function set_direction(value:NoteDirection):NoteDirection
  {
    this.direction = value;
    return this.direction;
  }

  // for identifying what noteStyle this notesprite is using in hxScript or even lua
  public var noteStyleName:String = "funkin";

  public function new(noteStyle:NoteStyle, isPlayer:Bool, direction:NoteDirection)
  {
    super(0, 0);

    this.isPlayer = isPlayer;

    this.direction = direction;

    noteStyleName = noteStyle.id;
    setup(noteStyle);

    this.animation.callback = onAnimationFrame;
    this.animation.finishCallback = onAnimationFinished;

    // Must be true for animations to play.
    this.active = true;

    noteModData = new NoteData();
    strumExtraModData = new StrumExtraData(this);

    this.hsvShader = new HSVShader();
    this.shader = hsvShader;
    updateStealthGlow();
  }

  // Call this to create a mesh
  public function setupMesh():Void
  {
    if (mesh == null)
    {
      mesh = new ZProjectSprite_Note();
      mesh.spriteGraphic = this;
      mesh.doDraw = false;
      mesh.copySpriteGraphic = false;
    }
    mesh.setUp();
  }

  @:access(flixel.FlxCamera)
  override public function draw():Void
  {
    if (this.alpha <= 0 || !this.visible || !this.alive)
    {
      return;
    }

    if (mesh != null && strumExtraModData?.threeD ?? false)
    {
      mesh.x = noteModData.x;
      mesh.y = noteModData.y;
      mesh.z = noteModData.z;

      mesh.angleX = noteModData.angleX;
      mesh.angleY = noteModData.angleY;
      mesh.angleZ = noteModData.angleZ;

      mesh.scaleX = noteModData.scaleX;
      mesh.scaleY = noteModData.scaleY;
      mesh.scaleZ = noteModData.scaleZ;

      mesh.skewX = noteModData.skewX;
      mesh.skewY = noteModData.skewY;

      mesh.offset = this.offset;
      mesh.cameras = this.cameras;

      mesh.updateTris();

      mesh.drawManual(this.graphic, noteStyleName);
    }
    else
    {
      super.draw();
    }
  }

  // call this to reset stealthGlow back to default values
  public function resetStealthGlow(skipUpdate:Bool = false):Void
  {
    this.stealthGlow = 0.0;
    this.stealthGlowBlue = 1.0;
    this.stealthGlowGreen = 1.0;
    this.stealthGlowRed = 1.0;
    if (!skipUpdate) updateStealthGlow();
  }

  // call this to update the stealthglow on the hsv shader
  public function updateStealthGlow():Void
  {
    this.hsvShader.stealthGlow = stealthGlow;
    this.hsvShader.stealthGlowBlue = stealthGlowBlue;
    this.hsvShader.stealthGlowGreen = stealthGlowGreen;
    this.hsvShader.stealthGlowRed = stealthGlowRed;
  }

  function onAnimationFrame(name:String, frameNumber:Int, frameIndex:Int):Void {}

  function onAnimationFinished(name:String):Void
  {
    // Run a timer before we stop playing the confirm animation.
    // On opponent, this prevent issues with hold notes.
    // On player, this allows holding the confirm key to fall back to press.
    if (name == 'confirm')
    {
      confirmHoldTimer = 0;
    }
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    centerOrigin();

    if (confirmHoldTimer >= 0)
    {
      confirmHoldTimer += elapsed;

      // Ensure the opponent stops holding the key after a certain amount of time.
      if (confirmHoldTimer >= CONFIRM_HOLD_TIME)
      {
        confirmHoldTimer = -1;
        playStatic();
      }
    }
  }

  function setup(noteStyle:NoteStyle):Void
  {
    noteStyle.applyStrumlineFrames(this);
    noteStyle.applyStrumlineAnimations(this, this.direction);

    this.setGraphicSize(Std.int(Strumline.STRUMLINE_SIZE * noteStyle.getStrumlineScale()));
    this.updateHitbox();
    noteStyle.applyStrumlineOffsets(this);

    this.playStatic();
  }

  public function playAnimation(name:String = 'static', force:Bool = false, reversed:Bool = false, startFrame:Int = 0):Void
  {
    this.animation.play(name, force, reversed, startFrame);

    centerOffsets();
    centerOrigin();
    if (mesh != null) mesh.updateCol();
  }

  public function playStatic():Void
  {
    this.active = false;
    this.playAnimation('static', true);
  }

  public function playPress():Void
  {
    this.active = true;
    this.playAnimation('press', true);
  }

  public function playConfirm():Void
  {
    this.active = true;
    this.playAnimation('confirm', true);
  }

  public function isConfirm():Bool
  {
    return getCurrentAnimation().startsWith('confirm');
  }

  public function holdConfirm():Void
  {
    this.active = true;

    if (getCurrentAnimation() == "confirm-hold")
    {
      return;
    }
    else if (getCurrentAnimation() == "confirm")
    {
      if (isAnimationFinished())
      {
        this.confirmHoldTimer = -1;
        this.playAnimation('confirm-hold', false, false);
      }
    }
    else
    {
      this.playAnimation('confirm', false, false);
    }
  }

  /**
   * Returns the name of the animation that is currently playing.
   * If no animation is playing (usually this means the sprite is BROKEN!),
   *   returns an empty string to prevent NPEs.
   */
  public function getCurrentAnimation():String
  {
    if (this.animation == null || this.animation.curAnim == null) return "";
    return this.animation.curAnim.name;
  }

  public function isAnimationFinished():Bool
  {
    return this.animation.finished;
  }

  static final DEFAULT_OFFSET:Int = 13;

  /**
   * Adjusts the position of the sprite's graphic relative to the hitbox.
   */
  function fixOffsets():Void
  {
    // Automatically center the bounding box within the graphic.
    this.centerOffsets();

    if (getCurrentAnimation() == "confirm")
    {
      // Move the graphic down and to the right to compensate for
      // the "glow" effect on the strumline note.
      this.offset.x -= DEFAULT_OFFSET;
      this.offset.y -= DEFAULT_OFFSET;
    }
    else
    {
      this.centerOrigin();
    }
  }
}
