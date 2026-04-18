import '../../base/util/hash_map_to_list.dart';
import '../../cdom/base/cdom_object.dart';
import '../../cdom/base/loadable.dart';
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
