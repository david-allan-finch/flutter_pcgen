import '../cdom/enumeration/type.dart' as cdom;
import 'character/equip_slot.dart';

// Represents a part of a character's body that can hold equipment (Head, Torso, etc.).
class BodyStructure {
  final String name;
  final bool holdsAnyType;
  final Set<cdom.Type> _forbiddenTypes;
  final List<EquipSlot> _slots = [];

  BodyStructure(this.name, {this.holdsAnyType = false, Set<cdom.Type>? forbiddenTypes})
      : _forbiddenTypes = forbiddenTypes != null ? Set.of(forbiddenTypes) : {};

  String getName() => name;

  void addEquipSlot(EquipSlot slot) => _slots.add(slot);

  List<EquipSlot> getSlots() => List.unmodifiable(_slots);

  bool isForbidden(List<cdom.Type> types) {
    if (_forbiddenTypes.isEmpty) return false;
    return types.any(_forbiddenTypes.contains);
  }

  bool isHoldsAnyType() => holdsAnyType;

  @override
  String toString() => name;
}
