import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_events.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/spritesheet.dart';
import 'package:forge2d/forge2d.dart';
import 'package:game_testing/base_components/sprite_anim_body_component.dart';
import 'package:vector_math/vector_math_64.dart';

class LamaComponent extends SpriteAnimationBodyComponent with JoystickListener {
  final Vector2 startPosition;
  bool isJumping = false;

  LamaComponent(SpriteSheet sheet, this.startPosition)
      : super.rest(sheet, Vector2(24, 36));

  @override
  Body createBody() {
    final shape = PolygonShape();
    final vertices = [
      Vector2(-size.x, size.y) / 2,
      Vector2(size.x, size.y) / 2,
      Vector2(size.x, -size.y) / 2,
      Vector2(-size.x, -size.y) / 2,
    ];
    shape.set(vertices, vertices.length);

    final fix = FixtureDef()
      ..shape = shape
      ..restitution = 0.0
      ..density = 1.0
      ..friction = 0.2;

    final def = BodyDef()
      ..userData = this
      ..position = startPosition
      ..type = BodyType.DYNAMIC;
    return world.createBody(def)..createFixture(fix);
  }

  void jump() {
    if (!isJumping) {
      isJumping = true;
      startAnimation(
        0,
        Duration(milliseconds: 30),
        loop: false,
        completeCallback: () => isJumping = false,
      );
    }
  }

  void stay() {
    stopAnimation();
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.id == 1) {
      body.setTransform(body.position + Vector2(-5, 0), 0.0);
      jump();
    } else if (event.id == 2) {
      body.setTransform(body.position + Vector2(5, 0), 0.0);
      jump();
    }
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {}
}
