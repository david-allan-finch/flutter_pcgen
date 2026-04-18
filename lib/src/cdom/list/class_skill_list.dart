import '../base/cdom_list_object.dart';
import '../enumeration/type.dart' as cdom;
import '../../core/skill.dart';

// A named list of skills associated with a PCClass.
class ClassSkillList extends CDOMListObject<Skill> {
  Set<cdom.Type>? _types;

  @override
  Type get listClass => Skill;

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
