import 'package:flame/sprite.dart';
import 'package:forge2d/forge2d.dart';
import 'package:game_testing/base_components/sprite_anim_body_component.dart';

/// Component that describe tower which will be attacked by lamas
class TowerComponent extends SpriteAnimationBodyComponent {
  final Vector2 startPosition;

  bool isShooting = false;

  TowerComponent(SpriteSheet s, this.startPosition) : super.rest(s, Vector2(32, 32));

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
    final fixtureDef = FixtureDef(shape)
      ..userData = this
      ..friction = 0.0;
    fixtureDef.filter.groupIndex = -2;

    final bodyDef = BodyDef()
      ..userData = this
      ..type = BodyType.static
      ..position = startPosition;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  /// Animate shooting
  void shoot() {
    if (isShooting) return;
    isShooting = true;
    startAnimation(
      0,
      const Duration(milliseconds: 30),
      loop: false,
      completeCallback: () => isShooting = false,
    );
  }
}
