import 'package:flame/extensions/vector2.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/timer.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/widgets.dart';
import 'package:game_testing/components/bullet_component.dart';
import 'package:game_testing/components/ground.dart';
import 'package:game_testing/components/lama_component.dart';
import 'package:game_testing/components/tower_component.dart';
import 'package:game_testing/components/tower_health_component.dart';
import 'package:game_testing/contacts/lama_bullet_contact.dart';
import 'package:game_testing/contacts/lama_tower_contact.dart';
import 'package:game_testing/models/bullet_model.dart';
import 'package:game_testing/models/lama_model.dart';

class LamaGame extends Forge2DGame with PanDetector {
  final Duration lamaSpam;
  final Duration bulletSpam;
  final int maxLamaCount;
  int totalLamaCount = 0;

  /// Timers that displays lama and bullet cooldown
  Timer lamaCooldown;
  Timer bulletCooldown;

  TowerHealthComponent towerHealth;
  TowerComponent towerComponent;

  double groundY;

  LamaGame({
    this.lamaSpam = const Duration(milliseconds: 1000),
    this.bulletSpam = const Duration(milliseconds: 100),
    this.maxLamaCount = 5,
  }) : super(gravity: Vector2(.0, -50.0), scale: 2.0) {
    addContactCallback(LamaBulletContact());
    addContactCallback(LamaTowerContact());
  }

  @override
  Future<void> onLoad() async {
    await images.load('lama.png');
    await images.load('bullet.png');
    await images.load('ground.png');
    await images.load('tower.png');
    addAll(createBoundaries(
      viewport,
      Sprite(images.fromCache('ground.png'), srcSize: Vector2(32, 8)),
    ));
    towerHealth = TowerHealthComponent(100, Vector2(5, 10), viewport.width);
    add(towerHealth);

    final size = viewport.size / viewport.scale;
    groundY = (-size.y / 2) + 20;
    towerComponent = TowerComponent(
      SpriteSheet(
        image: images.fromCache('tower.png'),
        srcSize: Vector2(32, 32),
      ),
      Vector2(-size.x / 2 + 16, groundY + 4),
    );
    add(towerComponent);

    lamaCooldown = Timer(
      lamaSpam.inMilliseconds / Duration.millisecondsPerSecond,
      callback: () {
        if (totalLamaCount < maxLamaCount) {
          final size = viewport.size / viewport.scale;
          totalLamaCount++;
          if (totalLamaCount > maxLamaCount ~/ 2) {
            add(LamaComponent(
              SpriteSheet(
                image: images.fromCache('lama.png'),
                srcSize: Vector2(24, 36),
              ),
              Vector2(size.x / 2 - 20, groundY),
              lama: Lama(10, Duration(seconds: 2), 200, 2),
              sheetSize: Vector2(36, 54),
            ));
          } else
            add(
              LamaComponent(
                SpriteSheet(
                  image: images.fromCache('lama.png'),
                  srcSize: Vector2(24, 36),
                ),
                Vector2(size.x / 2 - 20, groundY),
              ),
            );
        }
      },
      repeat: true,
    );
    bulletCooldown =
        Timer(bulletSpam.inMilliseconds / Duration.millisecondsPerSecond);
    lamaCooldown.start();
  }

  void damageTower(double damage) => towerHealth.damageTower(damage);

  @override
  void update(double dt) {
    super.update(dt);
    lamaCooldown.update(dt);
    if (bulletCooldown.isRunning()) {
      bulletCooldown.update(dt);
    }
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    spamBullet(details.localPosition);
  }

  @override
  void onPanStart(DragStartDetails details) {
    spamBullet(details.localPosition);
  }

  void spamBullet(Offset position) {
    if (!bulletCooldown.isRunning()) {
      final bullet = BulletComponent(
        Sprite(images.fromCache('bullet.png')),
        position.dy,
        bullet: Bullet.simple(),
      );
      towerComponent.shoot();
      add(bullet);
      bulletCooldown.start();
    }
  }
}
