// Translation of pcgen.gui2.converter.event.ProgressListener

import 'progress_event.dart';

/// Listener interface for progress events fired by conversion sub-panels.
abstract class ProgressListener {
  /// Called when progress to the next panel is allowed.
  void progressAllowed(ProgressEvent pe);

  /// Called when progress to the next panel is not allowed.
  void progressNotAllowed(ProgressEvent pe);
}
