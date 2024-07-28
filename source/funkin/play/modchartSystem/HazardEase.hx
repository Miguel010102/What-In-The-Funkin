package funkin.play.modchartSystem;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.math.FlxMath;

/*
  //Custom eases ported from mirin template!
  function bounce(t) return 4 * t * (1 - t) end
  function tri(t) return 1 - abs(2 * t - 1) end
  function bell(t) return inOutQuint(tri(t)) end
  function pop(t) return 3.5 * (1 - t) * (1 - t) * sqrt(t) end
  function tap(t) return 3.5 * t * t * sqrt(1 - t) end
  function pulse(t) return t < .5 and tap(t * 2) or -pop(t * 2 - 1) end
 */
class HazardEase extends FlxEase
{
  public static inline function bounce(t:Float):Float
  {
    return 4 * t * (1 - t);
  }

  public static inline function tri(t:Float):Float
  {
    return 1 - Math.abs(2 * t - 1);
  }

  public static inline function bell(t:Float):Float
  {
    return FlxEase.quintInOut(tri(t));
  }

  public static inline function pop(t:Float):Float
  {
    return 3.5 * (1 - t) * (1 - t) * Math.sqrt(t);
  }

  public static inline function tap(t:Float):Float
  {
    return 3.5 * t * t * Math.sqrt(1 - t);
  }

  public static inline function spike(t:Float):Float
  {
    return Math.exp(-10 * Math.abs(2 * t - 1));
  }

  public static inline function inverse(t:Float):Float
  {
    return t * t * (1 - t) * (1 - t) / (0.5 - t);
  }

  // THIS PROBABLY IS WRONG X.X
  public static inline function pulse(t:Float):Float
  {
    return t < 0.5 ? tap(t * 2) : -pop(t * 2 - 1);
  }

  public static inline function instant(t:Float):Float
  {
    return 1;
  }

  // Out in eases!
  public static inline function quadOutIn(tt:Float):Float
  {
    var t:Float = tt * 2;

    if (t < 1)
    {
      return Math.pow(0.5 - 0.5 * (1 - t), 2);
      // return 0.5 - 0.5 * (1 - t) ^ 2;
    }
    else
    {
      return Math.pow(0.5 + 0.5 * (t - 1), 2);
      // return 0.5 + 0.5 * (t - 1) ^ 2;
    }
  }

  public static inline function sineOutIn(t:Float):Float
  {
    return (t < 0.5 ? FlxEase.sineOut(t * 2) * 0.5 : FlxEase.sineIn(t * 2 - 1) * 0.5 + 0.5);
  }

  public static inline function bounceOutIn(t:Float):Float
  {
    return (t < 0.5 ? FlxEase.bounceOut(t * 2) * 0.5 : FlxEase.bounceIn(t * 2 - 1) * 0.5 + 0.5);
  }

  public static inline function circOutIn(t:Float):Float
  {
    return (t < 0.5 ? FlxEase.circOut(t * 2) * 0.5 : FlxEase.circIn(t * 2 - 1) * 0.5 + 0.5);
  }

  public static inline function expoOutIn(t:Float):Float
  {
    return (t < 0.5 ? FlxEase.expoOut(t * 2) * 0.5 : FlxEase.expoIn(t * 2 - 1) * 0.5 + 0.5);
  }

  public static inline function quintOutIn(tt:Float):Float
  {
    var t:Float = tt * 2;
    if (t < 1)
    {
      // return 0.5 * t ^ 5;
      return Math.pow(0.5 * t, 5);
    }
    else
    {
      return Math.pow(1 - 0.5 * (2 - t), 5);
      // return 1 - 0.5 * (2 - t) ^ 5;
    }
  }

  public static inline function quartOutIn(tt:Float):Float
  {
    var t:Float = tt * 2;
    if (t < 1)
    {
      // return 0.5 - 0.5 * (1 - t) ^ 4;
      return Math.pow(0.5 - 0.5 * (1 - t), 4);
    }
    else
    {
      return Math.pow(0.5 + 0.5 * (t - 1), 4);
      // return 0.5 + 0.5 * (t - 1) ^ 4;
    }
  }

  public static inline function cubeOutIn(tt:Float):Float
  {
    var t:Float = tt * 2;
    if (t < 1)
    {
      // return 0.5 - 0.5 * (1 - t) ^ 3;
      return Math.pow(0.5 - 0.5 * (1 - t), 3);
    }
    else
    {
      return Math.pow(0.5 + 0.5 * (t - 1), 3);
      // return 0.5 + 0.5 * (t - 1) ^ 3;
    }
  }

  // convert notitg / mirin stuff to regular haxe name lmao
  public static inline function outInQuad(t:Float):Float
  {
    return quadOutIn(t);
  }

  public static inline function inOutQuad(t:Float):Float
  {
    return FlxEase.quadInOut(t);
  }

  public static inline function outQuad(t:Float):Float
  {
    return FlxEase.quadOut(t);
  }

  public static inline function inQuad(t:Float):Float
  {
    return FlxEase.quadIn(t);
  }

  public static inline function inOutSine(t:Float):Float
  {
    return FlxEase.sineInOut(t);
  }

