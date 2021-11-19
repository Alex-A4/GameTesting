import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:forge2d/forge2d.dart';

/// Abstraction of body component to use it with Forge2D with animated sprite.
/// Looks like [SpriteBodyComponent] but with SpriteAnimationComponent inside.
/// You can use animations with [startAnimation] method or you can set up
/// static sprite with [stopAnimation] to display rest state if need.
abstract class SpriteAnimationBodyComponent extends BodyComponent {
  /// Child component that draws ui. It's a [_spriteComponent] or [SpriteAnimationComponent].
  PositionComponent? _spriteComponent;

  /// Sprite sheet which uses to display image
  SpriteSheet sheet;

  /// Size of sprite component
  Vector2 size;

  /// Anchor point for this component. This is where flame "grabs it".
  Anchor anchor = Anchor.center;

  @override
  bool debugMode = false;

  Paint? overridePaint;

  /// Create component with animation at the start.
  /// Animation specified with [startAnimRow] of sprite and [stepTime].
  ///
  /// If need, you can call basic constructor and call [startAnimation] like
  /// '''
  /// SpriteAnimationBodyComponent(sheet, size)..startAnimation(0, duration);
  /// '''dart
  SpriteAnimationBodyComponent.animated(
    this.sheet,
    this.size,
    int startAnimRow,
    Duration stepTime, {
    Anchor? anchor,
    bool loop = true,
    bool removeOnFinish = false,
    Function? completeCallback,
  }) {
    if (anchor != null) this.anchor = anchor;
    startAnimation(
      startAnimRow,
      stepTime,
      loop: loop,
      removeOnFinish: removeOnFinish,
      completeCallback: completeCallback,
    );
  }

  /// Create component without animation at the start with sprite specified with
  /// [row] and [column].
  ///
  /// If need, you can call basic constructor and call [stopAnimation] like
  /// '''
  /// SpriteAnimationBodyComponent(sheet, size)..stopAnimation(0, 0);
  /// '''dart
  SpriteAnimationBodyComponent.rest(
    this.sheet,
    this.size, {
    int row = 0,
    int column = 0,
    Anchor? anchor,
  }) {
    if (anchor != null) this.anchor = anchor;
    stopAnimation(row, column);
  }

  @override
  void update(double dt) {
    _spriteComponent?.update(dt);
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    if (_spriteComponent != null) {
      final screenPosition = gameRef.worldToScreen(body.position.clone());
      _spriteComponent!
        ..angle = -body.angle
        ..size = size * camera.zoom
        ..position = screenPosition;

      _spriteComponent!.render(c);
    }
    super.render(c);
  }

  /// Start animation with removing old component and run sprite animation.
  /// [row] is the row of sprite which should be animated.
  /// [stepTime] is time between two frames.
  /// [loop] - flag for animation is this should be played without pause
  /// [removeOnFinish] - flag for sprite animation component which will remove
  ///   component from the tree after animation completes.
  /// [completeCallback] - callback that will be called after animation completes
  /// if it's not looped. Callback WILL NOT BE called if [loop] is true.
  ///
  /// If [loop] is false, then animation will be stopped on last frame. To change
  /// it to rest state, add [completeCallback] where you will call [stopAnimation]
  /// or [startAnimation].
  /// '''
  /// component.startAnimation(0, duration, loop: false, completeCallback:
  ///   () => component.stopAnimation()
  /// );
  /// '''dart
  void startAnimation(
    int row,
    Duration stepTime, {
    bool loop = true,
    bool removeOnFinish = false,
    Function? completeCallback,
  }) {
    final a = sheet.createAnimation(
      row: row,
      stepTime: stepTime.inMilliseconds / Duration.millisecondsPerSecond,
      loop: loop,
    );
    if (!loop && completeCallback != null) {
      a.onComplete = () => completeCallback();
    }

    _spriteComponent = SpriteAnimationComponent(
      size: size,
      animation: a,
      removeOnFinish: removeOnFinish,
    )
      ..anchor = anchor
      ..paint = overridePaint ?? BasicPalette.white.paint();
  }

  /// Stop animation with removing old component and set up simple sprite that
  /// specified with [row] and  [column].
  /// After call this method, sprite will display simple sprite with rest state.
  void stopAnimation([int row = 0, int column = 0]) {
    _spriteComponent =
        SpriteComponent(size: size, sprite: sheet.getSprite(row, column))
          ..anchor = anchor
          ..paint = overridePaint ?? BasicPalette.white.paint();
  }

  void setOverridePaint(Paint paint) {
    this.overridePaint = paint;
    if (_spriteComponent == null) return;
    if (_spriteComponent is SpriteComponent) {
      (_spriteComponent as SpriteComponent).paint = paint;
    } else {
      (_spriteComponent as SpriteAnimationComponent).paint = paint;
    }
  }
}
