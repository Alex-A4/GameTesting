import 'package:flame/extensions/vector2.dart';
import 'package:flame/extensions/offset.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/timer.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:game_testing/components/bullet_component.dart';
import 'package:game_testing/components/ground.dart';
import 'package:game_testing/components/lama_component.dart';
import 'package:game_testing/contacts/lama_bullet_contact.dart';

class LamaGame extends Forge2DGame with PanDetector {
  final Duration spamSpeed;
  final Duration bulletSpam;
  static const maxLamaCount = 5;
  int totalLamaCount = 0;
  Timer spamTimer;
  Timer bulletCooldown;

  LamaGame({
    this.spamSpeed = const Duration(milliseconds: 5000),
    this.bulletSpam = const Duration(milliseconds: 100),
  }) : super(gravity: Vector2(.0, -50.0), scale: 2.0) {
    addContactCallback(LamaBulletContact());
  }

  @override
  Future<void> onLoad() async {
    await images.load('lama.png');
    await images.load('bullet.png');
    await images.load('ground.png');
    addAll(createBoundaries(
      viewport,
      Sprite(images.fromCache('ground.png'), srcSize: Vector2(32, 8)),
    ));
    spamTimer = Timer(
      spamSpeed.inMilliseconds / Duration.millisecondsPerSecond,
      callback: () {
        if (totalLamaCount < maxLamaCount) {
          final size = viewport.size / viewport.scale;
          final y = (-size.y / 2) + 20;
          totalLamaCount++;
          add(
            LamaComponent(
              SpriteSheet(
                image: images.fromCache('lama.png'),
                srcSize: Vector2(24, 36),
              ),
              Vector2(size.x / 2 - 20, y),
            ),
          );
        }
      },
      repeat: true,
    );
    bulletCooldown =
        Timer(bulletSpam.inMilliseconds / Duration.millisecondsPerSecond);
    spamTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    spamTimer.update(dt);
    if (bulletCooldown.isRunning()) {
      bulletCooldown.update(dt);
    }
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    if (!bulletCooldown.isRunning()) {
      final bullet = BulletComponent(
        Sprite(images.fromCache('bullet.png')),
        details.localPosition.toVector2(),
      );
      add(bullet);
      bulletCooldown.start();
    }
  }
}
