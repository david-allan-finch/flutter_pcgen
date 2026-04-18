import '../enumeration/data_set_id.dart';

// PCGenIdentifier represents a typed identifier (e.g. CharID) that carries its
// owning DataSetID.
abstract interface class PCGenIdentifier {
  DataSetID getDataSetID();
}
