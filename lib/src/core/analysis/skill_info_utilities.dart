import '../../cdom/enumeration/type.dart';
import '../globals.dart';
import '../pc_stat.dart';
import '../player_character.dart';
import '../skill.dart';

abstract final class SkillInfoUtilities {
  // Get the key stat abbreviation for a skill.
  static String getKeyStatFromStats(PlayerCharacter pc, Skill sk) {
    final stat = sk.keyStat;
    if (stat == null) {
      if (Globals.gameModeHasPointPool) {
        final statList = getKeyStatList(pc, sk, null);
        return statList.map((s) => s.getKeyName()).join();
      }
      return '';
    }
    return stat.get().getKeyName();
  }

  // Get a list of PCStat's that apply a SKILL bonus to this skill.
  static List<PCStat> getKeyStatList(PlayerCharacter pc, Skill sk, List<CDOMType>? typeList) {
    final aList = <PCStat>[];
    if (Globals.gameModeHasPointPool) {
      for (final aType in sk.getTrueTypeList(false)) {
        for (final stat in pc.getDisplay().getStatSet()) {
          final bonusList = stat.getBonusesForSkillType(aType);
          if (bonusList.isNotEmpty) {
            for (int i = 0; i < bonusList.length; i++) {
              aList.add(stat);
            }
            if (typeList != null && !typeList.contains(aType)) {
              typeList.add(aType);
            }
          }
        }
      }
    }
    return aList;
  }

  // Get an iterable of sub-types for a skill, excluding key stat and NONE.
  static Iterable<CDOMType> getSubtypeIterable(Skill sk) {
    final ret = List<CDOMType>.of(sk.getSafeListFor('TYPE'));
    final keystat = sk.keyStat;
    if (keystat == null) {
      ret.remove(CDOMType.none);
    } else {
      ret.remove(CDOMType.getConstant(keystat.get().getDisplayName()));
    }
    return ret;
  }
}
