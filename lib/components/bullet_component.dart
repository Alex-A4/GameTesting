import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:forge2d/forge2d.dart';
import 'package:game_testing/models/bullet_model.dart';

/// The component of bullet
class BulletComponent extends SpriteBodyComponent {
  final Bullet _bullet;
  Bullet get bullet => _bullet;
  late Rect _rect;
  late double _startY;
  bool _needRemove = false;

  BulletComponent(Sprite sprite, this._startY, {Bullet? bullet})
      : _bullet = bullet ?? Bullet.simple(),
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

    final s = camera.gameSize;
    final def = BodyDef()
      ..userData = this
      ..position = Vector2(10, _startY)
      ..type = BodyType.dynamic;
    _startY = def.position.y;
    _rect = Rect.fromLTWH(0, 0, s.x, s.y);
    return world.createBody(def)
      ..createFixture(fixDef)
      ..setMassData(MassData()..mass = 0.01);
  }

  @override
  void update(double dt) {
    super.update(dt);

    /// Remove bullet if it contacts with lama, if called [markToRemove]
    if (_needRemove) {
      removeFromParent();
      _needRemove = false;
    } else {
      final pos = body.position.clone();
      body.setTransform(Vector2(pos.x + _bullet.speed * dt, _startY), 0);

      /// If the bullet go out of the screen
      pos.absolute();
      if (!_rect.contains(pos.toOffset())) {
        removeFromParent();
      }
    }
  }

  void markToRemove() {
    _needRemove = true;
  }
}
