import '../../cdom/base/cdom_object.dart';
import 'editor_list_context.dart';
import 'editor_object_context.dart';
import 'editor_reference_context.dart';

// stub: LoadContextInst not yet translated; minimal inline implementation.
// Note: does not implement the existing thin LoadContext interface because
// EditorReferenceContext extends the full AbstractReferenceContext (from
// runtime_reference_context.dart), not the simplified one used by that interface.
abstract class LoadContextInst {
  final EditorReferenceContext _refContext;
  final EditorListContext _listContext;
  final EditorObjectContext _objContext;

  LoadContextInst(this._refContext, this._listContext, this._objContext);

  EditorReferenceContext getReferenceContext() => _refContext;
  EditorListContext getListContext() => _listContext;
  EditorObjectContext getObjectContext() => _objContext;

  String getContextType();
  bool consolidate();

  void setExtractURI(String? extractURI); // stub
  void setSourceURI(String? sourceURI); // stub
  String? getSourceURI(); // stub
  int getDataSetID(); // stub
  Iterable<String> unparse(CDOMObject obj); // stub
  dynamic getPrerequisite(String prereqStr); // stub
}

class EditorLoadContext extends LoadContextInst {
  final String _contextType = 'Editor';

  EditorLoadContext()
      : super(
          EditorReferenceContext.createEditorReferenceContext(),
          EditorListContext(),
          EditorObjectContext(),
        );

  @override
  String getContextType() => _contextType;

  @override
  bool consolidate() => false;

  void purge(CDOMObject cdo) {
    getObjectContext().purge(cdo);
    getListContext().purge(cdo);
    getReferenceContext().purge(cdo);
  }

  @override
  void setExtractURI(String? extractURI) {} // stub

  @override
  void setSourceURI(String? sourceURI) {} // stub

  @override
  String? getSourceURI() => null; // stub

  @override
  int getDataSetID() => 0; // stub

  @override
  Iterable<String> unparse(CDOMObject obj) => const []; // stub

  @override
  dynamic getPrerequisite(String prereqStr) => null; // stub
}
