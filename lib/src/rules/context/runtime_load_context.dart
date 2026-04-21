//
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.rules.context.RuntimeLoadContext
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
