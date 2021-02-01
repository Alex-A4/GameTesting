import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.setLandscape();
  await Flame.util.fullScreen();
  runApp(GameWidget(
    game: LamaGame(),
    backgroundBuilder: (_) => Container(color: Colors.white),
  ));
}
