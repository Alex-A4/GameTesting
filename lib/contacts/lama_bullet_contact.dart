import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:forge2d/forge2d.dart';
import 'package:game_testing/components/bullet_component.dart';
import 'package:game_testing/components/lama_component.dart';

class LamaBulletContact
    extends ContactCallback<LamaComponent, BulletComponent> {
  @override
  void begin(LamaComponent a, BulletComponent b, Contact contact) {
    b.markToRemove();
  }

  @override
  void end(LamaComponent a, BulletComponent b, Contact contact) {}
}
