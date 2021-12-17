import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:forge2d/forge2d.dart';
import 'package:game_testing/components/bullet_component.dart';
import 'package:game_testing/components/lama_component.dart';

/// Contact of lama and bullet that damage lama and destroys bullet component
class LamaBulletContact extends ContactCallback<LamaComponent, BulletComponent> {
  @override
  void begin(LamaComponent a, BulletComponent b, Contact contact) {
    if (!a.isDead) {
      b.markToRemove();
      a.kickBody(b.bullet.kickBody);
      a.damageLama(b.bullet.damage);
    }
  }

  @override
  void end(LamaComponent a, BulletComponent b, Contact contact) {}
}
