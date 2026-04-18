// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.DamageReductionFacet

import '../base/cdom_object.dart';
import '../content/damage_reduction.dart';
import '../enumeration/char_id.dart';
import '../enumeration/list_key.dart';
import 'base/abstract_sourced_list_facet.dart';
import 'bonus_checking_facet.dart';
import 'cdom_object_consolidation_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';
import 'formula_resolving_facet.dart';
import 'prerequisite_facet.dart';

/// Tracks [DamageReduction] objects granted to a Player Character.
class DamageReductionFacet
    extends AbstractSourcedListFacet<CharID, DamageReduction>
    implements DataFacetChangeListener<CharID, CDOMObject> {
  late PrerequisiteFacet prerequisiteFacet;
  late FormulaResolvingFacet formulaResolvingFacet;
  late BonusCheckingFacet bonusCheckingFacet;
  late CDOMObjectConsolidationFacet consolidationFacet;

  static final _orPattern = RegExp(r' [oO][rR] ');
  static final _andPattern = RegExp(r' [aA][nN][dD] ');

  @override
  void dataAdded(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    final cdo = dfce.getCDOMObject();
    final drs =
        cdo.getListFor(ListKey.getConstant<DamageReduction>('DAMAGE_REDUCTION'));
    if (drs != null) {
      addAll(dfce.getCharID(), drs, cdo);
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, CDOMObject> dfce) {
    removeAll(dfce.getCharID(), dfce.getCDOMObject());
  }

  Map<String, int> _getDRMap(
      CharID id, Map<DamageReduction, Set<Object>>? componentMap) {
    final andMap = <String, int>{};
    if (componentMap == null || componentMap.isEmpty) return andMap;
    final orMap = <String, int>{};

    for (final entry in componentMap.entries) {
      final dr = entry.key;
      for (final source in entry.value) {
        if (prerequisiteFacet.qualifies(id, dr, source)) {
          final sourceString =
              (source is CDOMObject) ? source.getQualifiedKey() : '';
          final rawDrValue = formulaResolvingFacet
              .resolve(id, dr.getReduction(), sourceString)
              .toInt();
          final bypass = dr.getBypass();
          if (_orPattern.hasMatch(bypass)) {
            final current = orMap[bypass];
            if (current == null || current < rawDrValue) {
              orMap[bypass] = rawDrValue;
            }
          } else {
            final splits = bypass.split(_andPattern);
            if (splits.length == 1) {
              final current = andMap[bypass];
              if (current == null || current < rawDrValue) {
                andMap[bypass] = rawDrValue;
              }
            } else {
              for (final split in splits) {
                final current = andMap[split];
                if (current == null || current < rawDrValue) {
                  andMap[split] = rawDrValue;
                }
              }
            }
          }
        }
      }
    }

    // Merge OR entries that aren't superseded by AND entries
    for (final entry in orMap.entries) {
      final origBypass = entry.key;
      final reduction = entry.value;
      final orValues = origBypass.split(_orPattern);
      var shouldAdd = true;
      for (final orValue in orValues) {
        final andDR = andMap[orValue];
        if (andDR != null && andDR >= reduction) {
          shouldAdd = false;
          break;
        }
      }
      if (shouldAdd) {
        andMap[origBypass] = reduction;
      }
    }
    return andMap;
  }

  /// Returns the full DR string for display (e.g. "10/magic; 5/silver").
  String getDRString(CharID id,
      [Map<DamageReduction, Set<Object>>? cachedMap]) {
    cachedMap ??= getCachedMap(id);
    final map = _getDRMap(id, cachedMap);
    // Group by reduction value descending, build output
    final grouped = <int, List<String>>{};
    for (final entry in map.entries) {
      final key = entry.key;
      final value =
          entry.value + bonusCheckingFacet.getBonus(id, 'DR', key).toInt();
      (grouped[value] ??= []).add(key);
    }
    final sb = StringBuffer();
    bool needSep = false;
    for (final reduction in (grouped.keys.toList()..sort())) {
      final bypassList = grouped[reduction]!..sort();
      for (final bypass in bypassList) {
        if (needSep) sb.write('; ');
        sb.write('$reduction/$bypass');
        needSep = true;
      }
    }
    return sb.toString();
  }

  /// Returns the DR value for [key], including bonuses.
  int getDR(CharID id, String key) {
    return _getNonBonusDR(id, key) +
        bonusCheckingFacet.getBonus(id, 'DR', key).toInt();
  }

  int _getNonBonusDR(CharID id, String key) {
    return _getDRMap(id, getCachedMap(id))[key] ?? 0;
  }

  void init() {
    consolidationFacet.addDataFacetChangeListener(this);
  }
}
