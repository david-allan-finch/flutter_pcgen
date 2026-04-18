// Translation of pcgen.system.application.PCGenLoggingDeadlockHandler

import 'deadlock_handler.dart';

/// Logs deadlock information (stub — not applicable in Dart).
class PCGenLoggingDeadlockHandler implements DeadlockHandler {
  @override
  void handleDeadlock(List<dynamic> deadlockedThreads) {
    // No-op: Dart isolates don't have traditional thread deadlocks
  }
}
