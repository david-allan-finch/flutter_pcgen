//
// Copyright 2001 (C) Greg Bingleman <byngl@hotmail.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.kit.KitSkill
import '../../cdom/base/cdom_reference.dart';
import '../../cdom/reference/cdom_single_ref.dart';
import '../../core/kit.dart';
import '../../core/language.dart';
import '../../core/pc_class.dart';
import '../../core/player_character.dart';
import '../../core/rule_constants.dart';
import '../../core/globals.dart';
import '../../core/skill.dart';
import '../../core/analysis/skill_rank_control.dart';
import '../../core/pclevelinfo/pc_level_info.dart';
import '../../base/logging/logging.dart';
import 'base_kit.dart';
import 'kit_skill_add.dart';

// Kit task that adds skill ranks to a PC.
final class KitSkill extends BaseKit {
  bool? free;
  double? rank;
  final List<CdomReference<Skill>> _skillList = [];
  CdomSingleRef<PCClass>? className;
  int? choiceCount;
  final List<CdomSingleRef<Language>> _selection = [];
  List<KitSkillAdd>? _skillsToAdd;

  void setFree(bool argFree) { free = argFree; }
  bool isFree() => free == true;
  bool? getFree() => free;

  void setRank(double setRank) { rank = setRank; }
  double? getRank() => rank;

  void addSkill(CdomReference<Skill> ref) { _skillList.add(ref); }
  List<CdomReference<Skill>> getSkills() => List.unmodifiable(_skillList);

  void setPcclass(CdomSingleRef<PCClass> ref) { className = ref; }
  CdomReference<PCClass>? getPcclass() => className;

  void setCount(int quan) { choiceCount = quan; }
  int? getCount() => choiceCount;
  int getSafeCount() => choiceCount ?? 1;

  void addSelection(CdomSingleRef<Language> ref) { _selection.add(ref); }
  List<CdomSingleRef<Language>> getSelections() => List.unmodifiable(_selection);

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    _skillsToAdd = [];
    final skillChoices = _getSkillChoices(aPC);
    if (skillChoices == null || skillChoices.isEmpty) return false;

