import '../cdom/base/loadable.dart';

// Configuration for a class type (Base, Monster, Prestige, etc.).
final class ClassType implements Loadable {
  String? _sourceURI;
  String _name = '';
  String crFormula = '';
  String crMod = '';
  int crModPriority = 0;
  bool xpPenalty = true;
  bool isMonster = false;

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  String getKeyName() => _name;

  @override
  String? getDisplayName() => _name;

  @override
  void setName(String name) { _name = name; }

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  ClassType clone() => ClassType()
    .._sourceURI = _sourceURI
    .._name = _name
    ..crFormula = crFormula
    ..crMod = crMod
    ..crModPriority = crModPriority
    ..xpPenalty = xpPenalty
    ..isMonster = isMonster;
}
