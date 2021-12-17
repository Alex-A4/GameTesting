import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' hide Viewport;
import 'package:forge2d/forge2d.dart';
import 'package:game_testing/base_components/sprite_anim_body_component.dart';

/// Create ground for whole width of screen at the bottom of it
List<Ground> createBoundaries(Vector2 gameSize, SpriteSheet sprite, Viewport centeredViewport) {
  final y = -gameSize.y + (sprite.srcSize.y / 2);
  double x = sprite.image.width / 2;

  int totalCount = (gameSize.x / sprite.image.width).ceil();
  final list = <Ground>[];

  for (var i = 0; i < totalCount; i++) {
    list.add(Ground(centeredViewport.unprojectVector(Vector2(x, y)), sprite));
    x += (sprite.image.width);
  }

  return list;
}

/// The ground where objects stays on
class Ground extends SpriteAnimationBodyComponent {
  final Vector2 start;

  Ground(this.start, SpriteSheet sprite) : super.rest(sprite, Vector2(32, 8));

  @override
  Paint get paint => Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

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
