// Translation of pcgen.system.application.DeadlockHandler

/// Handles detected deadlocks (stub — no threading deadlocks in Dart).
abstract interface class DeadlockHandler {
  void handleDeadlock(List<dynamic> deadlockedThreads);
}
