import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/type.dart';

// Base class for several objects in the PCGen database.
class PObject extends CDOMObject implements Comparable<Object> {

  @override
  void setName(String aString) {
    if (!aString.endsWith('.MOD')) {
      super.setName(aString);
      putString(StringKey.keyName, aString);
    }
  }

  @override
  int compareTo(Object obj) {
    if (obj is PObject) {
      return getKeyName().toLowerCase().compareTo(obj.getKeyName().toLowerCase());
    }
    return 1;
  }

  @override
  bool operator ==(Object other) {
    return other is PObject &&
        getKeyName().toLowerCase() == other.getKeyName().toLowerCase();
  }

  @override
  int get hashCode => getKeyName().toLowerCase().hashCode;

  String getOutputName() {
    // OutputNameFormatting.getOutputName deferred - use display name for now
    final outputName = getString(StringKey.outputName);
    if (outputName != null && outputName.isNotEmpty) return outputName;
    return getDisplayName();
  }

  String getType() {
    final types = getTrueTypeList(false);
    return types.map((t) => t.toString()).join('.');
  }

  List<Type> getTrueTypeList(bool visibleOnly) {
    return getSafeListFor<Type>(ListKey.getConstant<Type>('TYPE'));
  }

  @override
  bool isType(String aType) {
    if (aType.isEmpty) return false;
    String myType;
    if (aType.startsWith('!')) {
      myType = aType.substring(1).toUpperCase();
    } else if (aType.startsWith('TYPE=') || aType.startsWith('TYPE.')) {
      myType = aType.substring(5).toUpperCase();
    } else {
      myType = aType.toUpperCase();
    }

    final parts = myType.split('.');
    final typeListKey = ListKey.getConstant<Type>('TYPE');
    for (final part in parts) {
      if (!containsInList(typeListKey, Type.getConstant(part))) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() => getDisplayName();

  bool isNamePI() {
    return getSafeObject<bool>(ObjectKey.getConstant<bool>('NAME_PI')) ?? false;
  }

  /// Returns the raw bonus list for this object. [pc] may be null.
  /// Subclasses may override to add conditional bonuses.
  List<dynamic> getRawBonusList(dynamic pc) {
    return getSafeListFor<dynamic>(ListKey.getConstant<dynamic>('BONUS'));
  }

  PObject clone() {
    throw UnimplementedError('PObject.clone() not implemented');
  }
}
