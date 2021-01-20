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

  final double originalHealth;
  final zero = Vector2.zero();
  double health;

  /// Direction of jumping: 1 - right, -1 - left
  int jumpDirection = 1;

  LamaComponent(
    SpriteSheet sheet,
    this.startPosition, {
    this.originalHealth = 100.0,
  }) : super.rest(sheet, Vector2(24, 36)) {
    this.health = originalHealth;
  }

  /// Creates a edge shape (left or right side) depends on direction.
  /// This helps with avoiding contacts between bullet and lama when it's dead.
  Shape get deadShape {
    final left = Vector2(-size.x * (-jumpDirection), size.y) / 2;
    final right = Vector2(-size.x * (-jumpDirection), -size.y) / 2;
    return EdgeShape()..set(left, right);
  }

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
      ..density = 0.0
      ..friction = 1.0;

    final def = BodyDef()
      ..userData = this
      ..position = startPosition
      ..type = BodyType.DYNAMIC;
    return world.createBody(def)
      ..createFixture(fix)
      ..setMassData(MassData()..mass = 0.8);
  }

  @override
  void update(double dt) {
    if (isDead) {
      isJumping = false;
      if (applyDeadReaction) {
        applyDeadReaction = false;
        while (body.fixtures.isNotEmpty) {
          body.destroyFixture(body.fixtures.first);
        }
        body.createFixture(FixtureDef()..shape = deadShape);
        body.setTransform(body.position, -1 * jumpDirection * math.pi / 2);
        body.applyLinearImpulse(Vector2(0, 30));
      }
    }
    if (isDead && body.linearVelocity == zero) {
      body.setType(BodyType.KINEMATIC);
    }

    /// Allow jump only when lama stay on ground
    if (isJumping && body.linearVelocity == zero) {
      isJumping = false;
    }
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    if (isDead) return;

    final padding = Vector2(3 * viewport.scale, 0);
    final origSize = size * viewport.scale - (padding * 2);

    final healthPaint = Paint()
      ..color = Color(0xFF00AF00)
      ..strokeWidth = 2;
    final lessHealthPaint = Paint()
      ..color = Color(0xFF9F9F9F)
      ..strokeWidth = 2;

    final part = health / originalHealth;
    final partPoint = Vector2(origSize.x * part, 0) + padding;

    c.drawLine(padding.toOffset(), partPoint.toOffset(), healthPaint);
    c.drawLine(partPoint.toOffset(),
        Vector2(origSize.x + padding.x, 0).toOffset(), lessHealthPaint);
  }

  void jump() {
    if (isDead) return;
    if (!isJumping) {
      isJumping = true;
      startAnimation(
        jumpDirection == 1 ? 0 : 1,
        Duration(milliseconds: 70),
        loop: false,
      );
    }
  }

  void stay() {
    stopAnimation(jumpDirection == 1 ? 0 : 1, 0);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (isJumping || isDead) return;
    if (event.id == 1) {
      jumpDirection = -1;
      jump();
    } else if (event.id == 2) {
      jumpDirection = 1;
      jump();
    }
    if (event.id == 1 || event.id == 2) {
      body.applyLinearImpulse(Vector2(10.0 * jumpDirection, 8));
    }
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {}

  void damageLama(double damage) {
    health -= damage;
    if (health <= 0.0) {
      health = 0.0;
      _killLama();
    }
  }

  void _killLama() {
    isDead = true;
    applyDeadReaction = true;
    setOverridePaint(Paint()..color = Color(0x5FFFFFFF));
  }
}