    for (final skill in skillChoices) {
      double ranksLeft = rank ?? 1.0;
      final classList = <PCClass>[];
      if (className != null) {
        final classKey = className!.get().getKeyName();
        final pcClass = aPC.getClassKeyed(classKey);
        if (pcClass != null) {
          classList.add(pcClass);
        } else {
          warnings.add('SKILL: Could not find specified class $classKey in PC to add ranks from.');
        }
      }
      for (final pcClass in aPC.getClassSet()) {
        if (!classList.contains(pcClass)) classList.add(pcClass);
      }

      final oldImporting = aPC.isImporting();
      aPC.setImporting(true);
      for (final pcClass in classList) {
        final sta = _addRanks(aPC, pcClass, skill, ranksLeft, isFree(), warnings);
        if (sta != null) {
          _skillsToAdd!.add(sta);
          ranksLeft -= sta.getRanks();
          if (ranksLeft <= 0.0) break;
        }
      }
      aPC.setImporting(oldImporting);
      if (ranksLeft > 0.0) {
        warnings.add('SKILL: Could not add $ranksLeft ranks to ${skill.getKeyName()}. Not enough points.');
      }
    }
    return true;
  }

  @override
  void apply(PlayerCharacter aPC) {
    for (final ksa in _skillsToAdd!) {
      _updatePCSkills(aPC, ksa.getSkill(), ksa.getRanks().toInt(), ksa.getCost(), ksa.getLanguages(), ksa.getPCClass());
    }
  }

  bool _updatePCSkills(PlayerCharacter pc, Skill aSkill, int aRank, double aCost, List<Language> langList, PCClass pcClass) {
    final oldImporting = pc.isImporting();
    pc.setImporting(true);
    final aString = SkillRankControl.modRanks(aRank.toDouble(), pcClass, true, pc, aSkill);
    pc.setImporting(oldImporting);

    if (aString.isNotEmpty) {
      Logging.errorPrint('SKILL: $aString');
      return false;
    }

    double ptsToSpend = aCost;
    if (ptsToSpend >= 0.0) {
      for (final info in pc.getLevelInfo()) {
        if (info.classKeyName == pcClass.getKeyName()) {
          final remaining = info.skillPointsRemaining;
          if (remaining == 0) continue;
          final left = remaining - (remaining < ptsToSpend ? remaining : ptsToSpend).toInt();
          info.skillPointsRemaining = left;
          ptsToSpend -= (remaining - left);
          if (ptsToSpend <= 0) break;
        }
      }
    }
    return true;
  }

  KitSkillAdd? _addRanks(PlayerCharacter pc, PCClass pcClass, Skill aSkill, double ranksLeftToAdd, bool isFree_, List<String> warnings) {
    if (!isFree_ && pcClass.getSkillPool(pc) == 0) return null;

    double curRank = pc.hasSkill(aSkill) ? pc.getRank(aSkill) : 0.0;
    double ranksToAdd = ranksLeftToAdd;
    if (!Globals.checkRule(RuleConstants.skillmax) && ranksToAdd > 0.0) {
      ranksToAdd = (pc.getMaxRank(aSkill, pcClass) < curRank + ranksLeftToAdd
          ? pc.getMaxRank(aSkill, pcClass)
          : curRank + ranksLeftToAdd) - curRank;
      if ((ranksToAdd - ranksLeftToAdd).abs() > 0.0001) {
        warnings.add('SKILL: Could not add ${ranksLeftToAdd - ranksToAdd} to ${aSkill.getDisplayName()}. Exceeds MAXRANK of ${pc.getMaxRank(aSkill, pcClass)}.');
      }
    }

    int ptsToSpend = 0;
    List<int> points = List.filled(pc.getLevelInfoSize(), -1);
    if (!isFree_) {
      double ranksAdded = 0.0;
      final skillCost = pc.getSkillCostForClass(aSkill, pcClass).getCost();
      ptsToSpend = (ranksToAdd * skillCost).toInt();
      for (int i = 0; i < pc.getLevelInfoSize(); i++) {
        final info = pc.getLevelInfo(i);
        if (info.classKeyName == pcClass.getKeyName()) {
          points[i] = info.skillPointsRemaining;
        }
      }
      for (int i = 0; i < points.length; i++) {
        final remaining = points[i];
        if (remaining <= 0) continue;
        final left = remaining - (remaining < ptsToSpend ? remaining : ptsToSpend);
        points[i] = left;
        final spent = remaining - left;
        ptsToSpend -= spent;
        ranksAdded += spent / skillCost;
        if ((ranksAdded - ranksToAdd).abs() < 0.0001 || ptsToSpend <= 0) break;
      }
      ranksToAdd = ranksAdded;
      ptsToSpend = (ranksToAdd * skillCost).toInt();
    }

    final ret = SkillRankControl.modRanks(ranksToAdd, pcClass, false, pc, aSkill);
    if (ret.isNotEmpty) {
      if (isFree_ && ret.contains('You do not have enough skill points.')) {
        SkillRankControl.modRanks(ranksToAdd, pcClass, true, pc, aSkill);
      } else {
        warnings.add(ret);
        return null;
      }
    }
    if (!isFree_) {
      for (int i = 0; i < pc.getLevelInfoSize(); i++) {
        if (points[i] >= 0) pc.getLevelInfo(i).skillPointsRemaining = points[i];
      }
    }

    final langList = <Language>[];
    for (final ref in _selection) {
      langList.add(ref.get());
      if (langList.length >= ranksToAdd.toInt()) break;
    }
    return KitSkillAdd(aSkill, ranksToAdd, ptsToSpend.toDouble(), langList, pcClass);
  }

  List<Skill>? _getSkillChoices(PlayerCharacter aPC) {
    final skillsOfType = <Skill>[];
    for (final ref in _skillList) {
      skillsOfType.addAll(ref.getContainedObjects().whereType<Skill>());
    }
    if (skillsOfType.isEmpty) return null;
    if (skillsOfType.length == 1) return skillsOfType;
    return skillsOfType.take(getSafeCount()).toList();
  }

  @override
  String getObjectName() => 'Skills';

  @override
  String toString() {
    final info = StringBuffer();
    if (_skillList.length > 1) {
      info.write('${getSafeCount()} of (');
      info.write(_skillList.map((r) => r.getLSTformat(false)).join(', '));
      info.write(')');
    } else if (_skillList.isNotEmpty) {
      info.write(_skillList[0].getLSTformat(false));
    }
    info.write(' (${rank ?? 1.0}');
    if (isFree()) info.write('/free');
    if (_selection.isNotEmpty) {
      info.write('/');
      info.write(_selection.map((r) => r.toString()).join(', '));
    }
    info.write(')');
    return info.toString();
  }
}
