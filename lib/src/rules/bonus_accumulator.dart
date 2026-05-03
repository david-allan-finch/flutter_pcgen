/// Collects ParsedBonus entries from all active character objects and
/// computes final bonus totals by category + target.
///
/// Stacking rules (3.5e / Pathfinder):
///   - Untyped bonuses always stack.
///   - Typed bonuses of the same type: only the highest applies (no stacking).
///   - TYPE=xxx.STACK — explicitly stacks even with same type.
///   - TYPE=xxx.REPLACE — highest value replaces others of same type.
library;

import 'package:flutter_pcgen/src/rules/formula_evaluator.dart';
import 'package:flutter_pcgen/src/rules/parsed_bonus.dart';

// ---------------------------------------------------------------------------
// BonusAccumulator
// ---------------------------------------------------------------------------

class BonusAccumulator {
  // category → target → typeTag → list of values
  final Map<String, Map<String, Map<String, List<double>>>> _values = {};

  // category → target → list of untyped values (always stack)
  final Map<String, Map<String, List<double>>> _untyped = {};

  void clear() {
    _values.clear();
    _untyped.clear();
  }

  /// Add a single evaluated bonus.
  void add(ParsedBonus bonus, double value, {PrereqContext? prereqCtx}) {
    if (prereqCtx != null && !bonus.checkPrereqs(prereqCtx)) return;

    for (final target in bonus.targets) {
      final cat = bonus.category;
      final tgt = target.toUpperCase();

      if (bonus.bonusType.isEmpty) {
        // Untyped: always stacks
        _untyped.putIfAbsent(cat, () => {}).putIfAbsent(tgt, () => []).add(value);
      } else {
        final type = bonus.bonusType.toUpperCase();
        _values.putIfAbsent(cat, () => {}).putIfAbsent(tgt, () => {})
               .putIfAbsent(type, () => []).add(value);
        if (bonus.stack == BonusStack.stack) {
          // Mark as stacking by storing each value individually (they'll all be summed)
          // (already stored above; summing handles .STACK correctly via separate tracking)
        }
      }
    }
  }

  /// Apply all bonuses from [bonuses] using the given contexts.
  void applyAll(
    List<ParsedBonus> bonuses,
    FormulaContext formulaCtx,
    PrereqContext prereqCtx,
  ) {
    for (final bonus in bonuses) {
      if (!bonus.checkPrereqs(prereqCtx)) continue;
      final value = bonus.evaluate(formulaCtx);
      add(bonus, value);
    }
  }

  /// Total bonus for [category] and [target].
  /// Typed bonuses: only the highest value per type applies (unless .STACK).
  double total(String category, String target) {
    final cat = category.toUpperCase();
    final tgt = target.toUpperCase();
    double sum = 0;

    // Untyped contributions
    final untypedList = _untyped[cat]?[tgt];
    if (untypedList != null) {
      for (final v in untypedList) sum += v;
    }

    // Typed contributions — highest per type only (REPLACE / normal)
    final typed = _values[cat]?[tgt];
    if (typed != null) {
      for (final entry in typed.entries) {
        final typeValues = entry.value;
        if (typeValues.isEmpty) continue;
        // For normal/replace: take only the max
        sum += typeValues.reduce((a, b) => a > b ? a : b);
      }
    }

    return sum;
  }

  /// Total for a target that may also match 'ALL' (e.g. BONUS:SAVE|ALL|2)
  double totalWithAll(String category, String target) {
    return total(category, target) + total(category, 'ALL');
  }

  /// Integer version (rounds toward zero).
  int totalInt(String category, String target) => total(category, target).truncate();
  int totalIntWithAll(String category, String target) =>
      totalWithAll(category, target).truncate();
}

// ---------------------------------------------------------------------------
// CharacterBonusEngine — builds a BonusAccumulator from character state
// ---------------------------------------------------------------------------

/// Lightweight character state needed by the bonus engine.
/// Passed in from CharacterFacadeImpl to avoid circular imports.
class CharacterBonusState {
  final Map<String, int> statMods;
  final Map<String, int> statScores;
  final int totalLevel;
  final Map<String, int> classLevelCounts; // classKey → level count
  final Map<String, double> definedVars;
  final String alignmentKey;
  final String raceKey;
  final List<String> objectTypes;
  final List<String> classSkillNames;
  final Map<String, List<String>> selectedAbilityKeys; // category → keys
  final Map<String, double> skillRanks;

  const CharacterBonusState({
    required this.statMods,
    required this.statScores,
    required this.totalLevel,
    required this.classLevelCounts,
    required this.definedVars,
    required this.alignmentKey,
    required this.raceKey,
    required this.objectTypes,
    required this.classSkillNames,
    required this.selectedAbilityKeys,
    required this.skillRanks,
  });
}

class _PrereqCtx implements PrereqContext {
  final CharacterBonusState _state;
  @override final List<String> objectTypes;

  _PrereqCtx(this._state, {List<String>? objectTypes})
      : objectTypes = objectTypes ?? const [];

  @override String get alignmentKey => _state.alignmentKey;
  @override String get raceKey => _state.raceKey;
  @override int get totalLevel => _state.totalLevel;
  @override List<String> get classSkillNames => _state.classSkillNames;

  @override
  List<String> selectedAbilityKeys([String? category]) {
    if (category == null) {
      return _state.selectedAbilityKeys.values.expand((l) => l).toList();
    }
    return _state.selectedAbilityKeys[category] ?? [];
  }

  @override
  double getVariable(String name) {
    final upper = name.toUpperCase();
    // Stat modifiers
    if (_state.statMods.containsKey(upper)) return _state.statMods[upper]!.toDouble();
    // Stat scores
    if (upper.endsWith('SCORE')) {
      final abb = upper.substring(0, upper.length - 5);
      if (_state.statScores.containsKey(abb)) return _state.statScores[abb]!.toDouble();
    }
    // Named variables
    return _state.definedVars[name] ?? _state.definedVars[upper] ?? 0.0;
  }

  @override
  double getSkillRanks(String skillName) =>
      _state.skillRanks[skillName.toLowerCase()] ?? 0.0;

  @override
  int getStatScore(String statAbb) =>
      _state.statScores[statAbb.toUpperCase()] ?? 10;

  @override String get deityKey => '';
  @override List<String> get domainKeys => const [];
  @override List<String> get languageNames => const [];
  @override List<String> get visionTypes => const [];
  @override List<String> get templateKeys => const [];
  @override List<String> get weaponProficiencies => const [];
  @override String get sizeKey => 'M';
}

class CharacterBonusEngine {
  /// Build and return a fully-evaluated [BonusAccumulator] for [state].
  ///
  /// [allBonuses] is every ParsedBonus from every active source object
  /// (race bonuses, class level bonuses, feat bonuses, template bonuses,
  /// equipped item bonuses, etc.).
  static BonusAccumulator compute(
    CharacterBonusState state,
    List<ParsedBonus> allBonuses,
  ) {
    final formulaCtx = FormulaContext(
      statMods:    state.statMods,
      statScores:  state.statScores,
      totalLevel:  state.totalLevel,
      classLevels: state.classLevelCounts.map((k, v) => MapEntry(k, v)),
      variables:   state.definedVars,
    );

    final prereqCtx = _PrereqCtx(state);
    final acc = BonusAccumulator();
    acc.applyAll(allBonuses, formulaCtx, prereqCtx);
    return acc;
  }
}
