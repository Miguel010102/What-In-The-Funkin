package funkin.graphics;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import funkin.graphics.ZSprite;
import funkin.play.modchartSystem.ModConstants;
import lime.math.Vector2;
import openfl.geom.Matrix;
import openfl.display.TriangleCulling;
import openfl.geom.Vector3D;

class ZProjectSprite_Note extends FlxSprite
{
  public var z:Float = 0.0;

  // If set, will reference this sprites graphic! Very useful for animations!
  public var spriteGraphic(default, set):FlxSprite;

  function set_spriteGraphic(value:FlxSprite):FlxSprite
  {
    spriteGraphic = value;
    return spriteGraphic;
  }

  public var projectionEnabled:Bool = true;
  public var autoOffset:Bool = false;

  public var originalWidthHeight:Vector2;

  public var angleX:Float = 0;
  public var angleY:Float = 0;
  public var angleZ:Float = 0;

  public var scaleX:Float = 1;
  public var scaleY:Float = 1;
  public var scaleZ:Float = 1;

  public var skewX:Float = 0;
  public var skewY:Float = 0;
  public var skewZ:Float = 0;

  // in %
  public var skewX_offset:Float = 0.5;
  public var skewY_offset:Float = 0.5;
  public var skewZ_offset:Float = 0.5;

  public var moveX:Float = 0;
  public var moveY:Float = 0;
  public var moveZ:Float = 0;

  public var fovOffsetX:Float = 0;
  public var fovOffsetY:Float = 0;
  // public var fovOffsetZ:Float = 0;
  public var pivotOffsetX:Float = 0;
  public var pivotOffsetY:Float = 0;
  public var pivotOffsetZ:Float = 0;

  public var fov:Float = 90;

  /**
   * A `Vector` of floats where each pair of numbers is treated as a coordinate location (an x, y pair).
   */
  public var vertices:DrawData<Float> = new DrawData<Float>();

  /**
   * A `Vector` of integers or indexes, where every three indexes define a triangle.
   */
  public var indices:DrawData<Int> = new DrawData<Int>();

  /**
   * A `Vector` of normalized coordinates used to apply texture mapping.
   */
  public var uvtData:DrawData<Float> = new DrawData<Float>();

  public var processedGraphic:FlxGraphic;

  // custom setter to prevent values below 0, cuz otherwise we'll devide by 0!
  public var subdivisions(default, set):Int = 2;

  function set_subdivisions(value:Int):Int
  {
    if (value < 0) value = 0;
    subdivisions = value;
    return subdivisions;
  }

  public function new(?x:Float = 0, ?y:Float = 0, ?simpleGraphic:FlxGraphicAsset)
  {
    super(x, y, simpleGraphic);
    if (simpleGraphic != null) setUp();
  }

  public function setUp():Void
  {
    this.x = 0;
    this.y = 0;
    this.z = 0;

    if (spriteGraphic != null)
    {
      spriteGraphic.x = 0;
      spriteGraphic.y = 0;
    }

    var nextRow:Int = (subdivisions + 1 + 1);

    this.active = true; // This NEEDS to be true for the note to be drawn!
    updateColorTransform();
    var noteIndices:Array<Int> = [];
    for (x in 0...subdivisions + 1)
    {
      for (y in 0...subdivisions + 1)
      {
        // indices are created from top to bottom, going along the x axis each cycle.
        var funny:Int = y + (x * nextRow);
        noteIndices.push(0 + funny);
        noteIndices.push(nextRow + funny);
        noteIndices.push(1 + funny);

        noteIndices.push(nextRow + funny);
        noteIndices.push(1 + funny);
        noteIndices.push(nextRow + 1 + funny);
      }
    }
    indices = new DrawData<Int>(noteIndices.length, true, noteIndices);

    // UV coordinates are normalized, so they range from 0 to 1.
    var i:Int = 0;
    for (x in 0...subdivisions + 2) // x
    {
      for (y in 0...subdivisions + 2) // y
      {
        var xPercent:Float = x / (subdivisions + 1);
        var yPercent:Float = y / (subdivisions + 1);
        uvtData[i * 2] = xPercent;
        uvtData[i * 2 + 1] = yPercent;
        i++;
      }
    }
    updateTris();
  }

