import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/position_component.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:forge2d/forge2d.dart';

/// Abstraction of body component to use it with Forge2D with animated sprite.
/// Looks like [SpriteBodyComponent] but with SpriteAnimationComponent inside.
/// You can use animations with [startAnimation] method or you can set up
/// static sprite with [stopAnimation] if need.
abstract class SpriteAnimationBodyComponent extends BodyComponent {
  PositionComponent spriteComponent;
  SpriteSheet sheet;
  Vector2 size;

  @override
  bool debugMode = false;

  /// Make sure that the [size] of the sprite matches the bounding shape of the
  /// body that is create in createBody()
  SpriteAnimationBodyComponent(this.sheet, this.size);

  /// Create component with animation at the start.
  /// Animation specified with [startAnimRow] of sprite and [stepTime].
  ///
  /// If need, you can call basic constructor and call [startAnimation] like
  /// '''
  /// SpriteAnimationBodyComponent(sheet, size)..startAnimation(0, duration);
  /// '''dart
  SpriteAnimationBodyComponent.animated(
      this.sheet, this.size, int startAnimRow, Duration stepTime) {
    startAnimation(startAnimRow, stepTime);
  }

  /// Create component without animation at the start with sprite specified with
  /// [row] and [column].
  ///
  /// If need, you can call basic constructor and call [stopAnimation] like
  /// '''
  /// SpriteAnimationBodyComponent(sheet, size)..stopAnimation(0, 0);
  /// '''dart
  SpriteAnimationBodyComponent.rest(this.sheet, this.size,
      [int row = 0, int column = 0]) {
    stopAnimation(row, column);
  }

  @override
  void update(double dt) {
    super.update(dt);
    spriteComponent?.update(dt);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    final screenPosition = viewport.getWorldToScreen(body.position);

    if (spriteComponent == null) return;
    spriteComponent
      ..angle = -body.getAngle()
      ..size = size * viewport.scale
      ..x = screenPosition.x
      ..y = screenPosition.y;

    spriteComponent.render(c);
  }

  /// Start animation with removing old component and run sprite animation.
  void startAnimation(int row, Duration stepTime,
      {bool loop = true,
      bool removeOnFinish = false,
      Function completeCallback}) {
    spriteComponent?.remove();

    final a = sheet.createAnimation(
      row: row,
      stepTime: stepTime.inMilliseconds / Duration.millisecondsPerSecond,
      loop: loop,
    );
    if (!loop) {
      a.onComplete = () {
        stopAnimation();
        completeCallback?.call();
      };
    }

    spriteComponent = SpriteAnimationComponent(
      size,
      a,
      removeOnFinish: removeOnFinish,
    )..anchor = Anchor.center;
  }

  /// Stop animation with removing old component and set up simple sprite that
  /// specified with [row] and  [column].
  void stopAnimation([int row = 0, int column = 0]) {
    spriteComponent?.remove();
    spriteComponent =
        SpriteComponent.fromSprite(size, sheet.getSprite(row, column))
          ..anchor = Anchor.center;
  }
}
