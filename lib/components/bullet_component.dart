import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:forge2d/forge2d.dart';

/// The component of bullet
class BulletComponent extends SpriteBodyComponent {
  int count = 5;
  Rect rect;
  double speed = 150;
  final Vector2 startPosition;
  bool needRemove = false;

  BulletComponent(Sprite sprite, this.startPosition)
      : super(sprite, Vector2(11, 5));

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
    final fixDef = FixtureDef()
      ..userData = this
      ..shape = shape
      ..restitution = 0.0
      ..density = 0.0
      ..friction = 0.0;

    final def = BodyDef()
      ..userData = this
      ..position = viewport.getScreenToWorld(startPosition)
      ..type = BodyType.STATIC;
    final s = viewport.size / viewport.scale;
    rect = Rect.fromLTWH(-s.x / 2, -s.y / 2, s.x, s.y);
    return world.createBody(def)..createFixture(fixDef);
  }

  @override
  void update(double dt) {
    super.update(dt);
    /// DROPS ERROR
    if (needRemove) {
      gameRef.remove(this);
      needRemove = false;
    }
    final pos = this.body.position;
    body.setTransform(Vector2(pos.x + speed * dt, pos.y), 0);
    if (!rect.contains(pos.toOffset())) {
      /// WORKS FINE
      gameRef.remove(this);
    }
  }

  void markToRemove() {
    needRemove = true;
  }
}
