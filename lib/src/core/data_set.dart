//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.core.DataSet
import 'ability.dart';
import 'ability_category.dart';
import 'campaign.dart';
import 'deity.dart';
import 'domain.dart';
import 'equipment.dart';
import 'kit.dart';
import 'language.dart';
import 'pc_alignment.dart';
import 'pc_class.dart';
import 'pc_template.dart';
import 'pc_stat.dart';
import 'race.dart';
import 'size_adjustment.dart';
import 'skill.dart';
import 'weapon_prof.dart';

// Holds all the data loaded from data sources for a given game mode.
class DataSet {
  final List<Race> races = [];
  final List<PCClass> classes = [];
  final List<Deity> deities = [];
  final List<Skill> skills = [];
  final List<PCTemplate> templates = [];
  final List<PCAlignment> alignments = [];
  final List<Kit> kits = [];
  final List<PCStat> stats = [];
  final List<Campaign> campaigns = [];
  final List<Equipment> equipment = [];
  final List<Domain> domains = [];
  final List<Language> languages = [];
  final List<WeaponProf> weaponProfs = [];
  final List<SizeAdjustment> sizeAdjustments = [];
  final Map<AbilityCategory, List<Ability>> abilities = {};
  final List<String> xpTableNames = [];
  final List<String> characterTypes = [];

  Skill? speakLanguageSkill;
  String gameModeStr = '';

  // Add helpers
  void addRace(Race race) => races.add(race);
  void addClass(PCClass cls) => classes.add(cls);
  void addDeity(Deity deity) => deities.add(deity);
  void addSkill(Skill skill) => skills.add(skill);
  void addTemplate(PCTemplate template) => templates.add(template);
  void addAlignment(PCAlignment alignment) => alignments.add(alignment);
  void addKit(Kit kit) => kits.add(kit);
  void addStat(PCStat stat) => stats.add(stat);
  void addEquipment(Equipment eq) => equipment.add(eq);
  void addDomain(Domain domain) => domains.add(domain);
  void addLanguage(Language lang) => languages.add(lang);
  void addWeaponProf(WeaponProf prof) => weaponProfs.add(prof);
  void addSizeAdjustment(SizeAdjustment size) => sizeAdjustments.add(size);

  void addAbility(AbilityCategory category, Ability ability) {
    abilities.putIfAbsent(category, () => []).add(ability);
  }

  List<Ability> getAbilitiesInCategory(AbilityCategory category) {
    return List.unmodifiable(abilities[category] ?? []);
  }

  // Lookup helpers
  Race? findRace(String key) => _find(races, key);
  PCClass? findClass(String key) => _find(classes, key);
  Skill? findSkill(String key) => _find(skills, key);
  Deity? findDeity(String key) => _find(deities, key);
  PCStat? findStat(String key) => _find(stats, key);

  T? _find<T extends dynamic>(List<T> list, String key) {
    for (final item in list) {
      if ((item as dynamic).getKeyName().toLowerCase() == key.toLowerCase()) {
        return item;
      }
    }
    return null;
  }
}
