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
import '../../core/ability_category.dart';
import '../../core/campaign.dart';
import '../../core/deity.dart';
import '../../core/game_mode.dart';
import '../../core/kit.dart';
import '../../core/pc_alignment.dart';
import '../../core/pc_class.dart';
import '../../core/pc_stat.dart';
import '../../core/pc_template.dart';
import '../../core/race.dart';
import '../../core/skill.dart';
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
