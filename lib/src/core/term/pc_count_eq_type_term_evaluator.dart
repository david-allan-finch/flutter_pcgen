// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountEqTypeTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountEqTypeTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final List<String> types;
  final int merge;

  PCCountEqTypeTermEvaluator(String originalText, this.types, this.merge) {
    this.originalText = originalText;
  }

  @override
  double? resolve(dynamic pc) {
    List<dynamic> aList = [];
    int cur = 0;
    final aType = types[cur];

    if (aType == 'CONTAINER') {
      cur++;
      final equipList = pc.getEquipmentListInOutputOrder(merge);
      for (final eq in equipList) {
        if (eq.isContainer() == true) {
          aList.add(eq);
        }
      }
    } else if (aType.toLowerCase() == 'weapon') {
      cur++;
      aList = List.from(pc.getExpandedWeapons(merge));
    } else if (aType.toLowerCase() == 'acitem') {
      cur++;
      final equipList = pc.getEquipmentListInOutputOrder(merge);
      for (final eq in equipList) {
        if (eq.altersAC(pc) == true && eq.isArmor() != true && eq.isShield() != true) {
          aList.add(eq);
        }
      }
    } else if (aType.isEmpty) {
      cur++;
      aList = List.from(pc.getEquipmentOfTypeInOutputOrder(aType, 3, merge));
    } else {
      aList = List.from(pc.getEquipmentOfTypeInOutputOrder(aType, 3, merge));
    }

    while (cur < types.length) {
      final curTok = types[cur];
      cur++;
      if (curTok.toLowerCase() == 'not') {
        aList = List.from(pc.removeEqType(aList, types[cur]));
        cur++;
      } else if (curTok.toLowerCase() == 'add') {
        aList = List.from(pc.addEqType(aList, types[cur]));
        cur++;
      } else if (curTok.toLowerCase() == 'is') {
        aList = List.from(pc.removeNotEqType(aList, types[cur]));
        cur++;
      } else if (curTok.toLowerCase() == 'equipped' || curTok.toLowerCase() == 'notequipped') {
        final eFlag = curTok.toLowerCase() == 'equipped';
        aList.removeWhere((eq) => eq.isEquipped() != eFlag);
      }
    }

    return aList.length.toDouble();
  }

  @override
  bool isSourceDependant() => false;
}
