// Copyright 2004 Frugal <frugal@purplewombat.co.uk>
//
// Translation of pcgen.persistence.lst.output.prereq.AbstractPrerequisiteWriter

import '../../../../core/prereq/prerequisite.dart';
import '../../../../core/prereq/prerequisite_operator.dart';

/// Base class for Prerequisite LST serialisers. Provides operator validation.
class AbstractPrerequisiteWriter {
  /// Throws if [prereq]'s operator is not in [comparators].
  void checkValidOperator(
      Prerequisite prereq, List<PrerequisiteOperator> comparators) {
    for (final comparator in comparators) {
      if (prereq.operator == comparator) return;
    }
    final kind = prereq.kind?.toUpperCase() ?? '<NULL>';
    final ops = comparators.map((c) => c.toString()).join(', ');
    throw StateError(
        'Cannot write token: LST syntax only supports $ops operators for PRE$kind: $prereq');
  }

  /// Override in subclasses to handle special-case output.
  bool specialCase(StringSink writer, Prerequisite prereq) => false;
}
