import 'package:flame/components.dart';
import 'package:flutter/material.dart';

const _screenEdgePadding = 10.0;

/// Component that displays text health of tower.
/// Health manipulated with [damageTower].
class TowerHealthComponent extends PositionComponent {
  final double maxHealth;
  late Vector2 boxSize;
  late double currentHealth;
  late TextComponent _textComponent;

  @override
  bool get debugMode => false;

  /// Health bar renders in middle of screen's width with padding=[_screenEdgePadding].
  /// Height had been chose for text size=18/[zoom]
  TowerHealthComponent(
    this.maxHealth,
    Vector2 startPosition,
    Vector2 screenSize,
    double zoom,
  ) : super() {
    final realWidth = screenSize.x - 2 * _screenEdgePadding;
    position = startPosition + Vector2(_screenEdgePadding + realWidth / 2, 25 / zoom - 1);
    anchor = Anchor.center;
    boxSize = Vector2(realWidth, 30 / zoom);
    size = boxSize;
    currentHealth = maxHealth;

    add(_textComponent = TextComponent(
      text: maxHealth.toStringAsFixed(1),
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 18 / zoom, color: const Color(0xFFFFFFFF)),
      ),
      anchor: Anchor.center,
      position: position - Vector2(_screenEdgePadding, 25 / zoom / 2 - 1.5),
    ));
  }

  /// Left-top corner calculates from the lef-top corner of component as whole.
  /// If add some offset, it will be calculated inside component, not whole screen.
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final percent = currentHealth / maxHealth;
    final oneMinusPercent = 1.0 - percent;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, boxSize.x * percent, boxSize.y),
      Paint()
        ..color = const Color(0xFFFF0000)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRect(
      Rect.fromLTWH(boxSize.x * percent, 0, boxSize.x * oneMinusPercent, boxSize.y),
      Paint()
        ..color = const Color(0xFFbdbdbd)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, boxSize.x, boxSize.y),
      Paint()
        ..color = const Color(0xFF8d8d8d)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  void damageTower(double damage) {
    currentHealth -= damage;
    if (currentHealth <= 0.0) currentHealth = 0.0;
    _textComponent.text = currentHealth.toStringAsFixed(1);
  }
}
