import '../cdom/base/concrete_prereq_object.dart';
import '../cdom/base/cdom_object.dart';
import '../cdom/prereq/prerequisite.dart';
import 'player_character.dart';

// Associates an object with a set of prerequisites — the object is only
// available when all prerequisites are met.
class QualifiedObject<T> extends ConcretePrereqObject {
  T _object;

  QualifiedObject(this._object);

  QualifiedObject.withPrereq(this._object, Prerequisite prereq) {
    addPrerequisite(prereq);
  }

  QualifiedObject.withPrereqs(this._object, List<Prerequisite> prereqs) {
    addAllPrerequisites(prereqs);
  }

  /// Returns the object if [aPC] is null or qualifies, otherwise null.
  T? getObject(PlayerCharacter? aPC, CDOMObject? owner) {
    if (aPC == null || qualifies(aPC, owner)) return _object;
    return null;
  }

  T getRawObject() => _object;

  void setObject(T obj) { _object = obj; }

  @override
  String toString() => 'Object:$_object, Prereq:${getPrerequisites()}';

  @override
  bool operator ==(Object obj) {
    if (obj is! QualifiedObject<T>) return false;
    if (!equalsPrereqObject(obj)) return false;
    return _object == obj._object;
  }

  @override
  int get hashCode => getPrerequisiteCount() * 23 + _object.hashCode;
}
