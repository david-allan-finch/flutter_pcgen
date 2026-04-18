// Caches a value along with a serial number for invalidation tracking.
// Used by the variable processor system.
final class CachedVariable<T> {
  int _serial = 0;
  T? _value;

  int getSerial() => _serial;
  void setSerial(int i) => _serial = i;

  T? getValue() => _value;
  void setValue(T v) => _value = v;
}
