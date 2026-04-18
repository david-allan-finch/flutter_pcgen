import '../base/loadable.dart';
import 'cdom_single_ref.dart';

// Identifies a specific Loadable instance to bypass prerequisites or establish
// other relationships (e.g. QUALIFY token).
class Qualifier {
  final CDOMSingleRef<Loadable> _qualRef;

  Qualifier(CDOMSingleRef<Loadable> ref) : _qualRef = ref;

  CDOMSingleRef<Loadable> getQualifiedReference() => _qualRef;

  @override
  int get hashCode => _qualRef.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is Qualifier) {
      return _qualRef == other._qualRef;
    }
    return false;
  }
}
