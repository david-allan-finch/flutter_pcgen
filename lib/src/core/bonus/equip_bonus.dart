import 'bonus_obj.dart';

// Pairs a BonusObj with an optional condition string for equipment-specific bonuses.
class EquipBonus {
  final BonusObj bonus;
  final String conditions;

  EquipBonus(this.bonus, this.conditions);

  @override
  String toString() => 'EquipBonus [bonus=$bonus, conditions=$conditions]';
}
