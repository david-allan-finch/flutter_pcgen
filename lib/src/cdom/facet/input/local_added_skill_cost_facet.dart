// Translated from PCGen Java source to Dart.
// Source: pcgen/cdom/facet/input/LocalAddedSkillCostFacet.java

/// LocalAddedSkillCostFacet stores directly set SkillCost objects, which are
/// the result of a number of possibilities: ADD:CLASSSKILLS as well as
/// CSKILL:%LIST or CCSKILL:%LIST in a Domain are both examples that use
/// LocalAddedSkillCostFacet.
///
/// Parameterized as: scope=PCClass, subscope=SkillCost, value=Skill
/// (Java: AbstractSubScopeFacet<PCClass, SkillCost, Skill>)
class LocalAddedSkillCostFacet {
  // AbstractSubScopeFacet state: Map<PCClass, Map<SkillCost, Set<Skill>>>
  final Map<dynamic, Map<dynamic, Set<dynamic>>> _cache = {};

  void add(dynamic scope, dynamic subScope, dynamic value, dynamic source) {
    _cache.putIfAbsent(scope, () => {}).putIfAbsent(subScope, () => {}).add(value);
  }

  void remove(dynamic scope, dynamic subScope, dynamic value, dynamic source) {
    _cache[scope]?[subScope]?.remove(value);
  }

  Set<dynamic> getSet(dynamic scope, dynamic subScope) {
    return _cache[scope]?[subScope] ?? {};
  }
}
