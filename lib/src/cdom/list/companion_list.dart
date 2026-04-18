import '../base/category.dart';
import '../base/cdom_list_object.dart';
import '../../core/race.dart';

// A typed list of companion races (Familiar, Mount, Follower, etc.).
class CompanionList extends CDOMListObject<Race> implements Category<dynamic> {
  @override
  Type get listClass => Race;

  @override
  bool isType(String type) => false;

  @override
  Category<dynamic>? getParentCategory() => null;

  @override
  bool isMember(dynamic item) {
    // item would be CompanionMod — check category field
    return false; // simplified
  }

  String getPersistentFormat() => 'COMPANIONLIST=${getKeyName()}';

  String getReferenceDescription() => 'CompanionMod of TYPE ${getKeyName()}';

  @override
  int get hashCode => getKeyName().hashCode;

  @override
  bool operator ==(Object o) =>
      o is CompanionList && getKeyName() == o.getKeyName();
}
