// Copyright PCGen authors.
//
// Translation of pcgen.core.PCTemplate

import 'package:flutter_pcgen/src/cdom/enumeration/integer_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/util/enumeration/view.dart';
import 'package:flutter_pcgen/src/util/enumeration/visibility.dart';
import 'pcobject.dart';

// The CDOMObject for Templates.
final class PCTemplate extends PObject {
  // ---------------------------------------------------------------------------
  // CR
  // ---------------------------------------------------------------------------

  /// Returns total CR adjustment at a given level and HD.
  int getCR(int level, int hitdice) {
    final crMod = getObject(ObjectKey.getConstant<dynamic>('CR_MODIFIER'));
    final base = (crMod as num?)?.toInt() ?? 0;
    final conditional = getConditionalTemplates(level, hitdice)
        .map((t) {
          final m = t.getObject(ObjectKey.getConstant<dynamic>('CR_MODIFIER'));
          return (m as num?)?.toInt() ?? 0;
        })
        .fold<int>(0, (sum, v) => sum + v);
    return base + conditional;
  }

  // ---------------------------------------------------------------------------
  // Removable
  // ---------------------------------------------------------------------------

  bool isRemovable() {
    final visibility =
        getSafe(ObjectKey.visibility) as Visibility?;
    if (visibility != null && visibility.isVisibleTo(View.visibleDisplay)) {
      return getSafe(ObjectKey.removable) as bool? ?? false;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Conditional templates
  // ---------------------------------------------------------------------------

  List<PCTemplate> getConditionalTemplates(int totalLevels, int totalHitDice) {
    final result = <PCTemplate>[];

    for (final rlt
        in getSafeListFor<PCTemplate>(ListKey.getConstant<PCTemplate>('REPEATLEVEL_TEMPLATES'))) {
      for (final lt
          in rlt.getSafeListFor<PCTemplate>(ListKey.getConstant<PCTemplate>('LEVEL_TEMPLATES'))) {
        final lvl = lt.getInt(IntegerKey.level) as int?;
        if (lvl != null && lvl <= totalLevels) result.add(lt);
      }
    }

    for (final lt
        in getSafeListFor<PCTemplate>(ListKey.getConstant<PCTemplate>('LEVEL_TEMPLATES'))) {
      final lvl = lt.getInt(IntegerKey.level) as int?;
      if (lvl != null && lvl <= totalLevels) result.add(lt);
    }

    for (final lt
        in getSafeListFor<PCTemplate>(ListKey.getConstant<PCTemplate>('HD_TEMPLATES'))) {
      final hdMax = lt.getInt(IntegerKey.hdMax) as int?;
      final hdMin = lt.getInt(IntegerKey.hdMin) as int?;
      if (hdMax != null &&
          hdMin != null &&
          hdMax >= totalHitDice &&
          hdMin <= totalHitDice) {
        result.add(lt);
      }
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Bonus list
  // ---------------------------------------------------------------------------

  @override
  List<dynamic> getRawBonusList(dynamic pc) {
    final list = <dynamic>[...super.getRawBonusList(pc)];

    for (final rlt
        in getSafeListFor<PCTemplate>(ListKey.getConstant<PCTemplate>('REPEATLEVEL_TEMPLATES'))) {
      for (final lt
          in rlt.getSafeListFor<PCTemplate>(ListKey.getConstant<PCTemplate>('LEVEL_TEMPLATES'))) {
        list.addAll(lt.getRawBonusList(pc));
      }
    }

    for (final lt
        in getSafeListFor<PCTemplate>(ListKey.getConstant<PCTemplate>('LEVEL_TEMPLATES'))) {
      list.addAll(lt.getRawBonusList(pc));
    }

    for (final lt
        in getSafeListFor<PCTemplate>(ListKey.getConstant<PCTemplate>('HD_TEMPLATES'))) {
      list.addAll(lt.getRawBonusList(pc));
    }

    return list;
  }

  @override
  String toString() => getDisplayName();
}
