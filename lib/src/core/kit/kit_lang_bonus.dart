// Copyright (c) James Dempsey, 2008.
//
// Translation of pcgen.core.kit.KitLangBonus

import 'package:flutter_pcgen/src/core/kit/base_kit.dart';

/// Applies bonus languages to a character via a kit.
class KitLangBonus extends BaseKit {
  /// References to Language objects (CDOMSingleRef<Language>).
  final List<dynamic> langList = [];

  // Transient state set during testApply, consumed by apply.
  List<dynamic> _theLanguages = [];

  @override
  void apply(dynamic aPC) {
    final cna = aPC.getBonusLanguageAbility();
    for (final lang in _theLanguages) {
      aPC.addAbility(
        _CNAbilitySelection(cna, lang.getKeyName()),
        _UserSelection.instance,
        _UserSelection.instance,
      );
    }
  }

  @override
  bool testApply(dynamic aKit, dynamic aPC, List<String> warnings) {
    _theLanguages = [];
    final cna = aPC.getBonusLanguageAbility();
    final reservedList = <String>[];

    final controller = _getController(cna, aPC, reservedList);
    if (controller == null) return false;

    final allowedCount =
        (aPC.getAvailableAbilityPool(_langBonusCategory) as num).toInt();
    int remaining = allowedCount;

    for (final ref in langList) {
      final lang = ref.get();
      if (remaining > 0 && controller.conditionallyApply(aPC, lang)) {
        _theLanguages.add(lang);
        remaining--;
      } else {
        warnings
            .add('LANGUAGE: Could not add bonus language "${lang.getKeyName()}"');
      }
    }

    if (langList.length > allowedCount) {
      warnings.add('LANGUAGE: Too many bonus languages specified. '
          '${langList.length - allowedCount} had to be ignored.');
    }

    return _theLanguages.isNotEmpty;
  }

  @override
  String getObjectName() => 'Languages';

  @override
  String toString() {
    return langList.map((r) => r.getLSTformat(false)).join(', ');
  }

  void addLanguage(dynamic reference) => langList.add(reference);

  List<dynamic> getLanguages() => langList;
}

// Placeholder stand-ins — replace with real implementations.
dynamic _getController(dynamic cna, dynamic aPC, List<String> reservedList) =>
    null; // TODO: ChooserUtilities.getConfiguredController
dynamic get _langBonusCategory => null; // TODO: AbilityCategory.LANGBONUS

class _UserSelection {
  static final _UserSelection instance = _UserSelection._();
  _UserSelection._();
}

class _CNAbilitySelection {
  final dynamic cna;
  final String keyName;
  _CNAbilitySelection(this.cna, this.keyName);
}
