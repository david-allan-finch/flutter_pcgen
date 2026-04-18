import '../cdom/base/cdom_object.dart';
import '../cdom/enumeration/list_key.dart';
import '../cdom/enumeration/object_key.dart';
import '../cdom/enumeration/string_key.dart';
import '../cdom/enumeration/type.dart' as cdom;
import 'analysis/output_name_formatting.dart';

// Base class for most PCGen data objects (Skill, Feat, Race, etc.).
class PObject extends CDOMObject
    implements Comparable<Object> {
  @override
  int compareTo(Object obj) {
    if (obj is PObject) {
      return getKeyName().toLowerCase().compareTo(obj.getKeyName().toLowerCase());
    }
    return 1;
  }

  @override
  bool operator ==(Object obj) =>
      obj is PObject &&
      getKeyName().toLowerCase() == obj.getKeyName().toLowerCase();

  @override
  int get hashCode => getKeyName().toLowerCase().hashCode;

  @override
  void setName(String aString) {
    if (!aString.endsWith('.MOD')) {
      super.setName(aString);
      put(StringKey.keyName, aString);
    }
  }

  String getOutputName() => OutputNameFormatting.getOutputName(this);

  String getType() =>
      getSafeListFor(ListKey.type).map((t) => t.toString()).join('.');

  List<cdom.Type> getTrueTypeList(bool visibleOnly) {
    final ret = List<cdom.Type>.from(getSafeListFor(ListKey.type));
    // visibleOnly filtering requires HiddenTypeFacet — not yet available
    return List.unmodifiable(ret);
  }

  @override
  bool isType(String aType) {
    if (aType.isEmpty) return false;
    final String myType;
    if (aType.startsWith('!')) {
      myType = aType.substring(1).toUpperCase();
    } else if (aType.startsWith('TYPE=') || aType.startsWith('TYPE.')) {
      myType = aType.substring(5).toUpperCase();
    } else {
      myType = aType.toUpperCase();
    }
    for (final tok in myType.split('.')) {
      if (!containsInList(ListKey.type, cdom.Type.getConstant(tok))) return false;
    }
    return true;
  }

  @override
  String toString() => getDisplayName();

  bool isNamePI() => getSafe(ObjectKey.namePI) as bool? ?? false;

  String getSource() => ''; // stub — needs SourceFormat

  String getSourceForNodeDisplay() => ''; // stub
}
