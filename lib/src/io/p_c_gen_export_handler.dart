// Translation of pcgen.io.PCGenExportHandler

import '../core/player_character.dart';
import 'export_handler.dart';

/// PCGen-specific export handler that coordinates template processing.
class PCGenExportHandler extends ExportHandler {
  PCGenExportHandler(super.templatePath);

  @override
  void export(PlayerCharacter pc, StringSink output) {
    // TODO: full implementation
  }
}
