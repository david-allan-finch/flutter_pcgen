import '../base/cdom_list_object.dart';
import '../enumeration/type.dart' as cdom;
import '../../core/spell/spell.dart';

// A named list of spells associated with a Domain.
class DomainSpellList extends CDOMListObject<Spell> {
  Set<cdom.Type>? _types;

  @override
  Type get listClass => Spell;

  void addType(cdom.Type type) {
    _types ??= {};
    _types!.add(type);
  }

  @override
  bool isType(String type) {
    if (type.isEmpty || _types == null) return false;
    for (final part in type.split('.')) {
      if (!_types!.any((t) => t.toString().toLowerCase() == part.toLowerCase())) return false;
    }
    return true;
  }
}
