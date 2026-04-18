import '../../cdom/base/cdom_object.dart';
import '../../cdom/base/loadable.dart';
import 'abstract_reference_context.dart';
import 'load_context.dart';

// Runtime implementation of LoadContext for use during data loading.
class RuntimeLoadContext implements LoadContext {
  String? _extractURI;
  String? _sourceURI;
  int _dataSetID;
  final RuntimeReferenceContext _refContext;

  RuntimeLoadContext(this._dataSetID)
      : _refContext = RuntimeReferenceContext();

  @override
  void setExtractURI(String? extractURI) { _extractURI = extractURI; }

  @override
  void setSourceURI(String? sourceURI) { _sourceURI = sourceURI; }

  @override
  String? getSourceURI() => _sourceURI;

  @override
  int getDataSetID() => _dataSetID;

  @override
  AbstractReferenceContext getReferenceContext() => _refContext;

  @override
  Iterable<String> unparse(CDOMObject obj) => [];

  @override
  dynamic getPrerequisite(String prereqStr) => null;
}

// Runtime reference context implementation.
class RuntimeReferenceContext extends AbstractReferenceContext {
  @override
  void resolveReferences() {
    // In the full implementation this would iterate through all deferred
    // references and resolve them against the registry
  }
}
