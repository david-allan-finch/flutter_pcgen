// Copyright (c) Frugal, 2003.
//
// Translation of pcgen.core.prereq.Prerequisite

import 'package:flutter_pcgen/src/core/prereq/prerequisite_exception.dart';
import 'package:flutter_pcgen/src/core/prereq/prerequisite_operator.dart';

/// Storage format for all prerequisites. Populated by a parser, written out
/// by a writer, and tested by a tester class.
class Prerequisite {
  static const String applyKind = 'APPLY';

  String? kind;
  String? key;
  String? subKey;
  List<Prerequisite>? _prerequisites;
  PrerequisiteOperator operator = PrerequisiteOperator.gteq;
  String operand = '1';
  bool totalValues = false;
  bool characterRequired = true;
  bool countMultiples = false;
  bool overrideQualify = false;
  String? categoryName;

  void addPrerequisite(Prerequisite prereq) {
    _prerequisites ??= [];
    _prerequisites!.add(prereq);
  }

  List<Prerequisite> getPrerequisites() {
    return _prerequisites == null
        ? const []
        : List.unmodifiable(_prerequisites!);
  }

  int getPrerequisiteCount() => _prerequisites?.length ?? 0;

  void removePrerequisite(Prerequisite prereq) {
    _prerequisites?.remove(prereq);
  }

  void setOperatorByName(String operatorName) {
    operator = PrerequisiteOperator.getOperatorByName(operatorName);
  }

  /// Generates a compact display string (e.g. "PRE:FEAT:Dodge").
  String specify() {
    final buf = StringBuffer();
    if (kind != null) {
      buf.write('PRE');
      if (operator == PrerequisiteOperator.lt) {
        buf.write('!');
      }
      buf.write(kind!.toUpperCase());
      buf.write(':');
    }
    buf.write(operand);
    if (key != null) {
      buf.write(',');
      buf.write(key);
      if (subKey != null) {
        buf.write('=');
        buf.write(subKey);
      }
    }
    return buf.toString();
  }

  @override
  String toString() => specify();

  Prerequisite clone() {
    final copy = Prerequisite()
      ..kind = kind
      ..key = key
      ..subKey = subKey
      ..operator = operator
      ..operand = operand
      ..totalValues = totalValues
      ..characterRequired = characterRequired
      ..countMultiples = countMultiples
      ..overrideQualify = overrideQualify
      ..categoryName = categoryName;
    if (_prerequisites != null) {
      copy._prerequisites = _prerequisites!.map((p) => p.clone()).toList();
    }
    return copy;
  }
}
