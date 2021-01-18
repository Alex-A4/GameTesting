import 'dart:math' as math;
import 'dart:ui';

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
  bool isDead = false;
  bool applyDeadReaction = false;

  /// Direction of jumping: 1 - right, -1 - left
  int jumpDirection = 1;

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
    return world.createBody(def)
      ..createFixture(fix)
      ..setMassData(MassData()..mass = 10.0);
  }

  @override
  void update(double dt) {
    if (isDead) {
      isJumping = false;
      if (applyDeadReaction) {
        applyDeadReaction = false;
        body.setTransform(body.position, -1 * jumpDirection * math.pi / 2);
        body.applyLinearImpulse(Vector2(0, 30));
      } else {
        if (body.angularVelocity == 0.0 &&
            body.linearVelocity == Vector2.zero()) {
          body.setType(BodyType.KINEMATIC);
        }
      }
    }

    if (isJumping) {
      body.setTransform(
        Vector2(body.position.x + jumpDirection * 30.0 * dt, body.position.y),
        0,
      );
    }
    super.update(dt);
  }

  void jump() {
    if (isDead) return;
    if (!isJumping) {
      isJumping = true;
      startAnimation(
        jumpDirection == 1 ? 0 : 1,
        Duration(milliseconds: 50),
        loop: false,
        completeCallback: () => isJumping = false,
      );
    }
  }

  void stay() {
    stopAnimation(jumpDirection == 1 ? 0 : 1, 0);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.id == 1) {
      jumpDirection = -1;
      jump();
    } else if (event.id == 2) {
      jumpDirection = 1;
      jump();
    }
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {}

  void killLama() {
    isDead = true;
    applyDeadReaction = true;
    setOverridePaint(Paint()..color = Color(0x5FFFFFFF));
  }
}
