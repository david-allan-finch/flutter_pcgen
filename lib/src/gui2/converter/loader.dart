// Translation of pcgen.gui2.converter.Loader

import 'conversion_decider.dart';

/// Interface implemented by each LST file loader that knows how to process
/// a particular type of game-data file during dataset conversion.
abstract class Loader {
  /// Processes a single line from an LST file.
  ///
  /// [sb] accumulates the converted output for this line.
  /// [line] is the 0-based line index within the file.
  /// [lineString] is the raw text of the line.
  /// [decider] is used when user input is required for an ambiguous token.
  ///
  /// Returns a list of additional CDOMObjects that need to be injected into
  /// the output campaign, or null if none.
  List<dynamic>? process(
    StringBuffer sb,
    int line,
    String lineString,
    ConversionDecider decider,
  );

  /// Returns the list of source-entry files for this loader within [campaign].
  List<dynamic> getFiles(dynamic campaign);
}
