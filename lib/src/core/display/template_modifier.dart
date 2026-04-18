// Copyright (c) Tom Parker, 2008.
//
// Translation of pcgen.core.display.TemplateModifier

import 'non_ability_display.dart';

/// Utilities for building modifier summary strings from PCTemplate objects.
class TemplateModifier {
  TemplateModifier._();

  /// Generates a human-readable summary of the modifiers a [pct] (PCTemplate)
  /// applies to [aPC].
  ///
  /// Includes stat changes, DR, AC bonus, CR, and SR.
  static String modifierString(dynamic pct, dynamic aPC) {
    final mods = StringBuffer();
    final id = aPC.getCharID();
    final display = aPC.getDisplay();

    // Stat modifiers
    final stats = aPC.getStatFacet().getSet(id) as Iterable? ?? const [];
    for (final stat in stats) {
      if (NonAbilityDisplay.isNonAbilityForObject(stat, pct)) {
        mods.write('${stat.getKeyName()}:nonability ');
      } else {
        final statMod = aPC.getStatMod(pct, stat) as int? ?? 0;
        if (statMod != 0) {
          mods.write('${stat.getKeyName()}:$statMod ');
        }
      }
    }

    // Damage Reduction
    final totalLevels = display.getTotalLevels() as int? ?? 0;
    final totalHitDice = display.totalHitDice() as int? ?? 0;
    final templList = [pct, ...pct.getConditionalTemplates(totalLevels, totalHitDice) as Iterable];

    final drMap = <dynamic, Set<Object>>{};
    for (final subt in templList) {
      final tList = subt.getListFor('DAMAGE_REDUCTION') as List? ?? [];
      for (final dr in tList) {
        drMap.putIfAbsent(dr, () => {}).add(pct);
      }
    }
    if (drMap.isNotEmpty) {
      mods.write('DR:${aPC.getDRFacet().getDRString(id, drMap)}');
    }

    // AC bonus (only if not controlled by formula)
    if (!aPC.hasControl('ACVARTOTAL')) {
      final nat = aPC.charBonusTo(pct, 'COMBAT', 'AC') as int? ?? 0;
      if (nat != 0) mods.write('AC BONUS:$nat');
    }

    // CR
    final cr = pct.getCR(totalLevels, totalHitDice) as double? ?? 0.0;
    if (cr != 0.0) mods.write('CR:$cr ');

    // SR
    final sr = display.getTemplateSR(pct, totalLevels, totalHitDice) as int? ?? 0;
    if (sr != 0) mods.write('SR:$sr ');

    return mods.toString();
  }
}
