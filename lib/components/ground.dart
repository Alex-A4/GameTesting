import 'package:flame/extensions/vector2.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:forge2d/forge2d.dart';
import 'package:flame_forge2d/viewport.dart';

List<Ground> createBoundaries(Viewport viewport, Sprite sprite) {
  final size = viewport.size / viewport.scale;
  final y = (-size.y / 2) + (sprite.srcSize.y / 2);
  double totalWidth = size.x / 2;
  final list = <Ground>[];
  while (totalWidth >= (-size.x / 2)) {
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

    shape.set(vertices, vertices.length);

    final def = FixtureDef()
      ..shape = shape
      ..restitution = 0.0
      ..friction = 1.0;
    final bodyDef = BodyDef()
      ..userData = this // To be able to determine object in collision
      ..position = start
      ..type = BodyType.STATIC;

    return world.createBody(bodyDef)..createFixture(def);
  }
}
