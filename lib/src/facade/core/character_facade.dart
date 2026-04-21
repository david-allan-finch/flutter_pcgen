//
// Copyright 2008 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.facade.core.CharacterFacade
import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/core/deity.dart';
import 'package:flutter_pcgen/src/core/domain.dart';
import 'package:flutter_pcgen/src/core/gear_buy_sell_scheme.dart';
import 'package:flutter_pcgen/src/core/language.dart';
import 'package:flutter_pcgen/src/core/pc_alignment.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/pc_template.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/qualified_object.dart';
import 'package:flutter_pcgen/src/core/race.dart';
import 'package:flutter_pcgen/src/facade/util/reference_facade.dart';
import 'package:flutter_pcgen/src/facade/core/ability_facade.dart';
import 'package:flutter_pcgen/src/facade/core/data_set_facade.dart';
import 'package:flutter_pcgen/src/facade/core/equipment_facade.dart';

// The primary facade interface between the core and UI layers for a character.
// All mutable state goes through this interface to enable reactive UI updates.
abstract interface class CharacterFacade {
  // -- Identity --
  String getName();
  void setName(String name);
  ReferenceFacade<String> getNameRef();
  String getPlayersName();
  void setPlayersName(String name);
  String getTabName();
  void setTabName(String name);
  ReferenceFacade<String> getTabNameRef();
  String? getFilePath();
  void setFilePath(String? path);
  ReferenceFacade<String?> getFileRef();

  // -- Race / Alignment / Basics --
  Race? getRace();
  void setRace(Race race);
  PCAlignment? getAlignment();
  void setAlignment(PCAlignment alignment);
  String getGender();
  void setGender(String gender);
  String getHandedness();
  void setHandedness(String handed);

  // -- Stats --
  int getScoreBase(PCStat stat);
  void setScoreBase(PCStat stat, int score);
  int getModTotal(PCStat stat);
  int getScoreRaceBonus(PCStat stat);
  int getScoreOtherBonus(PCStat stat);
  String getScoreTotalString(PCStat stat);

  // -- Class levels --
  void addCharacterLevels(List<PCClass> classes);
  void removeCharacterLevels(int levels);
  int getClassLevel(PCClass c);

  // -- Abilities --
  void addAbility(AbilityCategory category, AbilityFacade ability);
  void removeAbility(AbilityCategory category, AbilityFacade ability);
  List<AbilityFacade> getAbilities(AbilityCategory category);
  List<AbilityCategory> getActiveAbilityCategories();
  int getTotalSelections(AbilityCategory category);
  int getRemainingSelections(AbilityCategory category);
  void setRemainingSelection(AbilityCategory category, int remaining);

  // -- Deity / Domains --
  Deity? getDeity();
  void setDeity(Deity deity);
  List<QualifiedObject<Domain>> getDomains();
  void addDomain(QualifiedObject<Domain> domain);
  void removeDomain(QualifiedObject<Domain> domain);
  int getRemainingDomainSelections();
  List<QualifiedObject<Domain>> getAvailableDomains();

  // -- Equipment --
  List<EquipmentFacade> getPurchasedEquipment();
  void addPurchasedEquipment(EquipmentFacade equipment, int quantity, {bool customize = false, bool free = false});
  void removePurchasedEquipment(EquipmentFacade equipment, int quantity, {bool free = false});
  bool isQualifiedForEquipment(EquipmentFacade equipment);

  // -- Funds --
  double getFunds();
  void setFunds(double newVal);
  void adjustFunds(double modVal);
  double getWealth();
  GearBuySellScheme? getGearBuySellScheme();
  void setGearBuySellScheme(GearBuySellScheme scheme);
  bool isAllowDebt();
  void setAllowDebt(bool allowed);
  bool isAutoResize();
  void setAutoResize(bool autoResize);

  // -- Languages --
  List<Language> getLanguages();
  bool isAutomatic(Language language);
  bool isRemovable(Language language);
  void removeLanguage(Language lang);

  // -- Templates --
  void addTemplate(PCTemplate template);
  void removeTemplate(PCTemplate template);
  List<PCTemplate> getTemplates();

  // -- XP --
  int getXP();
  void setXP(int xp);
  void adjustXP(int xp);
  int getXPForNextLevel();

  // -- DataSet --
  DataSetFacade getDataSet();

  // -- Underlying PC --
  PlayerCharacter getPC();

  // -- Dirty state --
  bool isDirty();
}