  public function updateTris(debugTrace:Bool = false):Void
  {
    var w:Float = spriteGraphic?.frameWidth ?? frameWidth;
    var h:Float = spriteGraphic?.frameHeight ?? frameHeight;

    var i:Int = 0;
    for (x in 0...subdivisions + 2) // x
    {
      for (y in 0...subdivisions + 2) // y
      {
        var point2D:Vector2;
        var point3D:Vector3D = new Vector3D(0, 0, 0);
        point3D.x = (w / (subdivisions + 1)) * x;
        point3D.y = (h / (subdivisions + 1)) * y;

        // skew funny
        var xPercent:Float = x / (subdivisions + 1);
        var yPercent:Float = y / (subdivisions + 1);
        // For some reason, we need a 0.5 offset for this???????????????????
        var xPercent_SkewOffset:Float = xPercent - skewY_offset - 0.5;
        var yPercent_SkewOffset:Float = yPercent - skewX_offset - 0.5;
        // Keep math the same as skewedsprite for parity reasons.
        if (skewX != 0) // Small performance boost from this if check to avoid the tan math lol?
          point3D.x += yPercent_SkewOffset * Math.tan(skewX * FlxAngle.TO_RAD) * h;
        if (skewY != 0) //
          point3D.y += xPercent_SkewOffset * Math.tan(skewY * FlxAngle.TO_RAD) * w;
        if (skewZ != 0) //
          point3D.z += yPercent_SkewOffset * Math.tan(skewZ * FlxAngle.TO_RAD) * h;

        // scale
        var newWidth:Float = (scaleX - 1) * (xPercent - 0.5);
        point3D.x += (newWidth) * w;
        newWidth = (scaleY - 1) * (yPercent - 0.5);
        point3D.y += (newWidth) * h;

        point2D = applyPerspective(point3D, xPercent, yPercent);

        if (originalWidthHeight != null && autoOffset)
        {
          point2D.x += (originalWidthHeight.x - spriteGraphic.frameWidth) / 2;
          point2D.y += (originalWidthHeight.y - spriteGraphic.frameHeight) / 2;
        }

        vertices[i * 2] = point2D.x;
        vertices[i * 2 + 1] = point2D.y;
        i++;
      }
    }

    // if (debugTrace) trace("\nverts: \n" + vertices + "\n");

    culled = false;

    // temp fix for now I guess lol?
    if (spriteGraphic != null)
    {
      spriteGraphic.flipX = false;
      spriteGraphic.flipY = false;
    }

    // TODO -> Swap this so that it instead just breaks out of the function if it detects a difference between two points as being negative!
    switch (hazCullMode)
    {
      case "always_positive" | "always_negative":
        if (spriteGraphic != null)
        {
          spriteGraphic.flipX = hazCullMode == "always_negative" ? true : false;
          spriteGraphic.flipY = hazCullMode == "always_negative" ? true : false;
        }

        var xFlipCheck_vertTopLeftX = vertices[0];
        var xFlipCheck_vertBottomRightX = vertices[vertices.length - 1 - 1];
        if (xFlipCheck_vertTopLeftX >= xFlipCheck_vertBottomRightX)
        {
          if (spriteGraphic != null)
          {
            spriteGraphic.flipX = !spriteGraphic.flipX;
          }
          else
          {
            culled = true;
          }
        }
        else
        { // y check
          xFlipCheck_vertTopLeftX = vertices[1];
          xFlipCheck_vertBottomRightX = vertices[vertices.length - 1];
          if (xFlipCheck_vertTopLeftX >= xFlipCheck_vertBottomRightX)
          {
            if (spriteGraphic != null)
            {
              spriteGraphic.flipY = !spriteGraphic.flipY;
            }
            else
            {
              culled = true;
            }
          }
        }

      case "back" | "positive":
        var xFlipCheck_vertTopLeftX = vertices[0];
        var xFlipCheck_vertBottomRightX = vertices[vertices.length - 1 - 1];
        if (xFlipCheck_vertTopLeftX >= xFlipCheck_vertBottomRightX) culled = true;
        else
        { // y check
          xFlipCheck_vertTopLeftX = vertices[1];
          xFlipCheck_vertBottomRightX = vertices[vertices.length - 1];
          if (xFlipCheck_vertTopLeftX >= xFlipCheck_vertBottomRightX) culled = true;
        }
      case "front" | "negative":
        var xFlipCheck_vertTopLeftX = vertices[0];
        var xFlipCheck_vertBottomRightX = vertices[vertices.length - 1 - 1];
        if (xFlipCheck_vertTopLeftX >= xFlipCheck_vertBottomRightX) culled = true;
        else
        { // y check
          xFlipCheck_vertTopLeftX = vertices[1];
          xFlipCheck_vertBottomRightX = vertices[vertices.length - 1];
          if (xFlipCheck_vertTopLeftX >= xFlipCheck_vertBottomRightX) culled = true;
        }
        culled = !culled;
      case "always":
        culled = true;
      default:
        culled = false;
    }
  }

