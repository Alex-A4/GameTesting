import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:forge2d/forge2d.dart';
import 'package:game_testing/components/lama_component.dart';
import 'package:game_testing/components/tower_component.dart';

class LamaTowerContact extends ContactCallback<LamaComponent, TowerComponent> {
  @override
  void begin(LamaComponent a, TowerComponent b, Contact contact) {
    a.startAttacking();
  }

  @override
  void end(LamaComponent a, TowerComponent b, Contact contact) {}
}
