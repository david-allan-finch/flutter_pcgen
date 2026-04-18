// Translation of pcgen.output.channel.compat.AbstractAdapter

/// AbstractAdapter provides read/write access to a character channel variable
/// using a facade-compatible interface.
abstract class AbstractAdapter<T> {
  final String _charId;
  final String _variableName;

  AbstractAdapter(this._charId, this._variableName);

  String get charId => _charId;
  String get variableName => _variableName;

  T? get();
  void set(T value);
}
