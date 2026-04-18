import 'skill.dart';

// Sorts Skill objects by name or trained status, ascending or descending.
class SkillComparator implements Comparator<Skill> {
  static const int resortName = 0;
  static const int resortTrained = 1;
  static const bool resortAscending = true;
  static const bool resortDescending = false;

  final dynamic _pc; // PlayerCharacter
  final int _sort;
  final bool _sortOrder;

  SkillComparator(dynamic pc, int sort, bool sortOrder)
      : _pc = pc,
        _sort = sort,
        _sortOrder = sortOrder;

  @override
  int compare(Skill obj1, Skill obj2) {
    final Skill s1;
    final Skill s2;
    if (_sortOrder == resortAscending || _sort == resortTrained) {
      s1 = obj1;
      s2 = obj2;
    } else {
      s1 = obj2;
      s2 = obj1;
    }

    if (_sort == resortTrained) {
      // getTotalRank would come from SkillRankControl — approximate with 0
      final r1 = 0.0; // SkillRankControl.getTotalRank(_pc, s1)
      final r2 = 0.0; // SkillRankControl.getTotalRank(_pc, s2)
      if (r1 > 0.0 && r2 <= 0.0) return _sortOrder == resortAscending ? -1 : 1;
      if (r1 <= 0.0 && r2 > 0.0) return _sortOrder == resortAscending ? 1 : -1;
      return s1.getOutputName().toLowerCase().compareTo(s2.getOutputName().toLowerCase());
    }
    return s1.getOutputName().toLowerCase().compareTo(s2.getOutputName().toLowerCase());
  }
}

// Dart equivalent of Comparator functional interface.
abstract interface class Comparator<T> {
  int compare(T a, T b);
}
