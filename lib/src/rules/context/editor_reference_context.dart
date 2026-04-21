//
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.rules.context.EditorReferenceContext
import 'package:flutter_pcgen/src/base/util/hash_map_to_list.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'runtime_reference_context.dart';

class EditorReferenceContext extends RuntimeReferenceContext {
  final HashMapToList<CDOMObject, CDOMObject> _copyMap = HashMapToList();
  final HashMapToList<CDOMObject, CDOMObject> _modMap = HashMapToList();
  // URI represented as String
  final HashMapToList<String, Loadable> _forgetMap = HashMapToList();

  String? _sourceURI;

  EditorReferenceContext._();

  @override
  T? performCopy<T extends CDOMObject>(T object, String copyName) {
    // Java uses object.getClass().newInstance() to create an uninitialized copy.
    // Dart has no equivalent reflective zero-arg constructor call; we record the
    // intent in the copy map and return null, matching the Java behaviour.
    try {
      // stub: reflective newInstance not available in Dart
      // CDOMObject copy = object.runtimeType.newInstance(); // not possible
      // _copyMap.addToListFor(object, copy);
      _copyMap.addToListFor(object, object); // stub: placeholder
    } catch (e) {
      throw ArgumentError(
          'Class ${object.runtimeType} must possess a zero-argument constructor: $e');
    }
    return null;
  }

  @override
  T performMod<T extends CDOMObject>(T object) {
    try {
      // stub: reflective newInstance not available in Dart
      _modMap.addToListFor(object, object); // stub: placeholder
    } catch (e) {
      throw ArgumentError(
          'Class ${object.runtimeType} must possess a zero-argument constructor: $e');
    }
    // Java also returns null here; but return type is T (non-null). Using
    // unsafe cast to preserve original semantics.
    return null as T; // stub
  }

  /// Override forget to record the object in the forget map rather than
  /// actually removing it from the reference context (the editor must not
  /// delete live objects).
  bool forget<T extends Loadable>(T obj) {
    _forgetMap.addToListFor(_sourceURI ?? '', obj);
    return true;
  }

  /// Actually remove the object from the reference context (called when the
  /// editor commits a deletion).
  void purge(CDOMObject cdo) {
    // Calls the real forget on the parent RuntimeReferenceContext
    super.forgetLoadable(cdo);
  }

  /// Return a new EditorReferenceContext initialised as per AbstractReferenceContext.
  static EditorReferenceContext createEditorReferenceContext() {
    final context = EditorReferenceContext._();
    context.initialize();
    return context;
  }
}
