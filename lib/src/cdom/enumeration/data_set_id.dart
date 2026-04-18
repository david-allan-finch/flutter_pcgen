// Unique identifier for a loaded data set (campaign combination).
final class DataSetID {
  static int _ordinalCount = 0;
  final int _ordinal;

  DataSetID._() : _ordinal = _ordinalCount++;

  static DataSetID generate() => DataSetID._();

  int getOrdinal() => _ordinal;

  @override
  String toString() => 'DataSetID[$_ordinal]';
}
