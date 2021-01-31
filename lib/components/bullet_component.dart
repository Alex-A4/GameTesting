import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:forge2d/forge2d.dart';

/// The component of bullet
class BulletComponent extends SpriteBodyComponent {
  Rect rect;
  double speed;
  double damage;
  double startY;
  double mass;
  bool needRemove = false;

  BulletComponent(
    Sprite sprite,
    this.startY, {
    this.speed,
    this.damage,
    this.mass,
  }) : super(sprite, Vector2(11, 5)) {
    this.speed ??= 150;
    this.damage ??= 10;
    this.mass ??= 0.1;
  }

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
      ..restitution = 1.0
      ..density = 0.0
      ..friction = 0.0;
    fixDef.filter.groupIndex = -2;

    final def = BodyDef()
      ..userData = this
      ..position = viewport.getScreenToWorld(Vector2(0, startY))
      ..type = BodyType.DYNAMIC;
    this.startY = def.position.y;
    final s = viewport.size / viewport.scale;
    rect = Rect.fromLTWH(-s.x / 2, -s.y / 2, s.x, s.y);
    return world.createBody(def)
      ..createFixture(fixDef)
      ..setMassData(MassData()..mass = mass);
  }

  @override
  void update(double dt) {
    super.update(dt);

    /// Remove bullet if it contacts with lama, if called [markToRemove]
    if (needRemove) {
      gameRef.remove(this);
      needRemove = false;
    } else {
      final pos = this.body.position;
      body.setTransform(Vector2(pos.x + speed * dt, startY), 0);

      /// If the bullet go out of the screen
      if (!rect.contains(pos.toOffset())) {
        gameRef.remove(this);
      }
    }
  }

  void markToRemove() {
    needRemove = true;
  }
}
