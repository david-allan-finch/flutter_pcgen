import '../../core/equipment.dart';
import '../../core/equipment_modifier.dart';

// Controls how an EquipmentModifier's name appears in the equipment's extended name.
enum EqModNameOpt {
  normal,
  noList,
  noName,
  nothing,
  spell,
  text;

  static EqModNameOpt valueOfIgnoreCase(String optName) {
    for (final v in EqModNameOpt.values) {
      if (v.name.toLowerCase() == optName.toLowerCase()) return v;
    }
    throw ArgumentError('$optName is not a valid EqModNameOpt');
  }

  String returnName(Equipment parent, EquipmentModifier mod) {
    switch (this) {
      case EqModNameOpt.normal:
        final assoc = parent.getAssociationList(mod);
        final sb = StringBuffer(mod.getDisplayName());
        if (assoc.isNotEmpty) {
          sb.write(' (');
          sb.write(associatedList(assoc));
          sb.write(')');
        }
        return sb.toString().trim().replaceAll('|', ' ');
      case EqModNameOpt.noList:
        return mod.getDisplayName().trim().replaceAll('|', ' ');
      case EqModNameOpt.noName:
        return associatedList(parent.getAssociationList(mod)).trim().replaceAll('|', ' ');
      case EqModNameOpt.nothing:
        return '';
      case EqModNameOpt.spell:
        // Spell formatting handled by caller; return display name as fallback
        return mod.getDisplayName().trim().replaceAll('|', ' ');
      case EqModNameOpt.text:
        return mod.getNameText() ?? '';
    }
  }

  String associatedList(List<String?> associatedList) {
    if (associatedList.isEmpty) return '';
    return associatedList.map((c) => c ?? '*').join(', ');
  }
}
