// Copyright 2003 Chris Ward <frugal@purplewombat.co.uk>
//
// Translation of pcgen.persistence.lst.prereq.PreParserFactory

import '../../../core/prereq/prerequisite.dart';
import '../../../core/prereq/prerequisite_operator.dart';
import 'prerequisite_parser_interface.dart';

/// Singleton factory for parsing PRExxx prerequisite strings into Prerequisite objects.
///
/// Each parser is registered for the kinds it handles; the factory dispatches
/// parse() calls to the appropriate registered parser.
class PreParserFactory {
  static PreParserFactory? _instance;

  final Map<String, PrerequisiteParserInterface> _parserLookup = {};

  PreParserFactory._();

  static PreParserFactory getInstance() => _instance ??= PreParserFactory._();

  void register(PrerequisiteParserInterface parser) {
    for (final kind in parser.kindsHandled()) {
      final key = kind.toLowerCase();
      if (_parserLookup.containsKey(key)) {
        throw StateError(
            'Error registering ${parser.runtimeType} as "$kind" — already registered to '
            '${_parserLookup[key]!.runtimeType}');
      }
      _parserLookup[key] = parser;
    }
  }

  PrerequisiteParserInterface? _getParser(String kind) =>
      _parserLookup[kind.toLowerCase()];

  /// Parses a list of PRE strings into Prerequisite objects, swallowing errors.
  static List<Prerequisite> parseAll(List<String> preStrings) {
    final result = <Prerequisite>[];
    final factory = getInstance();
    for (final preStr in preStrings) {
      try {
        result.add(factory.parse(preStr));
      } catch (_) {
        // TODO: log error
      }
    }
    return result;
  }

  /// Parses a single PRE string (e.g. "PRELEVEL:5" or "!PRERACE:Human") into a
  /// Prerequisite. Throws [ArgumentError] if the string is malformed.
  Prerequisite parse(String prereqStr) {
    if (prereqStr.isEmpty) {
      throw ArgumentError('Null or empty PRE string');
    }
    final index = prereqStr.indexOf(':');
    if (index < 0) {
      throw ArgumentError("'$prereqStr' is a badly formatted prereq.");
    }

    var kind = prereqStr.substring(0, index);
    var formula = prereqStr.substring(index + 1);

    bool overrideQualify = false;
    if (formula.startsWith('Q:')) {
      formula = formula.substring(2);
      overrideQualify = true;
    }

    bool invertResult = false;
    if (kind.startsWith('!')) {
      invertResult = true;
      kind = kind.substring(1);
    }
    // Strip the "PRE" prefix (first 3 chars)
    kind = kind.substring(3);

    final parser = _getParser(kind);
    if (parser == null) {
      throw ArgumentError(
          "Can not determine which parser to use for '$prereqStr'");
    }

    Prerequisite prereq = parser.parse(kind, formula, invertResult, overrideQualify);

    // Unwrap single-child PREMULT wrappers
    while (prereq.kind == null &&
        prereq.getPrerequisiteCount() == 1 &&
        prereq.operator == PrerequisiteOperator.gteq &&
        prereq.operand == '1') {
      prereq = prereq.getPrerequisites()[0];
    }

    return prereq;
  }

  /// Returns true if [token] looks like a PRE string.
  static bool isPreReqString(String token) =>
      (token.startsWith('PRE') || token.startsWith('!PRE')) &&
      token.contains(':');

  static void clear() {
    _instance?._parserLookup.clear();
  }
}
