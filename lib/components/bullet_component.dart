import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:forge2d/forge2d.dart';
import 'package:game_testing/models/bullet_model.dart';

/// The component of bullet
class BulletComponent extends SpriteBodyComponent {
  final Bullet bullet;
  late Rect rect;
  late double startY;
  bool needRemove = false;

  BulletComponent(Sprite sprite, this.startY, {Bullet? bullet})
      : this.bullet = bullet ?? Bullet.simple(),
        super(sprite, Vector2(11, 5));

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
    final fixDef = FixtureDef(shape)
      ..userData = this
      ..restitution = 1.0
      ..density = 0.0
      ..friction = 0.0;
    fixDef.filter.groupIndex = -2;

    final def = BodyDef()
      ..userData = this
      ..position = gameRef.screenToWorld(Vector2(40, startY))
      ..type = BodyType.dynamic;
    this.startY = def.position.y;
    final s = camera.gameSize;
    rect = Rect.fromLTWH(-s.x / 2, -s.y / 2, s.x, s.y);
    return world.createBody(def)
      ..createFixture(fixDef)
      ..setMassData(MassData()..mass = 0.01);
  }

  @override
  void update(double dt) {
    super.update(dt);

    /// Remove bullet if it contacts with lama, if called [markToRemove]
    if (needRemove) {
      removeFromParent();
      needRemove = false;
    } else {
      final pos = this.body.position;
      body.setTransform(Vector2(pos.x + bullet.speed * dt, startY), 0);

      /// If the bullet go out of the screen
      print(rect);
      print(pos);
      if (!rect.contains(pos.toOffset())) {
        removeFromParent();
      }
    }
  }

  void markToRemove() {
    needRemove = true;
  }
}
