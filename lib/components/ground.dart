import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:forge2d/forge2d.dart';

List<Ground> createBoundaries(Vector2 gameSize, Sprite sprite) {
  final y = (-gameSize.y) + (sprite.srcSize.y / 2);
  double totalWidth = gameSize.x;
  final list = <Ground>[];
  while (totalWidth >= 0) {
    list.add(Ground(Vector2(totalWidth, y), sprite));
    totalWidth -= (sprite.image.width);
  }

  return list;
}

class Ground extends SpriteBodyComponent {
  final Vector2 start;

  Ground(this.start, Sprite sprite) : super(sprite, Vector2(32, 8));

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

    final def = FixtureDef(shape)
      ..restitution = 0.0
      ..friction = 1.0;
    def.filter.groupIndex = -2;
    final bodyDef = BodyDef()
      ..userData = this
      ..position = start
      ..type = BodyType.static;

    return world.createBody(bodyDef)..createFixture(def);
  }
}
