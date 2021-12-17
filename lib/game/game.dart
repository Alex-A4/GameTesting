import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:game_testing/components/bullet_component.dart';
import 'package:game_testing/components/ground.dart';
import 'package:game_testing/components/lama_component.dart';
import 'package:game_testing/components/tower_component.dart';
import 'package:game_testing/components/tower_health_component.dart';
import 'package:game_testing/contacts/lama_bullet_contact.dart';
import 'package:game_testing/contacts/lama_tower_contact.dart';
import 'package:game_testing/models/lama_model.dart';

class LamaGame extends Forge2DGame with PanDetector {
  final Duration lamaSpam;
  final Duration bulletSpam;
  final int maxLamaCount;
  int totalLamaCount = 0;
  late double groundY;

  late Sprite bulletSprite;
  late TowerComponent towerComponent;
  late TowerHealthComponent towerHealth;

  /// Timers that displays lama and bullet cooldown
  late Timer lamaCooldown;
  late Timer bulletCooldown;

  @override
  bool get debugMode => false;

  LamaGame({
    this.lamaSpam = const Duration(milliseconds: 1000),
    this.bulletSpam = const Duration(milliseconds: 100),
    this.maxLamaCount = 1,
  }) : super(zoom: 4) {
    addContactCallback(LamaBulletContact());
    addContactCallback(LamaTowerContact());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await images.load('lama.png');
    await images.load('bullet.png');
    await images.load('ground.png');
    await images.load('tower.png');
    bulletSprite = Sprite(images.fromCache('bullet.png'));

    addAll(createBoundaries(
      size,
      SpriteSheet(image: images.fromCache('ground.png'), srcSize: Vector2(32, 8)),
      camera.viewport,
    ));
    groundY = -size.y + 20;

    towerHealth = TowerHealthComponent(
      100,
      camera.viewport.unprojectVector(Vector2.zero()),
      size,
      camera.zoom,
    );
    add(towerHealth);

    towerComponent = TowerComponent(
      SpriteSheet(
        image: images.fromCache('tower.png'),
        srcSize: Vector2(32, 32),
      ),
      camera.viewport.unprojectVector(Vector2(16, -size.y + 24)),
    );
    add(towerComponent);

    bulletCooldown = Timer(bulletSpam.inMilliseconds / Duration.millisecondsPerSecond);
    lamaCooldown = Timer(
      lamaSpam.inMilliseconds / Duration.millisecondsPerSecond,
      onTick: () {
        if (totalLamaCount < maxLamaCount) {
          totalLamaCount++;
          if (totalLamaCount > maxLamaCount ~/ 2) {
            add(LamaComponent(
              SpriteSheet(
                image: images.fromCache('lama.png'),
                srcSize: Vector2(24, 36),
              ),
              Vector2(size.x - 20, groundY),
              camera.zoom,
              lama: Lama(10, const Duration(seconds: 2), 200, 2),
              sheetSize: Vector2(36, 54),
            ));
          } else {
            add(LamaComponent(
              SpriteSheet(
                image: images.fromCache('lama.png'),
                srcSize: Vector2(24, 36),
              ),
              Vector2(size.x - 20, groundY),
              camera.zoom,
            ));
          }
        }
      },
      repeat: true,
    );
    lamaCooldown.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    lamaCooldown.update(dt);
    if (bulletCooldown.isRunning()) {
      bulletCooldown.update(dt);
    }
  }

  void damageTower(double damage) => towerHealth.damageTower(damage);

  @override
  void onPanUpdate(DragUpdateInfo info) {
    _spamBullet(info.raw.localPosition);
  }

  @override
  void onPanStart(DragStartInfo info) {
    _spamBullet(info.raw.localPosition);
  }

  void _spamBullet(Offset position) {
    var positionV2 = camera.unprojectVector(position.toVector2());

    if (!bulletCooldown.isRunning()) {
      final bullet = BulletComponent(bulletSprite, positionV2.y);
      add(bullet);
      towerComponent.shoot();
      bulletCooldown.start();
    }
  }
}
