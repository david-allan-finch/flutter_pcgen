// Copyright (c) Tom Parker, 2014.
//
// Translation of pcgen.core.display.SkillDisplay

/// Utilities for skill list ordering and output-order management.
class SkillDisplay {
  SkillDisplay._();

  static const int _arbitraryEndIndex = 999999;

  /// Returns [skills] sorted by the PC's skill output order.
  /// Hidden skills (outputIndex == -1) and invisible/unqualified skills
  /// are removed.
  static List<dynamic> getSkillListInOutputOrder(
      dynamic pc, List<dynamic> skills) {
    skills.sort((a, b) {
      int idx1 = (pc.getSkillOrder(a) as int?) ?? 0;
      int idx2 = (pc.getSkillOrder(b) as int?) ?? 0;
      if (idx1 == 0) idx1 = _arbitraryEndIndex;
      if (idx2 == 0) idx2 = _arbitraryEndIndex;
      if (idx1 != idx2) return idx1.compareTo(idx2);
      return (a.getOutputName() as String)
          .toLowerCase()
          .compareTo((b.getOutputName() as String).toLowerCase());
    });

    skills.removeWhere((skill) {
      final outputIndex = pc.getSkillOrder(skill) as int?;
      if (outputIndex != null && outputIndex == -1) return true;
      final vis = skill.getSafeObject(CDOMObjectKey.getConstant('VISIBILITY'));
      if (vis != null && (vis.isVisibleTo('HIDDEN_EXPORT') as bool? ?? false)) {
        return true;
      }
      if (!(skill.qualifies(pc, null) as bool? ?? true)) return true;
      return false;
    });

    return skills;
  }

  /// Returns the character's skills in output order.
  static List<dynamic> getSkillListInOutputOrderAll(dynamic pc) {
    return getSkillListInOutputOrder(
        pc, List<dynamic>.from(pc.getSkillSet() as Iterable));
  }

  /// Updates the output order for [aSkill] after it is added to the character.
  static void updateSkillsOutputOrder(dynamic pc, dynamic aSkill) {
    final order = pc.getSkillsOutputOrder();
    if (order == 'MANUAL') {
      final outputIndex = pc.getSkillOrder(aSkill) as int?;
      if (outputIndex == null || outputIndex == 0) {
        pc.setSkillOrder(aSkill, _getHighestOutputIndex(pc) + 1);
      }
    } else {
      resortSelected(pc, order);
    }
  }

  /// Re-sorts skills according to [sortSelection] and reassigns output indices.
  static void resortSelected(dynamic pc, dynamic sortSelection) {
    if (pc == null) return;
    final comparator = sortSelection.getComparator?.call(pc);
    _resortWithComparator(pc, comparator);
  }

  static void _resortWithComparator(dynamic pc, dynamic comparator) {
    if (comparator == null) return;
    final skillList = List<dynamic>.from(pc.getSkillSet() as Iterable);
    skillList.sort((a, b) => comparator.compare(a, b) as int);

    int nextIndex = 1;
    for (final skill in skillList) {
      final idx = pc.getSkillOrder(skill) as int?;
      if (idx == null || idx >= 0) {
        pc.setSkillOrder(skill, nextIndex++);
      }
    }
  }

  static int _getHighestOutputIndex(dynamic pc) {
    int max = 0;
    for (final skill in pc.getSkillSet() as Iterable) {
      final idx = pc.getSkillOrder(skill) as int?;
      if (idx != null && idx > max) max = idx;
    }
    return max;
  }
}
