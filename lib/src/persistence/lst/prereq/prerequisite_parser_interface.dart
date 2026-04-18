// Copyright 2003 Chris Ward <frugal@purplewombat.co.uk>
//
// Translation of pcgen.persistence.lst.prereq.PrerequisiteParserInterface

import '../../../core/prereq/prerequisite.dart';

/// Interface for classes that parse PRExxx prerequisite tokens from LST files.
abstract interface class PrerequisiteParserInterface {
  /// Returns the list of prerequisite kind strings this parser handles
  /// (without the "PRE" prefix, e.g. ["STAT", "STATGTEQ"]).
  List<String> kindsHandled();

  /// Parses [formula] for the given [kind] into a Prerequisite object.
  ///
  /// [invertResult] — if true, invert the operator.
  /// [overrideQualify] — enforce even in the presence of QUALIFY tags.
  Prerequisite parse(
      String kind, String formula, bool invertResult, bool overrideQualify);
}
