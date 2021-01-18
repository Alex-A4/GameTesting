import 'package:flame/components/joystick/joystick_action.dart';
import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/extensions/offset.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:game_testing/components/bullet_component.dart';
import 'package:game_testing/components/ground.dart';
import 'package:game_testing/components/lama_component.dart';
import 'package:game_testing/contacts/lama_bullet_contact.dart';

class LamaGame extends Forge2DGame with MultiTouchDragDetector {
  JoystickComponent joystick;
  LamaComponent _lama;

  LamaGame() : super(gravity: Vector2(.0, -50.0), scale: 2.0) {
    addContactCallback(LamaBulletContact());
    add(createJoystick());
  }

  JoystickComponent createJoystick() {
    joystick = JoystickComponent(actions: [
      JoystickAction(
        actionId: 1,
        align: JoystickActionAlign.BOTTOM_LEFT,
        margin: EdgeInsets.only(bottom: 10, left: 10),
      ),
      JoystickAction(
        actionId: 2,
        align: JoystickActionAlign.BOTTOM_LEFT,
        margin: EdgeInsets.only(left: 70, bottom: 10),
      ),
    ]);
    return joystick;
  }

  @override
  Future<void> onLoad() async {
    await images.load('lama.png');
    await images.load('bullet.png');
    await images.load('ground.png');
    _lama = LamaComponent(
      SpriteSheet(
          image: images.fromCache('lama.png'), srcSize: Vector2(24, 36)),
      Vector2(0, 0),
    );
    joystick.addObserver(_lama);
    addAll(createBoundaries(
      viewport,
      Sprite(images.fromCache('ground.png'), srcSize: Vector2(32, 8)),
    ));
    add(_lama);
  }

  @override
  void onReceiveDrag(DragEvent drag) {
    joystick.onReceiveDrag(drag);
    if (joystick.actions.every((b) => !b.isPressed)) {
      final bullet = BulletComponent(
        Sprite(images.fromCache('bullet.png')),
        drag.initialPosition.toVector2(),
      );
      add(bullet);
    }
    super.onReceiveDrag(drag);
  }
}
