// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.term.PCCountEquipmentTermEvaluator

import 'base_pc_term_evaluator.dart';
import 'term_evaluator.dart';

class PCCountEquipmentTermEvaluator extends BasePCTermEvaluator implements TermEvaluator {
  final List<String> types;
  final int merge;

  PCCountEquipmentTermEvaluator(String expressionString, this.types, this.merge) {
    originalText = expressionString;
  }

  @override
  double? resolve(dynamic pc) {
    final equipList = pc.getEquipmentListInOutputOrder(merge);
    List<dynamic> aList = List.from(equipList);

    int cur = 0;
    if (types[cur].isEmpty) {
      cur++;
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
