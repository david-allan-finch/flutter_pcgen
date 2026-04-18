import '../cdom/base/concrete_prereq_object.dart';
import '../cdom/reference/cdom_reference.dart';
import 'race.dart';

// A possible companion/follower choice with an optional level adjustment.
class FollowerOption extends ConcretePrereqObject implements Comparable<FollowerOption> {
  final CDOMReference<Race> ref;
  final String listName; // CompanionList name (e.g. "Familiar")
  int adjustment = 0;

  FollowerOption(this.ref, this.listName);

  Race? getRace() {
    final contained = ref.getContainedObjects();
    return contained.length == 1 ? contained.first : null;
  }

  CDOMReference<Race> getRaceRef() => ref;

  @override
  int compareTo(FollowerOption other) {
    final r = getRace();
    final or = other.getRace();
    if (r == null && or == null) return 0;
    if (r == null) return -1;
    if (or == null) return 1;
    return r.getKeyName().compareTo(or.getKeyName());
  }

  @override
  String toString() => ref.getLSTformat();
}
