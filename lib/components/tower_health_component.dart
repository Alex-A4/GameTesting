import 'dart:ui';

import 'package:flame/components.dart';

/// Component that displays text health of tower.
/// Health manipulated with [damageTower].
class TowerHealthComponent extends TextComponent {
  final Vector2 startPosition;
  final double maxHealth;
  late Vector2 boxSize;
  late double currentHealth;

  TowerHealthComponent(this.maxHealth, this.startPosition, double width)
      : super(
          maxHealth.toStringAsFixed(1),
          textRenderer: TextPaint(
            config: TextPaintConfig(fontSize: 18, color: Color(0xFFFFFFFF)),
          ),
        ) {
    position = startPosition + Vector2(width / 2, 10);
    anchor = Anchor.center;
    boxSize = Vector2(width, 20);
    currentHealth = maxHealth;
  }

  @override
  void render(Canvas canvas) {
    final percent = currentHealth / maxHealth;
    final oneMinusPercent = 1.0 - percent;
    canvas.drawRect(
      Rect.fromLTWH(
          startPosition.x, startPosition.y, boxSize.x * percent, boxSize.y),
      Paint()
        ..color = Color(0xFFFF0000)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRect(
      Rect.fromLTWH(startPosition.x + boxSize.x * percent, startPosition.y,
          boxSize.x * oneMinusPercent, boxSize.y),
      Paint()
        ..color = Color(0xFFbdbdbd)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRect(
      Rect.fromLTWH(startPosition.x, startPosition.y, boxSize.x, boxSize.y),
      Paint()
        ..color = Color(0xFF8d8d8d)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
    super.render(canvas);
  }

  void damageTower(double damage) {
    currentHealth -= damage;
    if (currentHealth <= 0.0) currentHealth = 0.0;
    text = currentHealth.toStringAsFixed(1);
  }
}
