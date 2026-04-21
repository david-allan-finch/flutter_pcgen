//
// Copyright 2009-2010 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.rules.context.EditorLoadContext
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
