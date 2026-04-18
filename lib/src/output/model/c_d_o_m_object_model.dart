// Translation of pcgen.output.model.CDOMObjectModel

import '../base/output_actor.dart';

/// Output model wrapping a CDOMObject. Provides hash-model access to actors
/// registered for the object's type.
class CDOMObjectModel {
  final String _charId;
  final dynamic _obj;
  final Map<String, OutputActor<dynamic>> _actors;

  CDOMObjectModel(this._charId, this._obj, this._actors);

  /// Get the output for a named interpolation key.
  dynamic get(String key) {
    final actor = _actors[key];
    if (actor == null) return null;
    return actor.process(_charId, _obj);
  }
}
