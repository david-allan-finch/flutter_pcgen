import '../base/loadable.dart';

// Identifies a spell school (e.g. "Abjuration") as a Loadable object.
class SpellSchool implements Loadable, Comparable<SpellSchool> {
  String? _sourceUri;
  String? _name;

  @override
  String getDisplayName() => _name ?? '';

  @override
  String getKeyName() => _name ?? '';

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  @override
  void setName(String newName) => _name = newName;

  @override
  String toString() => _name ?? '';

  @override
  bool operator ==(Object other) =>
      other is SpellSchool && _name == other._name;

  @override
  int get hashCode => _name.hashCode;

  @override
  int compareTo(SpellSchool other) => (_name ?? '').compareTo(other._name ?? '');

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String source) => _sourceUri = source;
}
