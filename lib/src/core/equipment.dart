import '../cdom/base/constants.dart';
import '../cdom/enumeration/integer_key.dart';
import '../cdom/enumeration/list_key.dart';
import '../cdom/enumeration/object_key.dart';
import '../cdom/enumeration/string_key.dart';
import '../cdom/enumeration/type.dart';
import 'pcobject.dart';

// Equipment location constants
enum EquipmentLocation {
  notCarried,
  carried,
  equipped,
  primaryHand,
  secondaryHand,
  bothHands,
  twoWeapons,
  shield,
  naturalPrimary,
  naturalSecondary,
  unarmed,
  doubleWeapon,
}

// Represents a piece of equipment for a PC.
class Equipment extends PObject {
  int _qty = 1;
  int _outputIndex = 0;
  bool _isEquipped = false;
  bool _isAutomatic = false;
  String _location = Constants.equipLocationNotcarried;
  double _weight = 0.0;
  double _cost = 0.0;
  int _carried = 0;
  String? _parentName;
  List<dynamic> _eqModifiers = [];
  List<dynamic> _eqModifiersHead2 = [];
  String? _containerCapacityString;

  // Quantity
  int getQty() => _qty;
  void setQty(int qty) { _qty = qty; }
  void setQty(double qty) { _qty = qty.round(); }

  // Output order
  int getOutputIndex() => _outputIndex;
  void setOutputIndex(int i) { _outputIndex = i; }

  // Equipped status
  bool isEquipped() => _isEquipped;
  void setEquipped(bool equipped) { _isEquipped = equipped; }

  // Location
  String getLocation() => _location;
  void setLocation(String loc) { _location = loc; }

  // Weight
  double getWeight() => _weight;
  void setWeight(double w) { _weight = w; }

  // Cost
  double getCost() => _cost;
  void setCost(double c) { _cost = c; }

  // Carried
  int getCarried() => _carried;
  void setCarried(int c) { _carried = c; }

  // Parent
  String? getParentName() => _parentName;
  void setParentName(String? name) { _parentName = name; }

  // Slot
  int getSlot() => getSafeInt(IntegerKey.slots);

  // Plus (enhancement bonus)
  int getPlus() => getSafeInt(IntegerKey.plus);

  // AC check penalty
  int acCheck() => getSafeInt(IntegerKey.acCheck);

  // Spell failure
  int spellFailure() => getSafeInt(IntegerKey.spellFailure);

  // Reach
  int getReach() => getSafeInt(IntegerKey.reach);

  // Range
  int getRange() => getSafeInt(IntegerKey.range);

  // Auto size prefix
  bool isAutoSize() => getKeyName().startsWith(Constants.autoResizePrefix);

  // Wield category
  String getWieldName() {
    final wield = getObject(ObjectKey.getConstant<dynamic>('WIELD'));
    return wield?.toString() ?? '';
  }

  // Armor type
  String getArmorType() {
    final armorType = getObject(ObjectKey.getConstant<dynamic>('ARMOR_TYPE'));
    return armorType?.toString() ?? '';
  }

  // Equipment modifiers for primary head
  List<dynamic> getEqModifierList(bool primary) {
    return primary ? List.unmodifiable(_eqModifiers) : List.unmodifiable(_eqModifiersHead2);
  }

  void addEqModifier(dynamic modifier, bool primary) {
    if (primary) {
      _eqModifiers.add(modifier);
    } else {
      _eqModifiersHead2.add(modifier);
    }
  }

  // Size
  dynamic getSizeAdjustment() {
    return getObject(ObjectKey.getConstant<dynamic>('SIZE'));
  }

  // Is container
  bool isContainer() {
    return getSafeInt(IntegerKey.containerReduceWeight) > 0 ||
        _containerCapacityString != null;
  }

  String? getContainerCapacityString() => _containerCapacityString;
  void setContainerCapacityString(String s) { _containerCapacityString = s; }

  // Is natural weapon
  bool isNaturalWeapon() =>
      containsInList(ListKey.getConstant<Type>('TYPE'), Type.natural);

  // Is magic
  bool isMagic() =>
      containsInList(ListKey.getConstant<Type>('TYPE'), Type.magic);

  // Is masterwork
  bool isMasterwork() =>
      containsInList(ListKey.getConstant<Type>('TYPE'), Type.masterwork);

  // Hands needed to wield
  int getHands() => getSafeInt(IntegerKey.hands);

  // Number of attacks with this weapon
  int getNumAttacks() => 1;

  @override
  Equipment clone() {
    final copy = Equipment();
    copy.setDisplayName(getDisplayName());
    copy.setKeyName(getKeyName());
    copy._qty = _qty;
    copy._weight = _weight;
    copy._cost = _cost;
    copy._location = _location;
    copy._isEquipped = _isEquipped;
    return copy;
  }

  @override
  String toString() => getDisplayName();
}
