import 'cdom_object.dart';
import 'prereq_object.dart';

/// A CDOMList is an identifier used to identify CDOMObject relationships.
///
/// It is intended to be used in situations where groups of CDOMObjects require
/// some form of additional information beyond mere presence. One example would
/// be the Spell Level of a given Spell in a CDOMList of Spells.
abstract interface class CDOMList<T extends CDOMObject>
    implements PrereqObject {
  /// Returns the Type of Object this CDOMList will identify.
  Type getListClass();

  /// Returns the key name for this CDOMList.
  String getKeyName();

  /// Returns true if this CDOMList has the given Type.
  bool isType(String type);

  /// Returns a representation of this CDOMList, suitable for storing in an LST
  /// file.
  String getLSTformat();
}
