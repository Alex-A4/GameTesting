import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/extensions/vector2.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/timer.dart';
import 'package:forge2d/forge2d.dart' hide Timer;
import 'package:game_testing/base_components/sprite_anim_body_component.dart';
import 'package:vector_math/vector_math_64.dart';

class LamaComponent extends SpriteAnimationBodyComponent {
  final Vector2 startPosition;
  final double damage;
  final Duration attackCooldown;

  Timer attackTimer;

  double jumpPower;
  bool isJumping = false;

  bool isDead = false;
  bool applyDeadReaction = false;

  /// Blink time in seconds and blink direction.
  /// True - from fully opaque to transparent, false - otherwise
  double blinkTime;
  bool blinkDirection = true;

  final double originalHealth;
  static final zero = Vector2.zero();
  double health;

  /// Direction of jumping: 1 - right, -1 - left
  int jumpDirection = -1;

  LamaComponent(
    SpriteSheet sheet,
    this.startPosition, {
    this.attackCooldown = const Duration(milliseconds: 300),
    this.originalHealth = 100.0,
    this.damage = 5.0,
    this.jumpPower,
  }) : super.rest(sheet, Vector2(24, 36)) {
    this.health = originalHealth;
    this.jumpPower ??= 1;
    attackTimer = Timer(
      attackCooldown.inMilliseconds / Duration.millisecondsPerSecond,
    );
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
      ..userData = this
      ..shape = shape
      ..restitution = 0.0
      ..density = 0.0
      ..friction = 1.0;
    fix.filter.groupIndex = -1;

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
    if (attackTimer.isRunning()) attackTimer.update(dt);
    if (isDead) {
      isJumping = false;
      if (applyDeadReaction) {
        applyDeadReaction = false;
        while (body.fixtures.isNotEmpty) {
          body.destroyFixture(body.fixtures.first);
        }
        body.setTransform(body.position, -1 * jumpDirection * math.pi / 2);
        body.setType(BodyType.KINEMATIC);
        blinkTime = 3.0;
      }
    }

    if (blinkTime != null && blinkTime > 0.0) {
      setBlink(dt);
    } else if (blinkTime != null && blinkTime <= 0.0) {
      gameRef.remove(this);
    }

    /// Allow jump only when lama stay on ground
    if (isJumping && body.linearVelocity == zero) {
      isJumping = false;
    }
    if (!isJumping) jump();

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
      body.applyLinearImpulse(
          Vector2(10.0 * jumpDirection * jumpPower, 8 * jumpPower));
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
  }

  /// Set up sprite's blink effect
  void setBlink(double dt) {
    final diff = blinkTime - blinkTime.toInt();

    final opacity = (blinkDirection ? diff : 1.0 - diff) * 0.5;
    setOverridePaint(Paint()..color = Color.fromRGBO(255, 255, 255, opacity));
    if (diff < 0.01) {
      blinkDirection = !blinkDirection;
      blinkTime = blinkTime.toInt().toDouble();
    }
    blinkTime -= dt;
  }

  /// Is the lama can attack
  bool canAttack() => !attackTimer.isRunning();

  /// Make attack and run attack cooldown
  void makeAttack() {
    assert(canAttack());
    attackTimer.start();
  }
}
