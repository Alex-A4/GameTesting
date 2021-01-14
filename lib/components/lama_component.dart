import 'package:flame/spritesheet.dart';
import 'package:forge2d/forge2d.dart';
import 'package:game_testing/base_components/sprite_anim_body_component.dart';
import 'package:vector_math/vector_math_64.dart';

class LamaComponent extends SpriteAnimationBodyComponent {
  final Vector2 startPosition;
  bool isJumping = false;

  LamaComponent(SpriteSheet sheet, this.startPosition)
      : super.rest(sheet, Vector2.all(24));

  @override
  Body createBody() {
    final def = BodyDef()
      ..userData = this
      ..position = startPosition
      ..type = BodyType.STATIC;
    return world.createBody(def);
  }

  void jump() {
    if (!isJumping) {
      isJumping = true;
      startAnimation(
        0,
        Duration(milliseconds: 500),
        loop: false,
        completeCallback: () => isJumping = false,
      );
    }
  }

  void stay() {
    stopAnimation();
  }
}
