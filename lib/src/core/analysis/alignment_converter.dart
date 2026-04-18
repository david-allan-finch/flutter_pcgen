import '../../globals.dart';
import '../pc_alignment.dart';

// Converts an alignment key string to a PCAlignment object.
final class AlignmentConverter {
  AlignmentConverter._();

  static PCAlignment? getPCAlignment(String alignKey) {
    final desiredAlign = Globals.context
        .getReferenceContext()
        .silentlyGetConstructedCDOMObject(PCAlignment, alignKey);
    if (desiredAlign == null) {
      // Logging.errorPrint
      print('Unable to find alignment that matches: $alignKey');
    }
    return desiredAlign as PCAlignment?;
  }
}
