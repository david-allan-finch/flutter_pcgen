// Stub for Spring framework integration — not applicable in the Dart/Flutter port.
// PCGen uses Spring to instantiate AbstractStorageFacet beans from XML config.
// In Dart, facet registration is handled directly rather than via IoC container.
final class SpringHelper {
  SpringHelper._();

  // Returns all registered AbstractStorageFacet instances.
  static List<dynamic> getStorageFacets() => const [];
}
