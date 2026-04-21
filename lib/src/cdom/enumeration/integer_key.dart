//
// Copyright 2005 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.enumeration.IntegerKey
import 'package:flutter_pcgen/src/base/util/case_insensitive_map.dart';
import 'package:flutter_pcgen/src/cdom/base/constants.dart';

// Typesafe constant for Integer characteristics of a CDOMObject.
class IntegerKey {
  static final CaseInsensitiveMap<IntegerKey> _typeMap = CaseInsensitiveMap();
  static int _ordinalCount = 0;

  static final IntegerKey acCheck = getConstant('AC_CHECK');
  static final IntegerKey addSpellLevel = getConstant('ADD_SPELL_LEVEL');
  static final IntegerKey baseQuantity = getConstant('BASE_QUANTITY', defaultValue: 1);
  static final IntegerKey bonusClassSkillPoints = getConstant('BONUS_CLASS_SKILL_POINTS');
  static final IntegerKey castingThreshold = getConstant('CASTING_THRESHOLD');
  static final IntegerKey cost = getConstant('COST');
  static final IntegerKey critMult = getConstant('CRIT_MULT');
  static final IntegerKey critRange = getConstant('CRIT_RANGE');
  static final IntegerKey edr = getConstant('EDR');
  static final IntegerKey hands = getConstant('HANDS', defaultValue: 1);
  static final IntegerKey creatureHands = getConstant('CREATURE_HANDS', defaultValue: 2);
  static final IntegerKey hitDie = getConstant('HIT_DIE');
  static final IntegerKey knownSpellsFromSpecialty = getConstant('KNOWN_SPELLS_FROM_SPECIALTY');
  static final IntegerKey legs = getConstant('LEGS', defaultValue: 2);
  static final IntegerKey level = getConstant('LEVEL');
  static final IntegerKey levelAdjustment = getConstant('LEVEL_ADJUSTMENT', defaultValue: 0);
  static final IntegerKey levelLimit = getConstant('LEVEL_LIMIT', defaultValue: Constants.noLevelLimit);
  static final IntegerKey levelsPerFeat = getConstant('LEVELS_PER_FEAT');
  static final IntegerKey maxCharges = getConstant('MAX_CHARGES');
  static final IntegerKey maxDex = getConstant('MAX_DEX', defaultValue: Constants.maxMaxdex);
  static final IntegerKey minCharges = getConstant('MIN_CHARGES');
  static final IntegerKey nonpp = getConstant('NONPP');
  static final IntegerKey numPages = getConstant('NUM_PAGES');
  static final IntegerKey plus = getConstant('PLUS');
  static final IntegerKey prohibitCost = getConstant('PROHIBIT_COST');
  static final IntegerKey range = getConstant('RANGE');
  static final IntegerKey campaignRank = getConstant('CAMPAIGN_RANK', defaultValue: 9);
  static final IntegerKey reach = getConstant('REACH', defaultValue: 5);
  static final IntegerKey reachMult = getConstant('REACH_MULT', defaultValue: 1);
  static final IntegerKey slots = getConstant('SLOTS', defaultValue: 1);
  static final IntegerKey spellFailure = getConstant('SPELL_FAILURE');
  static final IntegerKey startFeats = getConstant('START_FEATS');
  static final IntegerKey xpCost = getConstant('XP_COST');
  static final IntegerKey consecutive = getConstant('CONSECUTIVE');
  static final IntegerKey maxLevel = getConstant('MAX_LEVEL');
  static final IntegerKey levelIncrement = getConstant('LEVEL_INCREMENT');
  static final IntegerKey startLevel = getConstant('START_LEVEL');
  static final IntegerKey hdMin = getConstant('HD_MIN');
  static final IntegerKey hdMax = getConstant('HD_MAX');
  static final IntegerKey umult = getConstant('UMULT');
  static final IntegerKey containerReduceWeight = getConstant('CONTAINER_REDUCE_WEIGHT');
  static final IntegerKey minValue = getConstant('MIN_VALUE', defaultValue: 0);
  static final IntegerKey maxValue = getConstant('MAX_VALUE', defaultValue: 1000);
  static final IntegerKey sizenum = getConstant('SIZENUM');
  static final IntegerKey sizeorder = getConstant('SIZEORDER');
  static final IntegerKey initialSkillMult = getConstant('INITIAL_SKILL_MULT', defaultValue: 0);

  final String _fieldName;
  final int _defaultValue;
  final int ordinal;

  IntegerKey._(this._fieldName, this._defaultValue) : ordinal = _ordinalCount++;

  int getDefault() => _defaultValue;

  @override
  String toString() => _fieldName;

  static IntegerKey getConstant(String name, {int defaultValue = 0}) {
    final existing = _typeMap[name];
    if (existing != null) return existing;
    final key = IntegerKey._(name, defaultValue);
    _typeMap[name] = key;
    return key;
  }

  static IntegerKey valueOf(String name) {
    final key = _typeMap[name];
    if (key == null) throw ArgumentError('$name is not a previously defined IntegerKey');
    return key;
  }

  static Iterable<IntegerKey> getAllConstants() => List.unmodifiable(_typeMap.values);

  static void clearConstants() => _typeMap.clear();
}