  public static inline function outSine(t:Float):Float
  {
    return FlxEase.sineOut(t);
  }

  public static inline function outInSine(t:Float):Float
  {
    return sineOutIn(t);
  }

  public static inline function inSine(t:Float):Float
  {
    return FlxEase.sineIn(t);
  }

  public static inline function outCube(t:Float):Float
  {
    return FlxEase.cubeOut(t);
  }

  public static inline function inCube(t:Float):Float
  {
    return FlxEase.cubeIn(t);
  }

  public static inline function inOutCube(t:Float):Float
  {
    return FlxEase.cubeInOut(t);
  }

  public static inline function outInCube(t:Float):Float
  {
    return cubeOutIn(t);
  }

  public static inline function outCubic(t:Float):Float
  {
    return FlxEase.cubeOut(t);
  }

  public static inline function inCubic(t:Float):Float
  {
    return FlxEase.cubeIn(t);
  }

  public static inline function inOutCubic(t:Float):Float
  {
    return FlxEase.cubeInOut(t);
  }

  public static inline function outInCubic(t:Float):Float
  {
    return cubeOutIn(t);
  }

  public static inline function cubicOut(t:Float):Float
  {
    return FlxEase.cubeOut(t);
  }

  public static inline function cubicIn(t:Float):Float
  {
    return FlxEase.cubeIn(t);
  }

  public static inline function cubicInOut(t:Float):Float
  {
    return FlxEase.cubeInOut(t);
  }

  public static inline function cubicOutIn(t:Float):Float
  {
    return cubeOutIn(t);
  }

  public static inline function outExpo(t:Float):Float
  {
    return FlxEase.expoOut(t);
  }

  public static inline function inExpo(t:Float):Float
  {
    return FlxEase.expoIn(t);
  }

  static inline function inOutExpo(t:Float):Float
  {
    return FlxEase.expoInOut(t);
  }

  static inline function outInExpo(t:Float):Float
  {
    return expoOutIn(t);
  }

  static inline function outBounce(t:Float):Float
  {
    return FlxEase.bounceOut(t);
  }

  static inline function inBounce(t:Float):Float
  {
    return FlxEase.bounceIn(t);
  }

  static inline function inOutBounce(t:Float):Float
  {
    return FlxEase.bounceInOut(t);
  }

  static inline function outInBounce(t:Float):Float
  {
    return bounceOutIn(t);
  }

  static inline function outCirc(t:Float):Float
  {
    return FlxEase.circOut(t);
  }

  static inline function inCirc(t:Float):Float
  {
    return FlxEase.circIn(t);
  }

  static inline function inOutCirc(t:Float):Float
  {
    return FlxEase.circInOut(t);
  }

  static inline function outInCirc(t:Float):Float
  {
    return circOutIn(t);
  }

  static inline function outInQuint(t:Float):Float
  {
    return quintOutIn(t);
  }

  static inline function outQuint(t:Float):Float
  {
    return FlxEase.quintOut(t);
  }

  static inline function inQuint(t:Float):Float
  {
    return FlxEase.quintIn(t);
  }

  static inline function inOutQuint(t:Float):Float
  {
    return FlxEase.quintInOut(t);
  }

  static inline function inOutQuart(t:Float):Float
  {
    return FlxEase.quartInOut(t);
  }

  static inline function outInQuart(t:Float):Float
  {
    return quartOutIn(t);
  }

  static inline function inQuart(t:Float):Float
  {
    return FlxEase.quartIn(t);
  }

  static inline function outQuart(t:Float):Float
  {
    return FlxEase.quartOut(t);
  }

  static inline function outElastic(t:Float):Float
  {
    return FlxEase.elasticOut(t);
  }

  static inline function inElastic(t:Float):Float
  {
    return FlxEase.elasticIn(t);
  }

  static inline function inOutElastic(t:Float):Float
  {
    return FlxEase.elasticInOut(t);
  }

  static inline function outBack(t:Float):Float
  {
    return FlxEase.backOut(t);
  }

  static inline function inBack(t:Float):Float
  {
    return FlxEase.backIn(t);
  }

  static inline function inOutBack(t:Float):Float
  {
    return FlxEase.backInOut(t);
  }

  /** @since 4.3.0 */
  static inline function inSmoothStep(t:Float):Float
  {
    return FlxEase.smoothStepIn(t);
  }

  /** @since 4.3.0 */
  static inline function outSmoothStep(t:Float):Float
  {
    return FlxEase.smoothStepOut(t);
  }

  /** @since 4.3.0 */
  static inline function inOutSmoothStep(t:Float):Float
  {
    return FlxEase.smoothStepInOut(t);
  }

  /** @since 4.3.0 */
  static inline function inSmootherStep(t:Float):Float
  {
    return FlxEase.smootherStepIn(t);
  }

  /** @since 4.3.0 */
  static inline function outSmootherStep(t:Float):Float
  {
    return FlxEase.smootherStepOut(t);
  }

  /** @since 4.3.0 */
  static inline function inOutSmootherStep(t:Float):Float
  {
    return FlxEase.smootherStepInOut(t);
  }
}