  public var cullMode = TriangleCulling.NONE;
  public var hazCullMode:String = "none";

  var culled:Bool = false;

  @:access(flixel.FlxCamera)
  override public function draw():Void
  {
    return; // do nothing lmfao, moved to drawManual just to be safe cuz idk if it will double draw or not (I doubt but, you never know with Flixel)
  }

  public function drawManual():Void
  {
    if (culled || alpha < 0 || vertices == null || indices == null || processedGraphic == null || uvtData == null || _point == null || offset == null)
    {
      return;
    }

    if (spriteGraphic != null)
    {
      spriteGraphic.update(FlxG.elapsed);
      spriteGraphic.updateFramePixels();
    }

    if (alpha < 0 || processedGraphic == null || _point == null || offset == null)
    {
      return;
    }

    for (camera in cameras)
    {
      if (!camera.visible || !camera.exists) continue;
      // if (!isOnScreen(camera)) continue; // TODO: Update this code to make it work properly.

      // memory leak with drawTriangles :c

      // getScreenPosition(_point, camera).subtractPoint(offset);
      getScreenPosition(_point, camera);
      camera.drawTriangles(processedGraphic, vertices, indices, uvtData, null, _point, blend, true, antialiasing, colorTransform,
        spriteGraphic?.shader ?? null, cullMode);
      // camera.drawTriangles(processedGraphic, vertices, indices, uvtData, null, _point, blend, true, antialiasing);
    }

    #if FLX_DEBUG
    if (FlxG.debugger.drawDebug) drawDebug();
    #end
  }

  override public function destroy():Void
  {
    vertices = null;
    indices = null;
    uvtData = null;
    spriteGraphic = null;
    if (processedGraphic != null) processedGraphic.destroy();

    super.destroy();
  }

  // since updateColorTransform isn't public lol?
  public function updateCol():Void
  {
    updateColorTransform();
  }

  // Call this when updating the animation! This is because different animations can have different sprite sizes!
  override function updateColorTransform():Void
  {
    super.updateColorTransform();
    // Clear old graphic
    if (processedGraphic != null) processedGraphic.destroy();

    if (spriteGraphic != null)
    {
      spriteGraphic.updateFramePixels();
      processedGraphic = FlxGraphic.fromBitmapData(spriteGraphic.framePixels, false);
      processedGraphic.bitmap.colorTransform(processedGraphic.bitmap.rect, colorTransform);

      if (originalWidthHeight == null)
      {
        originalWidthHeight = new Vector2(spriteGraphic.frameWidth, spriteGraphic.frameHeight);
      }
    }
    else if (graphic != null)
    {
      processedGraphic = FlxGraphic.fromGraphic(graphic, true);
      processedGraphic.bitmap.colorTransform(processedGraphic.bitmap.rect, colorTransform);
    }
  }

  public function applyPerspective(pos:Vector3D, xPercent:Float = 0, yPercent:Float = 0):Vector2
  {
    var w:Float = spriteGraphic?.frameWidth ?? frameWidth;
    var h:Float = spriteGraphic?.frameHeight ?? frameHeight;

    var pos_modified:Vector3D = new Vector3D(pos.x, pos.y, pos.z);

    var rotateModPivotPoint:Vector2 = new Vector2(w / 2, h / 2);
    rotateModPivotPoint.x += pivotOffsetX;
    rotateModPivotPoint.y += pivotOffsetY;
    var thing:Vector2 = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(pos_modified.x, pos_modified.y), angleZ);
    pos_modified.x = thing.x;
    pos_modified.y = thing.y;

