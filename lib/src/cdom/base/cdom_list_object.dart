import 'cdom_list.dart';
import 'cdom_object.dart';
import 'concrete_prereq_object.dart';
import 'loadable.dart';

/// This is an abstract object intended to be used as a basis for "concrete"
/// CDOMList objects.
///
/// CDOMListObject provides basic equality, ensuring matching Class, matching
/// underlying class (the Class of objects in the CDOMList) and matching List
/// name. It does not fully test the underlying CDOMObject contents.
abstract class CDOMListObject<T extends CDOMObject> extends ConcretePrereqObject
    implements CDOMList<T>, Loadable {
  String? _name;
  String? _keyName;
  String? _sourceURI;

  @override
  String getKeyName() => _keyName ?? _name ?? '';

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) {
    _sourceURI = source;
  }

  void setKeyName(String key) {
    _keyName = key;
  }

  @override
  String getDisplayName() => _name ?? '';

  @override
  String getLSTformat() => getKeyName();

  @override
  bool isInternal() => false;

  @override
  void setName(String n) {
    _name = n;
  }

  @override
  String toString() => getKeyName();
}
