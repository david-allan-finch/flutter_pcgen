// Translation of pcgen.io.ExportHandler

import '../core/player_character.dart';
import 'export_exception.dart';

/// Processes a character sheet template and writes output for a character.
class ExportHandler {
  final String templatePath;

  ExportHandler(this.templatePath);

  /// Export [pc] to [output] using this handler's template.
  void export(PlayerCharacter pc, StringSink output) {
    // TODO: full implementation — tokenize template, resolve tokens
    throw ExportException('ExportHandler not yet implemented');
  }

  /// Export a party of [characters] to [output].
  void exportParty(List<PlayerCharacter> characters, StringSink output) {
    // TODO: full implementation
    throw ExportException('ExportHandler.exportParty not yet implemented');
  }
}
