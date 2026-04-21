// Copyright 2003 Chris Ward <frugal@purplewombat.co.uk>
//
// Translation of pcgen.persistence.lst.prereq.AbstractPrerequisiteIntegerParser

import 'package:flutter_pcgen/src/core/prereq/prerequisite.dart';
import 'abstract_prerequisite_parser.dart';

/// Parses prerequisites where the formula is a single integer (e.g. PRELEVEL:5).
abstract class AbstractPrerequisiteIntegerParser
    extends AbstractPrerequisiteParser {
  @override
  Prerequisite parse(
      String kind, String formula, bool invertResult, bool overrideQualify) {
    final prereq = super.parse(kind, formula, invertResult, overrideQualify);
    final n = int.tryParse(formula);
    if (n == null) {
      throw FormatException("'$formula' is not a valid integer");
    }
    prereq.operand = n.toString();
    if (invertResult) {
      prereq.operator = prereq.operator?.invert();
    }
    return prereq;
  }
}
