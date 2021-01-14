import 'package:flame/extensions/vector2.dart';
import 'package:flame/extensions/offset.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:game_testing/components/bullet_component.dart';
import 'package:game_testing/components/ground.dart';
import 'package:game_testing/components/lama_component.dart';

class LamaGame extends Forge2DGame with TapDetector {
  LamaComponent _lama;

  LamaGame() : super(gravity: Vector2(.0, -10.0), scale: 4.0) {
    addAll(createBoundaries(viewport));
  }

  @override
  Future<void> onLoad() async {
    await images.load('lama.png');
    await images.load('bullet.png');
    _lama = LamaComponent(
      SpriteSheet(
          image: images.fromCache('lama.png'), srcSize: Vector2.all(48)),
      Vector2(0,0),
    );
    add(_lama);
  }

  @override
  void onTapUp(v) {
    final bullet = BulletComponent(
        Sprite(images.fromCache('bullet.png')), v.localPosition.toVector2());
    add(bullet);
    _lama.jump();
  }
}
