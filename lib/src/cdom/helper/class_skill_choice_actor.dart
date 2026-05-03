//
// Copyright (c) 2008 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.helper.ClassSkillChoiceActor
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/persistent_choice_actor.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/integer_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/skill_cost.dart';
import 'package:flutter_pcgen/src/cdom/inst/pc_class_level.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'package:flutter_pcgen/src/core/sub_class.dart';
import 'package:flutter_pcgen/src/core/analysis/skill_rank_control.dart';
import 'package:flutter_pcgen/src/core/pclevelinfo/pc_level_info.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart';

// A ClassSkillChoiceActor adds selected Skills as class skills for a specific
// PCClass and optionally applies a fixed number of ranks to each chosen skill.
class ClassSkillChoiceActor implements PersistentChoiceActor<Skill> {
  // The PCClass to which skill selections are applied as class skills.
  final PCClass _source;

  // Optional number of ranks to apply automatically upon selection.
  final int? _applyRank;

  ClassSkillChoiceActor(PCClass pcc, int? autoRank)
      : _source = pcc,
        _applyRank = autoRank;

  // Returns the number of ranks applied automatically, or null if none.
  int? getApplyRank() => _applyRank;

  // Adds the chosen Skill as a class skill and optionally applies ranks.
  @override
  void applyChoice(CDOMObject owner, Skill choice, dynamic pc) {
    final playerChar = pc as PlayerCharacter;
    final pcc = _getSourceClass(playerChar);
    if (pcc == null) {
      // ignore: avoid_print
      print('ERROR: Unable to find the pc\'s class $_source to apply skill choices to.');
      return;
    }
    playerChar.addLocalCost(pcc, choice, SkillCost.classSkill, owner);
    if (_applyRank != null) {
      if (owner is PCClassLevel) {
        // Ensure skill-point budget for this level is already computed.
        final pcClass = owner.getSafeObject(CDOMObjectKey.parent) as PCClass?;
        if (pcClass != null) {
          int levelIndex = 1;
          for (final lvlInfo in playerChar.getLevelInfo()) {
            if (lvlInfo.getClassKeyName() == pcClass.getKeyName() &&
                lvlInfo.getClassLevel() ==
                    owner.getSafeInt(IntegerKey.level)) {
              playerChar.checkSkillModChangeForLevel(
                  pcClass, lvlInfo, owner, levelIndex);
              levelIndex++;
              break;
            }
          }
        }
      }
      final result = SkillRankControl.modRanks(
          _applyRank!.toDouble(), pcc, false, playerChar, choice);
      if (result.isNotEmpty) {
        // ignore: avoid_print
        print('ERROR: Unable to apply $_applyRank ranks of $choice. Error: $result');
      }
    }
  }

  // Returns true if the given Skill is not already a class skill for this
  // ClassSkillChoiceActor's PCClass on the given PlayerCharacter.
  @override
  bool allow(Skill choice, dynamic pc, bool allowStack) {
    return !(pc as PlayerCharacter).isClassSkill(_source, choice);
  }

  // Returns a list of currently selected skills (empty; managed externally).
  @override
  List<Skill> getCurrentlySelected(CDOMObject owner, dynamic pc) => const [];

  // Decodes a persistent skill key into a Skill object.
  @override
  Skill decodeChoice(dynamic context, String persistentFormat) {
    return (context as LoadContext)
        .getReferenceContext()
        .silentlyGetConstructedCDOMObject(Skill, persistentFormat) as Skill;
  }

  // Encodes the given Skill as its key name for persistent storage.
  @override
  String encodeChoice(Skill choice) => choice.getKeyName() ?? '';

  // Restores a previously applied skill choice (adds it back as a class skill).
  @override
  void restoreChoice(dynamic pc, CDOMObject owner, Skill choice) {
    final playerChar = pc as PlayerCharacter;
    final pcc = _getSourceClass(playerChar);
    if (pcc == null) {
      // ignore: avoid_print
      print('ERROR: Unable to find the pc\'s class $_source to restore skill choices to.');
      return;
    }
    playerChar.addLocalCost(pcc, choice, SkillCost.classSkill, owner);
  }

  // Removes a previously applied skill choice, reversing ranks and cost.
  @override
  void removeChoice(dynamic pc, CDOMObject owner, Skill choice) {
    final playerChar = pc as PlayerCharacter;
    final pcc = playerChar.getClassKeyed(_source.getKeyName() ?? '');
    if (_applyRank != null) {
      SkillRankControl.modRanks(
          -_applyRank!.toDouble(), pcc, false, playerChar, choice);
    }
    playerChar.removeLocalCost(pcc, choice, SkillCost.classSkill, owner);
  }

  // Returns the character's instance of the PCClass associated with this actor.
  PCClass? _getSourceClass(PlayerCharacter pc) {
    if (_source is SubClass) {
      final cat = (_source as SubClass).getCDOMCategory();
      return pc.getClassKeyed(cat?.getKeyName() ?? '');
    }
    return pc.getClassKeyed(_source.getKeyName() ?? '');
  }
}
