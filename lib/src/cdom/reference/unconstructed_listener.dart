import 'unconstructed_event.dart';

// Receives UnconstructedEvents when unconstructed objects are found during load.
abstract interface class UnconstructedListener {
  void unconstructedReferenceFound(UnconstructedEvent event);
}
