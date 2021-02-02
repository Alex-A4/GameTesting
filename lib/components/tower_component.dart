import 'package:flame/spritesheet.dart';
import 'package:forge2d/forge2d.dart';
import 'package:game_testing/base_components/sprite_anim_body_component.dart';
import 'package:game_testing/game/game.dart';
import 'package:vector_math/vector_math_64.dart';

/// Component that describe tower which will be attacked by lamas
class TowerComponent extends SpriteAnimationBodyComponent {
  final Vector2 startPosition;

  bool isShooting = false;

  TowerComponent(SpriteSheet s, this.startPosition)
      : super.rest(s, Vector2(32, 32));

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
    final fixtureDef = FixtureDef()
      ..userData = this
      ..friction = 0.0
      ..shape = shape;

    final bodyDef = BodyDef()
      ..userData = this
      ..type = BodyType.STATIC
      ..position = startPosition;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  /// Attack tower to reduce health by [damage]
  void damageTower(double damage) => (gameRef as LamaGame).damageTower(damage);

  /// Animate shooting
  void shoot() {
    if (isShooting) return;
    isShooting = true;
    startAnimation(0, Duration(milliseconds: 30),
        loop: false, completeCallback: () => isShooting = false);
  }
}
