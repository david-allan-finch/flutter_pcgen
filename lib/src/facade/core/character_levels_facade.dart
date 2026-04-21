// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.CharacterLevelsFacade

import 'package:flutter_pcgen/src/facade/core/character_level_facade.dart';

abstract interface class CharacterLevelsFacade {
  bool investSkillPoints(CharacterLevelFacade level, dynamic skill, int points);
  dynamic getClassTaken(CharacterLevelFacade level);
  dynamic getSkillCost(CharacterLevelFacade level, dynamic skill);
  int getGainedSkillPoints(CharacterLevelFacade level);
  void setGainedSkillPoints(CharacterLevelFacade level, int points);
  int getSpentSkillPoints(CharacterLevelFacade level);
  int getRemainingSkillPoints(CharacterLevelFacade level);
  int getHPGained(CharacterLevelFacade level);
  int getHPRolled(CharacterLevelFacade level);
  void setHPRolled(CharacterLevelFacade level, int hp);
  double getSkillRanks(CharacterLevelFacade level, dynamic skill);
  dynamic getSkillBreakdown(CharacterLevelFacade level, dynamic skill);
  double getMaxRanks(CharacterLevelFacade level, dynamic cost, bool isClassForMaxRanks);
  bool isClassSkillForMaxRanks(CharacterLevelFacade level, dynamic skill);
  void addClassListener(dynamic listener);
  void addHitPointListener(dynamic listener);
  void removeHitPointListener(dynamic listener);
  void addSkillBonusListener(dynamic listener);
  void removeSkillBonusListener(dynamic listener);
}
