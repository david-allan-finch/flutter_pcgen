// Copyright 2001 Bryan McRoberts / 2003 Chris Ward <frugal@purplewombat.co.uk>
//
// Translation of pcgen.persistence.lst.prereq.AbstractPrerequisiteListParser

import 'package:flutter_pcgen/src/core/prereq/prerequisite.dart';
import 'package:flutter_pcgen/src/core/prereq/prerequisite_operator.dart';
import 'package:flutter_pcgen/src/persistence/lst/prereq/abstract_prerequisite_parser.dart';
import 'package:flutter_pcgen/src/persistence/lst/prereq/prerequisite_parser_interface.dart';

/// Abstract base for PRE parsers that handle list-style formulas
/// (e.g. "1,Elf,Human" or "2,SKILL.Spellcraft=5,SKILL.Concentration=5").
abstract class AbstractPrerequisiteListParser extends AbstractPrerequisiteParser
    implements PrerequisiteParserInterface {
  @override
  Prerequisite parse(
      String kind, String formula, bool invertResult, bool overrideQualify) {
    final prereq = super.parse(kind, formula, invertResult, overrideQualify);
    _parsePrereqListType(prereq, kind, formula);
    if (invertResult) {
      prereq.operator = prereq.operator?.invert() ?? prereq.operator!;
    }
    return prereq;
  }

  /// Converts key sub-values in parentheses to subKey fields recursively.
  void convertKeysToSubKeys(Prerequisite? prereq, String kind) {
    if (prereq == null) return;
    if (prereq.kind != null &&
        prereq.kind!.toLowerCase() == kind.toLowerCase()) {
      var key = (prereq.key ?? '').trim();
      final open = key.indexOf('(');
      final close = key.lastIndexOf(')');
      if (open >= 0 && close == key.length - 1) {
        prereq.subKey = key.substring(open + 1, close).trim();
        prereq.key = key.substring(0, open).trim();
      }
    }
    for (final child in prereq.getPrerequisites()) {
      convertKeysToSubKeys(child, kind);
    }
  }

  /// Sets characterRequired = false on [prereq] and all its children.
  void setNoNeedForChar(Prerequisite? prereq) {
    if (prereq == null) return;
    prereq.characterRequired = false;
    for (final child in prereq.getPrerequisites()) {
      setNoNeedForChar(child);
    }
  }

  /// Parses the list-format formula into [prereq].
  /// Override in subclasses for type-specific behaviour.
  void _parsePrereqListType(Prerequisite prereq, String kind, String formula) {
    // Split "count,item1,item2,..." format
    final parts = formula.split(',');
    if (parts.isEmpty) return;

    // First element is the count (minimum number that must match)
    final count = int.tryParse(parts[0]);
    if (count != null) {
      prereq.operand = count.toString();
      prereq.operator = PrerequisiteOperator.gteq;
      if (parts.length == 2) {
        // Single item — set directly on prereq
        prereq.key = parts[1];
      } else if (parts.length > 2) {
        // Multiple items — build PREMULT with sub-prerequisites
        prereq.kind = null; // becomes a wrapper
        for (int i = 1; i < parts.length; i++) {
          final sub = Prerequisite()
            ..kind = kind
            ..key = parts[i]
            ..operator = PrerequisiteOperator.gteq
            ..operand = '1';
          prereq.addPrerequisite(sub);
        }
      }
    } else {
      prereq.key = formula;
    }
  }

  bool isNoWarnElement(String element) => false;
  bool isAnyLegal() => true;
  String? getAssumedValue() => null;
  bool requiresValue() => false;
  bool allowsNegate() => false;
}
