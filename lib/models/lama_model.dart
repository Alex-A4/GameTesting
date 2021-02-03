/// Lama model that describes basic parameters for component
class Lama {
  final double damage;
  final Duration attackCooldown;
  final double health;
  final double jumpPower;

  Lama(this.damage, this.attackCooldown, this.health, this.jumpPower);

  factory Lama.simple() => Lama(5.0, Duration(seconds: 1), 100, 1);
}
