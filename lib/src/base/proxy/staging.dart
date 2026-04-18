// Simplified proxy/staging system (Java uses dynamic proxies; here we use explicit dispatch).
// A Staging holds pending changes to be applied to a target object.
abstract interface class Staging<T> {
  void applyTo(T target);
}
