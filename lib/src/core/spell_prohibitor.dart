import '../cdom/base/concrete_prereq_object.dart';

// Defines what spells are prohibited for a class/subclass (by alignment, school, etc.).
enum ProhibitedSpellType { alignment, school, subSchool, descriptor, spell }

class SpellProhibitor extends ConcretePrereqObject {
  ProhibitedSpellType? type;
  List<String> valueList = [];

  void addValue(String value) => valueList.add(value);

  bool isProhibited(dynamic spell, dynamic aPC, dynamic owner) {
    if (!qualifies(aPC, owner)) return false;
    // Full implementation requires spell descriptor lookup
    return false;
  }

  @override
  String toString() => '${type?.name ?? ''}:${valueList.join(',')}';

  @override
  int get hashCode => (type?.hashCode ?? 0) ^ valueList.length;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    if (o is! SpellProhibitor) return false;
    return type == o.type && valueList.toString() == o.valueList.toString();
  }
}
