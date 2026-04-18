// Translation of pcgen.system.application.DeadlockDetectorTask

import '../p_c_gen_task.dart';

/// Detects thread deadlocks (stub — no threading in Dart isolates model).
class DeadlockDetectorTask extends PCGenTask {
  @override
  void run() {
    // No-op: Dart uses isolates, not shared-memory threads
  }
}
