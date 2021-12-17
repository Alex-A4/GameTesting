import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flame/timer.dart';
import 'package:forge2d/forge2d.dart' hide Timer;
import 'package:game_testing/base_components/sprite_anim_body_component.dart';
import 'package:game_testing/game/game.dart';
import 'package:game_testing/models/lama_model.dart';

class LamaComponent extends SpriteAnimationBodyComponent {
  final Vector2 startPosition;
  final Lama lama;

  late Timer attackTimer;

  bool _isJumping = false;

  bool _isDead = false;

  bool get isDead => _isDead;
  bool _applyDeadReaction = false;

  /// Blink time in seconds and blink direction.
  /// True - from fully opaque to transparent, false - otherwise
  double? _blinkTime;
  bool _blinkDirection = true;

  static final zero = Vector2.zero();
  late double health;

  /// Direction of jumping: 1 - right, -1 - left
  final int _jumpDirection = -1;

  LamaComponent(
    SpriteSheet sheet,
    this.startPosition,
    double scale, {
    Lama? lama,
    Vector2? sheetSize,
  })  : lama = lama ?? Lama.simple(),
        super.rest(sheet, (sheetSize ?? Vector2(24, 36)) / scale * 2) {
    attackTimer = Timer(
      this.lama.attackCooldown.inMilliseconds / Duration.millisecondsPerSecond,
      repeat: true,
      onTick: () => _implementAttack(),
      autoStart: false,
    );
    health = this.lama.health;
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
    shape.set(vertices);

    final fix = FixtureDef(shape)
      ..userData = this
      ..restitution = 0.0
      ..density = 0.0
      ..friction = 1.0;
    fix.filter.groupIndex = -1;

    final def = BodyDef()
      ..userData = this
      ..position = startPosition
      ..type = BodyType.dynamic;
    return world.createBody(def)
      ..createFixture(fix)
      ..setMassData(MassData()..mass = 0.8);
  }

  @override
  void update(double dt) {
    if (attackTimer.isRunning() && !_isDead) {
      attackTimer.update(dt);
    }
    if (_isDead) {
      _isJumping = false;
      if (_applyDeadReaction) {
        _applyDeadReaction = false;
        while (body.fixtures.isNotEmpty) {
          body.destroyFixture(body.fixtures.first);
        }
        body.setTransform(body.position, -1 * _jumpDirection * math.pi / 2);
        body.setType(BodyType.kinematic);
        _blinkTime = 3.0;
      }
    }

    if (_blinkTime != null && _blinkTime! > 0.0) {
      setBlink(dt);
    } else if (_blinkTime != null && _blinkTime! <= 0.0) {
      gameRef.remove(this);
    }

    /// Allow jump only when lama stay on ground
    if (_isJumping && body.linearVelocity == zero) {
      _isJumping = false;
    }
    if (!_isJumping) jump();

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_isDead) return;

    final start = Vector2(-size.x / 2, -size.y / 2);
    final end = Vector2(size.x / 2, -size.y / 2);
    final healthPaint = Paint()
      ..color = const Color(0xFF00AF00)
      ..strokeWidth = 2;
    final lessHealthPaint = Paint()
      ..color = const Color(0xFF9F9F9F)
      ..strokeWidth = 2;

    final part = health / lama.health;
    final partPoint = Vector2(size.x * part + start.x, start.y);

    canvas.drawLine(start.toOffset(), partPoint.toOffset(), healthPaint);
    canvas.drawLine(
      partPoint.toOffset(),
      end.toOffset(),
      lessHealthPaint,
    );
  }

  /// Implement jump animation
  void jump() {
    if (_isDead) return;
    if (!_isJumping) {
      _isJumping = true;
      body.applyLinearImpulse(Vector2(10.0 * _jumpDirection * lama.jumpPower, 8 * lama.jumpPower));
      startAnimation(
        _jumpDirection == 1 ? 0 : 1,
        const Duration(milliseconds: 70),
        loop: false,
      );
    }
  }

  /// Set up default sprite to display staying
  void stay() {
    stopAnimation(_jumpDirection == 1 ? 0 : 1, 0);
  }

  /// Damage lama's health
  void damageLama(double damage) {
    health -= damage;
    if (health <= 0.0) {
      health = 0.0;
      _killLama();
    }
  }

  /// Kick the body to apply impulse
  void kickBody(Vector2 kickImpulse) {
    body.applyLinearImpulse(kickImpulse);
  }

  /// Kill lama when [health]=0.0 and apply dead reaction
  void _killLama() {
    _isDead = true;
    _applyDeadReaction = true;
  }

  /// Set up sprite's blink effect
  void setBlink(double dt) {
    final diff = _blinkTime! - _blinkTime!.toInt();

    final opacity = (_blinkDirection ? diff : 1.0 - diff) * 0.5;
    setOverridePaint(Paint()..color = Color.fromRGBO(255, 255, 255, opacity));
    if (diff < 0.01) {
      _blinkDirection = !_blinkDirection;
      _blinkTime = _blinkTime!.toInt().toDouble();
    }
    _blinkTime = _blinkTime! - dt;
  }

  /// Implement attack to damage tower
  void _implementAttack() {
    (gameRef as LamaGame).damageTower(lama.damage);
  }

  /// Start attacking tower by cooldown
  void startAttacking() => attackTimer.start();

  /// Stop attacking tower by cooldown
  void stopAttacking() => attackTimer.stop();
}
