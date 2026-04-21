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
// Translation of pcgen.facade.core.DataSetFacade
import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/core/deity.dart';
import 'package:flutter_pcgen/src/core/game_mode.dart';
import 'package:flutter_pcgen/src/core/kit.dart';
import 'package:flutter_pcgen/src/core/pc_alignment.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/pc_template.dart';
import 'package:flutter_pcgen/src/core/race.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'ability_facade.dart';
import 'equipment_facade.dart';

// Provides access to all loaded game data for UI browsing.
abstract interface class DataSetFacade {
  Map<AbilityCategory, List<AbilityFacade>> getAbilities();
  List<AbilityFacade> getPrereqAbilities(AbilityFacade ability);
  List<Skill> getSkills();
  List<Race> getRaces();
  List<PCClass> getClasses();
  List<Deity> getDeities();
  List<PCTemplate> getTemplates();
  List<Campaign> getCampaigns();
  GameMode getGameMode();
  List<PCAlignment> getAlignments();
  List<PCStat> getStats();
  Skill? getSpeakLanguageSkill();
  List<EquipmentFacade> getEquipment();
  void addEquipment(EquipmentFacade equip);
  List<Kit> getKits();
}
