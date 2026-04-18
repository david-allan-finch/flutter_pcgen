enum AttackType {
  melee('BAB'),
  ranged('RAB'),
  unarmed('UAB'),
  grapple('GAB');

  final String identifier;

  const AttackType(this.identifier);

  static AttackType getAttackInstance(String ident) {
    for (final at in AttackType.values) {
      if (at.identifier == ident) return at;
    }
    throw ArgumentError('Illegal AttackType identifier: $ident');
  }
}
