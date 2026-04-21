// Copyright 2001 Bryan McRoberts / 2003 Chris Ward <frugal@purplewombat.co.uk>
//
// Translation of pcgen.persistence.lst.prereq.AbstractPrerequisiteParser

import 'package:flutter_pcgen/src/core/prereq/prerequisite.dart';
import 'package:flutter_pcgen/src/persistence/lst/prereq/prerequisite_parser_interface.dart';

/// Abstract base for prerequisite parsers. Validates the kind against
/// [kindsHandled] and builds a base Prerequisite with kind and overrideQualify set.
abstract class AbstractPrerequisiteParser implements PrerequisiteParserInterface {
  @override
  Prerequisite parse(
      String kind, String formula, bool invertResult, bool overrideQualify) {
    final handled =
        kindsHandled().any((k) => k.toLowerCase() == kind.toLowerCase());
    if (!handled) {
      throw ArgumentError(
          '${runtimeType} cannot parse a Prerequisite tag of "$kind:$formula"');
    }
    final prereq = Prerequisite()
      ..kind = kind
      ..overrideQualify = overrideQualify;
    return prereq;
  }

  /// Checks that [value] uses [separator] correctly (not at start/end, no doubles).
  /// Returns an error message string on failure, or null on success.
  String? checkForIllegalSeparator(String kind, String separator, String value) {
    if (value.startsWith(separator)) {
      return 'PRE$kind arguments may not start with $separator : $value';
    }
    if (value.endsWith(separator)) {
      return 'PRE$kind arguments may not end with $separator : $value';
    }
    if (value.contains('$separator$separator')) {
      return 'PRE$kind arguments uses double separator $separator$separator : $value';
    }
    return null;
  }
}
