// Represents the hit die for a class (d4, d6, d8, d10, d12).
class HitDie {
  final int _die;

  const HitDie(this._die);

  int getDie() => _die;

  @override
  String toString() => 'd$_die';

  @override
  bool operator ==(Object other) => other is HitDie && _die == other._die;

  @override
  int get hashCode => _die.hashCode;
}
