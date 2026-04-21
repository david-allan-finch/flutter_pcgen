// Translation of pcgen.io.FreeMarkerExportHandler

import 'package:flutter_pcgen/src/core/player_character.dart';
import 'export_handler.dart';

/// Export handler that uses FreeMarker templates (stubbed — not available in Dart).
class FreeMarkerExportHandler extends ExportHandler {
  FreeMarkerExportHandler(super.templatePath);

  @override
  void export(PlayerCharacter pc, StringSink output) {
    // TODO: FreeMarker templates not available in Dart — needs reimplementation
  }
}
