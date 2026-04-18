import '../base/loadable.dart';
import 'reference_manufacturer.dart';

// A TransparentReference is a CDOMReference that can be re-resolved using a
// ReferenceManufacturer. Used when a reference must be created before the
// appropriate manufacturer exists (e.g. game-mode references resolved against
// per-campaign manufacturers).
abstract interface class TransparentReference<T extends Loadable> {
  // Resolves this reference using the given manufacturer, overwriting any
  // previously resolved underlying reference.
  void resolve(ReferenceManufacturer<T> rm);
}
