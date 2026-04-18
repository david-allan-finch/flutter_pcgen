import '../cdom/enumeration/object_key.dart';
import 'equipment.dart';

final class EquipmentUtilities {
  EquipmentUtilities._();

  // Returns all equipment items that are NOT of the given type.
  static List<Equipment> removeEqType(List<Equipment> aList, String type) {
    final result = <Equipment>[];
    for (final eq in aList) {
      if ('CONTAINED'.toLowerCase() == type.toLowerCase() &&
          eq.getParent() != null) {
        continue;
      }
      if (!eq.typeStringContains(type)) result.add(eq);
    }
    return result;
  }

  // Returns only equipment items that ARE of the given type.
  static List<Equipment> removeNotEqType(List<Equipment> aList, String aString) {
    return aList.where((eq) => eq.typeStringContains(aString)).toList();
  }

  // Appends aString to aName using parenthesis notation.
  static String appendToName(String aName, String aString) {
    final buf = StringBuffer(aName);
    final iLen = buf.length - 1;
    // StringBuffer doesn't allow in-place char replacement easily
    final s = buf.toString();
    if (s[iLen] == ')') {
      return '${s.substring(0, iLen)}/$aString)';
    } else {
      return '$s ($aString)';
    }
  }

  // Finds equipment in aList whose key (or base item key chain) matches baseKey.
  static Equipment? findEquipmentByBaseKey(
      List<Equipment> aList, String baseKey) {
    for (final equipment in aList) {
      Equipment? target = equipment;
      while (target != null) {
        if (target.getKeyName().toLowerCase() == baseKey.toLowerCase()) {
          return equipment;
        }
        final baseRef = target.get(ObjectKey.baseItem);
        target = baseRef == null ? null : (baseRef as dynamic)?.get();
      }
    }
    return null;
  }
}
