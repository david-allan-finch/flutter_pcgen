// Translation of pcgen.system.BatchExporter

import 'dart:io';

import '../core/player_character.dart';
import '../facade/core/character_facade.dart';
import '../io/export_handler.dart';

/// Exports characters to output sheets in batch (non-interactive) mode.
///
/// Can be used either with an instance (providing the template at construction
/// time) or via static helpers when the caller already has loaded characters.
///
/// Translation of pcgen.system.BatchExporter.
class BatchExporter {
  final String exportTemplateFilename;
  final bool isPdf;

  BatchExporter(this.exportTemplateFilename)
      : isPdf = exportTemplateFilename.toLowerCase().endsWith('.xslt') ||
            exportTemplateFilename.toLowerCase().endsWith('.fo');

  // ---------------------------------------------------------------------------
  // Instance export methods (load + export in one step)
  // ---------------------------------------------------------------------------

  /// Loads the character from [characterFilename], then exports it using the
  /// template registered at construction time.
  ///
  /// If [outputFilename] is null, a default output file is derived from the
  /// character filename and template type.
  ///
  /// Returns true if the export succeeded.
  Future<bool> exportCharacterFromFile({
    required String characterFilename,
    String? outputFilename,
  }) async {
    // TODO: load sources from character's source selection, load character via
    //       PCGIOHandler, then call exportCharacter.
    return false;
  }

  /// Exports a party file (.pcp) at [partyFilename] using the registered
  /// template.
  Future<bool> exportPartyFromFile({
    required String partyFilename,
    String? outputFilename,
  }) async {
    // TODO: load all characters in the party file, call exportParty.
    return false;
  }

  // ---------------------------------------------------------------------------
  // Static export methods (pre-loaded characters)
  // ---------------------------------------------------------------------------

  /// Exports [character] to [outputFile] using [sheetFile] as the template.
  ///
  /// Returns true if the export succeeded without errors.
  static bool exportCharacter(
      PlayerCharacter character, String sheetFile, String outputFile) {
    try {
      final handler = ExportHandler(sheetFile);
      final sink = StringBuffer();
      handler.export(character, sink);
      File(outputFile).writeAsStringSync(sink.toString());
      return true;
    } catch (e) {
      print('ERROR: Failed to export character to $outputFile: $e');
      return false;
    }
  }

  /// Exports [character] to [outputFile] as a PDF.
  ///
  /// Requires an FOP-equivalent pipeline. Returns true on success.
  static Future<bool> exportCharacterToPdf(
      PlayerCharacter character, String sheetFile, String outputFile) async {
    // TODO: render via an FO→PDF pipeline (e.g. using a native PDF library or
    //       spawning an external FOP process) when the PDF pipeline is ported.
    return false;
  }

  /// Exports all [characters] to [outputFile] using the party sheet [sheetFile].
  static bool exportParty(
      List<PlayerCharacter> characters, String sheetFile, String outputFile) {
    try {
      final handler = ExportHandler(sheetFile);
      final sink = StringBuffer();
      handler.exportParty(characters, sink);
      File(outputFile).writeAsStringSync(sink.toString());
      return true;
    } catch (e) {
      print('ERROR: Failed to export party to $outputFile: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Utility helpers
  // ---------------------------------------------------------------------------

  /// Derives a default output filename from [inputFilename] and the template
  /// extension.
  static String defaultOutputFilename(String inputFilename, String templateFile) {
    final dot = inputFilename.lastIndexOf('.');
    final base = dot == -1 ? inputFilename : inputFilename.substring(0, dot);
    final ext = _outputExtension(templateFile);
    return '$base.$ext';
  }

  static String _outputExtension(String templateFile) {
    final lower = templateFile.toLowerCase();
    if (lower.endsWith('.htm') || lower.endsWith('.html')) return 'html';
    if (lower.endsWith('.pdf') || lower.endsWith('.fo') ||
        lower.endsWith('.xslt')) return 'pdf';
    if (lower.endsWith('.txt')) return 'txt';
    if (lower.endsWith('.rtf')) return 'rtf';
    if (lower.endsWith('.xml')) return 'xml';
    return 'out';
  }
}
