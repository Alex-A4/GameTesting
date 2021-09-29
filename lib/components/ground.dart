import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:forge2d/forge2d.dart';

List<Ground> createBoundaries(Viewport viewport, Sprite sprite) {
  final size = (viewport.canvasSize ?? 0) / viewport.scale;
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

    shape.set(vertices);

    final def = FixtureDef(shape)
      ..restitution = 0.0
      ..friction = 1.0;
    def.filter.groupIndex = -2;
    final bodyDef = BodyDef()
      ..userData = this // To be able to determine object in collision
      ..position = start
      ..type = BodyType.static;

    return world.createBody(bodyDef)..createFixture(def);
  }
}
