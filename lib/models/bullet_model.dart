import 'package:flame_forge2d/flame_forge2d.dart';

/// Bullet model that describes basic parameters for component
class Bullet {
  final Vector2 kickBody;
  final double damage;
  final double speed;

  Bullet(this.kickBody, this.damage, this.speed);

  factory Bullet.simple() => Bullet(Vector2(0, 0), 10, 150);
}
