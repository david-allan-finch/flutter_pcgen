// Provides encode/decode for persistent storage of choices.
abstract interface class Persistent<T> {
  String encodeChoice(T item);
  T decodeChoice(dynamic context, String persistentFormat);
}
