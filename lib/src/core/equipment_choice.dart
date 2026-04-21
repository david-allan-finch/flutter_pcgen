//
// Copyright 2004 (C) James Dempsey <jdempsey@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.EquipmentChoice
// EquipmentChoice.dart
// Translated from pcgen/core/EquipmentChoice.java
// FacetLibrary/EquipmentTypeFacet are stubbed.

import 'package:flutter_pcgen/src/core/globals.dart';
import 'package:flutter_pcgen/src/core/equipment.dart';
import 'package:flutter_pcgen/src/core/equipment_modifier.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/formula_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/analysis/choose_activation.dart';
import 'package:flutter_pcgen/src/core/utils/delta.dart';
import 'package:flutter_pcgen/src/core/utils/signed_integer.dart';

/// Holds the details of a choice or choices required for an Equipment.
class EquipmentChoice {
  // stub: EquipmentTypeFacet – use dynamic / stub access
  dynamic _equipmentTypeFacet; // stub

  bool allowDuplicates = false;
  bool noSign = false;
  bool bAdd;
  bool skipZero = false;

  int minValue = 0;
  int maxValue = 0;
  int incValue = 1;
  int maxSelect = 0;
  int pool;
  String? title;

  List<Object> availableList = [];

  EquipmentChoice(this.bAdd, this.pool) {
    // stub: _equipmentTypeFacet = FacetLibrary.getFacet(EquipmentTypeFacet)
  }

  // ---------------------------------------------------------------------------
  // Choice iterator
  // ---------------------------------------------------------------------------

  /// Create an iterator-like list over the available choices.
  List<Object> getChoiceIteratorList(bool neverEmpty) {
    if (neverEmpty && availableList.isEmpty) {
      return [''];
    }

    if (minValue < maxValue) {
      final List<Object> finalList = [];
      for (final Object o in availableList) {
        final String choice = o.toString();
        if (!choice.contains('|')) {
          for (int j = minValue; j <= maxValue; j += incValue) {
            if (!skipZero || j != 0) {
              finalList.add('$choice|${Delta.toString(j)}');
            }
          }
        } else {
          finalList.add(choice);
        }
      }
      return finalList;
    }

    return List<Object>.from(availableList);
  }

  // ---------------------------------------------------------------------------
  // Getters / Setters
  // ---------------------------------------------------------------------------

  int getPool() => pool;
  void setPool(int p) => pool = p;

  bool isBAdd() => bAdd;
  void setBAdd(bool add) => bAdd = add;

  List<Object> getAvailableList() => availableList;
  bool isAllowDuplicates() => allowDuplicates;
  void setAllowDuplicates(bool v) => allowDuplicates = v;

  int getIncValue() => incValue;
  void setIncValue(int v) => incValue = v;

  int getMaxSelect() => maxSelect;
  void setMaxSelect(int v) => maxSelect = v;

  int getMaxValue() => maxValue;
  void setMaxValue(int v) => maxValue = v;

  int getMinValue() => minValue;
  void setMinValue(int v) => minValue = v;

  bool isNoSign() => noSign;
  void setNoSign(bool v) => noSign = v;

  String? getTitle() => title;
  void setTitle(String? v) => title = v;

  // ---------------------------------------------------------------------------
  // Add skills / stats / equipment / abilities
  // ---------------------------------------------------------------------------

  void addSkills() {
    for (final Skill skill in Globals.getContext()
        .getReferenceContext()
        .getConstructedCDOMObjects(Skill)) {
      availableList.add(skill.getKeyName());
    }
  }

  void setMinValueFromString(String minString) {
    try {
      setMinValue(Delta.parseInt(minString.substring(4)));
    } catch (_) {
      // log: Bad MIN= value: $minString
    }
  }

  void setMaxValueFromString(String maxString) {
    try {
      setMaxValue(Delta.parseInt(maxString.substring(4)));
    } catch (_) {
      // log: Bad MAX= value: $maxString
    }
  }

  void setIncrementValueFromString(String incString) {
    try {
      int v = Delta.parseInt(incString.substring(10));
      if (v < 1) v = 1;
      setIncValue(v);
    } catch (_) {
      // ignore
    }
  }

  void addSelectableAbilities(String typeString, String aCategory) {
    final dynamic ref = Globals.getContext().getReferenceContext();
    final AbilityCategory? cat =
        ref.silentlyGetConstructedCDOMObject(AbilityCategory, aCategory) as AbilityCategory?;
    if (cat == null) return;
    for (final Ability anAbility in ref.getManufacturerId(cat).getAllObjects() as Iterable<Ability>) {
      final bool matchesType =
          typeString.toLowerCase() == 'all' || anAbility.isType(typeString);
      if ((anAbility.getSafeObject(ObjectKey.visibility) as dynamic)?.toString() == 'DEFAULT' &&
          !availableList.contains(anAbility.getKeyName())) {
        if (matchesType && !ChooseActivation.hasNewChooseToken(anAbility)) {
          availableList.add(anAbility.getKeyName());
        }
      }
    }
  }

  void addSelectableEquipment(String typeString) {
    for (final Equipment aEquip in Globals.getContext()
        .getReferenceContext()
        .getConstructedCDOMObjects(Equipment)) {
      if (aEquip.isType(typeString) && !availableList.contains(aEquip.getName())) {
        availableList.add(aEquip.getName());
      }
    }
  }

  void addSelectableSkills(String typeString) {
    for (final Skill skill in Globals.getContext()
        .getReferenceContext()
        .getConstructedCDOMObjects(Skill)) {
      if ((typeString.toLowerCase() == 'all' || skill.isType(typeString)) &&
          !availableList.contains(skill.getKeyName())) {
        availableList.add(skill.getKeyName());
      }
    }
  }

