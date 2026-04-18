// Translation of pcgen.system.PCGenTaskEvent

import 'progress_container.dart';

class PCGenTaskEvent {
  final ProgressContainer source;
  final dynamic errorRecord; // Java LogRecord

  PCGenTaskEvent(this.source, {this.errorRecord});

  ProgressContainer getSource() => source;
  dynamic getErrorRecord() => errorRecord;
}
