// Translation of pcgen.io.PCGenExportHandler

import '../core/player_character.dart';
import 'export_exception.dart';
import 'export_handler.dart';

/// PCGen-specific template export handler.
///
/// Processes PCGen's own character-sheet template format: a text file where
/// |TOKEN| markers are replaced with values resolved from the character.
/// Supports FOR/IIF control structures and sub-token lookup.
///
/// In the original Java code PCGenExportHandler is a package-private subclass
/// of ExportHandler.  In the Dart port the concrete implementation lives here;
/// [ExportHandler.createExportHandler] delegates to this class for non-FTL
/// templates.
///
/// Translation of pcgen.io.PCGenExportHandler.
class PCGenExportHandler extends ExportHandler {
  /// Token delimiter used in PCGen templates.
  static const String _tokenDelimiter = '|';

  /// Regex to find |TOKEN| (and |TOKEN.sub| / |TOKEN n| etc.) patterns.
  static final RegExp _tokenPattern =
      RegExp(r'\|([A-Z][A-Z0-9._]*(?:\s+\d+)?)\|');

  PCGenExportHandler(super.templatePath);

  // ---------------------------------------------------------------------------
  // ExportHandler implementation
  // ---------------------------------------------------------------------------

  @override
  void export(PlayerCharacter pc, StringSink output) {
    // TODO: implement full template engine:
    //   1. Read templatePath from disk (or asset bundle in Flutter).
    //   2. Pre-process FOR / ENDFOR blocks into loop structures.
    //   3. Pre-process IIF / ELSE / ENDIF into conditional structures.
    //   4. Walk the resulting tree, substituting |TOKEN| values.
    //   5. Write processed text to [output].
    throw ExportException(
        'PCGenExportHandler: template engine not yet implemented '
        'for template: $templatePath');
  }

  @override
  void exportParty(List<PlayerCharacter> characters, StringSink output) {
    // Party sheets export all characters through the same template with a
    // loop variable controlling which character is active.
    for (final pc in characters) {
      export(pc, output);
    }
  }

  // ---------------------------------------------------------------------------
  // Internal helpers (skeleton implementations)
  // ---------------------------------------------------------------------------

  /// Replaces all |TOKEN| occurrences in [templateLine] with their values
  /// for [pc].
  ///
  /// Returns the processed line.
  String processLine(String templateLine, PlayerCharacter pc) {
    return templateLine.replaceAllMapped(_tokenPattern, (match) {
      final tokenString = match.group(1) ?? '';
      return getTokenValue(tokenString, pc) ?? match.group(0)!;
    });
  }

  /// Evaluates a JEP-style arithmetic or boolean expression used inside
  /// IIF conditions.
  ///
  /// Returns the numeric result, or 0.0 on parse failure.
  double evaluateExpression(String expr, PlayerCharacter pc) {
    // TODO: implement JEP expression evaluation; for now try a simple
    //       numeric literal.
    return double.tryParse(expr.trim()) ?? 0.0;
  }
}
