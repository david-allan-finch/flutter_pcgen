import '../base/cdom_object.dart';
import '../enumeration/string_key.dart';

// Represents items gained at a specific level of a PCClass.
final class PCClassLevel extends CDOMObject {
  @override
  int get hashCode {
    final name = getDisplayName();
    return name == null ? 0 : name.hashCode;
  }

  @override
  bool operator ==(Object obj) =>
      obj is PCClassLevel && obj.isCDOMEqual(this);

  @override
  bool isType(String type) => false;

  String? getQualifiedKey() => get(StringKey.qualifiedKey);

  @override
  String toString() => getDisplayName() ?? '';

  PCClassLevel clone() {
    final copy = PCClassLevel();
    cloneTo(copy);
    return copy;
  }
}
