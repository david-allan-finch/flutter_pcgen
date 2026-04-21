// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.core.system.LoadInfo

import 'package:flutter_pcgen/src/cdom/base/loadable.dart';

/// Stores load-related information for a game mode: strength-to-load mapping,
/// size multipliers, and load type multipliers.
class LoadInfo implements Loadable {
  Uri? _sourceUri;
  String? _loadInfoName;

  final Map<dynamic, double> rawSizeMultiplierMap = {};
  final Map<dynamic, double> _sizeMultiplierMap = {};
  final Map<int, double> _strengthLoadMap = {};

  int minStrengthScoreWithLoad = 0;
  int maxStrengthScoreWithLoad = 0;
  double loadScoreMultiplier = 0.0;
  int loadMultStep = 10;

  final Map<String, _LoadMapEntry> _loadMultiplierMap = {};

  String? modifyFormula;

  @override
  Uri? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(Uri source) => _sourceUri = source;

  @override
  String getKeyName() => _loadInfoName ?? '';

  @override
  void setKeyName(String key) => _loadInfoName = key;

  @override
  String getDisplayName() => _loadInfoName ?? '';

  void setLoadInfoName(String name) => _loadInfoName = name;
  String? getLoadInfoName() => _loadInfoName;

  void setLoadScoreMultiplier(double multiplier) =>
      loadScoreMultiplier = multiplier;
  double getLoadScoreMultiplier() => loadScoreMultiplier;

  void setLoadMultStep(int step) => loadMultStep = step;
  int getLoadMultStep() => loadMultStep;

  void addLoadScoreValue(int score, double load) {
    _strengthLoadMap[score] = load;
    if (score > maxStrengthScoreWithLoad) {
      maxStrengthScoreWithLoad = score;
    }
    if (_strengthLoadMap.length == 1) {
      minStrengthScoreWithLoad = score;
    } else if (score < minStrengthScoreWithLoad) {
      minStrengthScoreWithLoad = score;
    }
  }

  double getLoadScoreValue(int score) {
    if (score < minStrengthScoreWithLoad) return 0.0;
    if (_strengthLoadMap.containsKey(score)) {
      return _strengthLoadMap[score]!;
    }
    // Values above the table grow by loadScoreMultiplier per loadMultStep.
    if (score > maxStrengthScoreWithLoad) {
      final base = _strengthLoadMap[maxStrengthScoreWithLoad] ?? 0.0;
      final steps = (score - maxStrengthScoreWithLoad) ~/ loadMultStep;
      return base * (loadScoreMultiplier * steps);
    }
    // Find nearest lower key.
    int best = minStrengthScoreWithLoad;
    for (final k in _strengthLoadMap.keys) {
      if (k <= score && k > best) best = k;
    }
    return _strengthLoadMap[best] ?? 0.0;
  }

  void addSizeAdjustment(dynamic sizeRef, double multiplier) =>
      rawSizeMultiplierMap[sizeRef] = multiplier;

  void resolveSizeAdjustmentMap() {
    for (final entry in rawSizeMultiplierMap.entries) {
      _sizeMultiplierMap[entry.key.get()] = entry.value;
    }
  }

  double getSizeAdjustment(dynamic size) =>
      _sizeMultiplierMap[size] ?? 1.0;

  void addLoadMultiplier(
      String encumbranceType, double? value, String? formula, int? checkPenalty) {
    _loadMultiplierMap[encumbranceType] =
        _LoadMapEntry(value, formula, checkPenalty);
  }

  double? getLoadMultiplier(String encumbranceType) =>
      _loadMultiplierMap[encumbranceType]?.value;

  String? getLoadFormula(String encumbranceType) =>
      _loadMultiplierMap[encumbranceType]?.formula;

  int? getCheckPenalty(String encumbranceType) =>
      _loadMultiplierMap[encumbranceType]?.checkPenalty;

  void setModifyFormula(String formula) => modifyFormula = formula;
  String? getModifyFormula() => modifyFormula;
}

class _LoadMapEntry {
  final double? value;
  final String? formula;
  final int? checkPenalty;
  const _LoadMapEntry(this.value, this.formula, this.checkPenalty);
}