  void addParentsExistingEquipmentModifiersToChooser(
      Equipment parent, String choiceType) {
    for (final EquipmentModifier sibling in parent.getEqModifierList(true)) {
      if (sibling.getSafeString(StringKey.choiceString).toString().startsWith(choiceType)) {
        availableList.addAll(parent.getAssociationList(sibling));
      }
    }
  }

  void addStats() {
    for (final PCStat stat in Globals.getContext()
        .getReferenceContext()
        .getConstructedCDOMObjects(PCStat)) {
      availableList.add(stat.getKeyName());
    }
  }

  void adjustPool(int available, int numSelected) {
    if (available > 0 && maxSelect > 0 && maxSelect != 0x7fffffff) {
      setPool(maxSelect - numSelected);
    }
  }

  // ---------------------------------------------------------------------------
  // addChoicesByType
  // ---------------------------------------------------------------------------

  void addChoicesByType(Equipment parent, int numOfChoices, int numChosen,
      String filterBy, String kindToAdd, String category) {
    if (numOfChoices > 0 && maxSelect == 0) {
      setPool(numOfChoices - numChosen);
    }

    final String type = filterBy.substring(5);

    if (type.startsWith('LASTCHOICE')) {
      addParentsExistingEquipmentModifiersToChooser(parent, kindToAdd);
    } else if (kindToAdd.toLowerCase() == 'skill') {
      addSelectableSkills(type);
    } else if (kindToAdd.toLowerCase() == 'equipment') {
      addSelectableEquipment(type);
    } else if (kindToAdd.toLowerCase() == 'ability') {
      addSelectableAbilities(type, category);
    } else if (kindToAdd.toLowerCase() == 'feat') {
      addSelectableAbilities(type, 'FEAT');
    } else if (type.toLowerCase() == 'eqtypes') {
      // stub: EquipmentTypeFacet.getSet(...)
      // log: EQTYPES choice list from facet not fully supported
    } else {
      // log: Unknown option in CHOOSE '$filterBy'
    }
  }

  // ---------------------------------------------------------------------------
  // constructFromChoiceString
  // ---------------------------------------------------------------------------

  void constructFromChoiceString(
    String choiceString,
    Equipment parent,
    int available,
    int numSelected,
    bool forEqBuilder,
    PlayerCharacter pc,
  ) {
    // First pass: extract TITLE
    if (!forEqBuilder) {
      for (final String part in choiceString.split('|')) {
        if (part.startsWith('TITLE=')) {
          setTitle(part.substring(6));
        }
      }
    }

    final int select =
        (parent.getSafeFormula(FormulaKey.select) as dynamic)?.resolve(parent, true, pc, '')?.toInt() ?? 0;
    setMaxSelect(select);

    String? originalkind;
    bool needStats = false;
    bool needSkills = false;
    String? category;

    if (!forEqBuilder) {
      for (final String kind in choiceString.split('|')) {
        if (category == null) {
          if (kind == 'ABILITY') {
            // category will be set on next token – handled below
            category = null; // placeholder
          } else {
            category = 'FEAT';
          }
        }

        adjustPool(available, numSelected);

        if (kind.startsWith('TITLE=') || kind.startsWith('COUNT=')) {
          // already handled
          // log: kind starts with TITLE=/COUNT= and we've already processed this
        } else {
          if (originalkind == null) {
            originalkind = kind;
            needStats = originalkind == 'STATBONUS';
            needSkills = originalkind == 'SKILLBONUS';
          } else if (kind.startsWith('TYPE=') || kind.startsWith('TYPE.')) {
            if (originalkind == 'SKILLBONUS' || originalkind == 'SKILL') {
              needSkills = false;
              addChoicesByType(parent, available, numSelected, kind, 'SKILL', '');
            } else if (originalkind == 'EQUIPMENT' ||
                originalkind == 'FEAT' ||
                originalkind == 'ABILITY') {
              addChoicesByType(
                  parent, available, numSelected, kind, originalkind, category ?? 'FEAT');
            } else {
              addChoicesByType(
                  parent, available, numSelected, kind, title ?? '', category ?? 'FEAT');
            }
          } else if (kind == 'STAT') {
            addStats();
          } else if (kind == 'SKILL') {
            addSkills();
          } else if (kind == 'SKIPZERO') {
            skipZero = originalkind == 'NUMBER';
          } else if (kind == 'MULTIPLE') {
            setAllowDuplicates(true);
          } else if (kind == 'NOSIGN') {
            setNoSign(true);
          } else if (kind.startsWith('MIN=')) {
            setMinValueFromString(kind);
          } else if (kind.startsWith('MAX=')) {
            setMaxValueFromString(kind);
          } else if (kind.startsWith('INCREMENT=')) {
            setIncrementValueFromString(kind);
          } else {
            needStats = false;
            needSkills = false;
            if (!availableList.contains(kind)) {
              availableList.add(kind);
            }
          }
        }
      }
    }

    if (needStats) {
      addStats();
    } else if (needSkills) {
      addSkills();
    }

    if (title == null) {
      setTitle(originalkind);
    }

    if (maxSelect == 0x7fffffff) {
      setPool(availableList.length - numSelected);
      setBAdd(true);
    }

    if (availableList.isEmpty && minValue < maxValue) {
      for (int j = minValue; j <= maxValue; j += incValue) {
        if (!skipZero || j != 0) {
          if (noSign) {
            availableList.add(j);
          } else {
            availableList.add(SignedInteger(j));
          }
        }
      }
      setMinValue(maxValue);
    }
  }
}
