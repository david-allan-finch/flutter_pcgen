import '../cdom/enumeration/object_key.dart';
import 'pcobject.dart';

// Represents a skill (e.g., Acrobatics, Perception).
final class Skill extends PObject {
  String getKeyStatAbb() {
    final keyStat = getObject(ObjectKey.getConstant<dynamic>('KEY_STAT'));
    if (keyStat == null) return '';
    return (keyStat as dynamic).get()?.getKeyName() ?? '';
  }

  @override
  bool operator ==(Object other) =>
      other is Skill && getKeyName().toLowerCase() == other.getKeyName().toLowerCase();

  @override
  int get hashCode => getKeyName().hashCode;

  String? getLocalScopeName() => 'PC.SKILL';
}
