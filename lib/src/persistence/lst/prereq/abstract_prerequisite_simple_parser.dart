// Copyright 2003 Chris Ward <frugal@purplewombat.co.uk>
//
// Translation of pcgen.persistence.lst.prereq.AbstractPrerequisiteSimpleParser

import 'package:flutter_pcgen/src/core/prereq/prerequisite.dart';
import 'package:flutter_pcgen/src/core/prereq/prerequisite_operator.dart';
import 'package:flutter_pcgen/src/persistence/lst/prereq/abstract_prerequisite_parser.dart';

/// Parses prerequisites where the formula is a simple key string (e.g. PRERACE:Human).
/// Sets key = formula and operator = EQ (optionally inverted).
abstract class AbstractPrerequisiteSimpleParser
    extends AbstractPrerequisiteParser {
  @override
  Prerequisite parse(
      String kind, String formula, bool invertResult, bool overrideQualify) {
    final prereq = super.parse(kind, formula, invertResult, overrideQualify);
    prereq.key = formula;
    prereq.operator = PrerequisiteOperator.eq;
    if (invertResult) {
      prereq.operator = prereq.operator?.invert() ?? prereq.operator!;
    }
    return prereq;
  }
}
