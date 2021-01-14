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
  final Vector2 startPosition;

  BulletComponent(Sprite sprite, this.startPosition)
      : super(sprite, Vector2.all(16));

  @override
  Body createBody() {
    final def = BodyDef()
      ..userData = this
      ..position = viewport.getScreenToWorld(startPosition)
      ..gravityScale = 0
      ..linearVelocity = Vector2(1000, 0)
      ..type = BodyType.DYNAMIC;
    final s = viewport.size / viewport.scale;
    rect = Rect.fromLTWH(-s.x / 2, -s.y / 2, s.x, s.y);
    return world.createBody(def);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final pos = this.body.position;
    if (!rect.contains(pos.toOffset())) {
      remove();
    }
  }
}
