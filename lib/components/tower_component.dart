import 'package:flame/sprite.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:forge2d/forge2d.dart';
import 'package:game_testing/game/game.dart';
import 'package:vector_math/vector_math_64.dart';

/// Component that describe tower which will be attacked by lamas
class TowerComponent extends SpriteBodyComponent {
  final Vector2 startPosition;

  TowerComponent(Sprite s, this.startPosition) : super(s, Vector2(10, 10));

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
      ..position = viewport.getScreenToWorld(startPosition);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  /// Attack tower to reduce health by [damage]
  void damageTower(double damage) => (gameRef as LamaGame).damageTower(damage);
}
