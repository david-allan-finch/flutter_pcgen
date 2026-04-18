import 'data_set_id.dart';

// A unique identifier for a PlayerCharacter. Used as a key in facet caches.
final class CharID {
  static int _ordinalCount = 0;
  final int _ordinal;
  final DataSetID _datasetID;

  CharID._(this._datasetID) : _ordinal = _ordinalCount++;

  static CharID getID(DataSetID dsid) => CharID._(dsid);

  int getOrdinal() => _ordinal;
  DataSetID getDatasetID() => _datasetID;
  DataSetID getDataSetID() => _datasetID;

  @override
  String toString() => 'CharID[$_ordinal]';
}
