import 'dart:ui';

import 'package:forge2d/forge2d.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/viewport.dart';

List<Ground> createBoundaries(Viewport viewport) {
  final Vector2 screenSize = viewport.size / viewport.scale;
  final Vector2 bottomRight = screenSize / 2;
  final Vector2 bottomLeft = Vector2(-bottomRight.x, bottomRight.y);

  final rem = Vector2(0, 5);
  return [
    Ground(bottomRight - rem, bottomLeft - rem),
  ];
}

class Ground extends BodyComponent {
  final Vector2 start;
  final Vector2 end;

  Ground(this.start, this.end)
      : super(
          paint: Paint()
            ..color = Color(0xFFFF0000)
            ..strokeWidth = 5,
        );

  @override
  Body createBody() {
    final EdgeShape shape = EdgeShape();
    shape.set(start, end);

    final fixtureDef = FixtureDef()
      ..shape = shape
      ..restitution = 0.0
      ..friction = 0.1;

    final bodyDef = BodyDef()
      ..userData = this // To be able to determine object in collision
      ..position = Vector2.zero()
      ..type = BodyType.STATIC;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