    rotateModPivotPoint = new Vector2(w / 2, 0);
    rotateModPivotPoint.x += pivotOffsetX;
    rotateModPivotPoint.y += pivotOffsetZ;
    thing = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(pos_modified.x, pos_modified.z), angleY);
    pos_modified.x = thing.x;
    pos_modified.z = thing.y;

    rotateModPivotPoint = new Vector2(0, h / 2);
    rotateModPivotPoint.x += pivotOffsetZ;
    rotateModPivotPoint.y += pivotOffsetY;
    thing = ModConstants.rotateAround(rotateModPivotPoint, new Vector2(pos_modified.z, pos_modified.y), angleX);
    pos_modified.z = thing.x;
    pos_modified.y = thing.y;

    // Apply offset here before it gets affected by z projection!
    pos_modified.x -= offset.x;
    pos_modified.y -= offset.y;

    pos_modified.x += moveX;
    pos_modified.y += moveY;
    pos_modified.z += moveZ;

    if (projectionEnabled)
    {
      pos_modified.x += this.x;
      pos_modified.y += this.y;
      pos_modified.z += this.z; // ?????

      pos_modified.x += fovOffsetX;
      pos_modified.y += fovOffsetY;
      pos_modified.z *= 0.001;

      pos_modified = perspectiveMath_OLD(pos_modified, 0, 0);

      pos_modified.x -= this.x;
      pos_modified.y -= this.y;
      pos_modified.z -= this.z * 0.001; // ?????

      pos_modified.x -= fovOffsetX;
      pos_modified.y -= fovOffsetY;
      return new Vector2(pos_modified.x, pos_modified.y);
    }
    else
    {
      return new Vector2(pos_modified.x, pos_modified.y);
    }
  }

  public var zNear:Float = 0.0;
  public var zFar:Float = 100.0;

  // https://github.com/TheZoroForce240/FNF-Modcharting-Tools/blob/main/source/modcharting/ModchartUtil.hx
  public function perspectiveMath_OLD(pos:Vector3D, offsetX:Float = 0, offsetY:Float = 0):Vector3D
  {
    try
    {
      var _FOV:Float = this.fov;

      _FOV *= (Math.PI / 180.0);

      var newz:Float = pos.z - 1;
      var zRange:Float = zNear - zFar;
      var tanHalfFOV:Float = 1;
      var dividebyzerofix:Float = FlxMath.fastCos(_FOV * 0.5);
      if (dividebyzerofix != 0)
      {
        tanHalfFOV = FlxMath.fastSin(_FOV * 0.5) / dividebyzerofix;
      }

      if (pos.z > 1) newz = 0;

      var xOffsetToCenter:Float = pos.x - (FlxG.width * 0.5);
      var yOffsetToCenter:Float = pos.y - (FlxG.height * 0.5);

      var zPerspectiveOffset:Float = (newz + (2 * zFar * zNear / zRange));

      // divide by zero check
      if (zPerspectiveOffset == 0) zPerspectiveOffset = 0.001;

      xOffsetToCenter += (offsetX * -zPerspectiveOffset);
      yOffsetToCenter += (offsetY * -zPerspectiveOffset);

      xOffsetToCenter += (0 * -zPerspectiveOffset);
      yOffsetToCenter += (0 * -zPerspectiveOffset);

      var xPerspective:Float = xOffsetToCenter * (1 / tanHalfFOV);
      var yPerspective:Float = yOffsetToCenter * tanHalfFOV;
      xPerspective /= -zPerspectiveOffset;
      yPerspective /= -zPerspectiveOffset;

      pos.x = xPerspective + (FlxG.width * 0.5);
      pos.y = yPerspective + (FlxG.height * 0.5);
      pos.z = zPerspectiveOffset;
      return pos;
    }
    catch (e)
    {
      return pos;
      trace("OH GOD OH FUCK IT NEARLY DIED CUZ OF: \n" + e.toString());
    }
  }
}
