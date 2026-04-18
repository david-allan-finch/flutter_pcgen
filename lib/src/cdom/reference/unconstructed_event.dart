import '../base/cdom_reference.dart';

// Issued when an unconstructed reference is found during data load and was not
// permitted by an UnconstructedValidator.
class UnconstructedEvent {
  final Object source;
  final CDOMReference<dynamic> reference;

  UnconstructedEvent(this.source, CDOMReference<dynamic> ref)
      : reference = ref;

  CDOMReference<dynamic> getReference() => reference;
}
