//
// Copyright 2014 (C) Stefan Radermacher
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
// Translation of pcgen.util.enumeration.Tab
enum Tab {
  summary('Summary', 'in_summary'),
  race('Race', 'in_race'),
  templates('Templates', 'in_Templates'),
  classes('Class', 'in_clClass'),
  skills('Skills', 'in_skills'),
  abilities('Feats', 'in_featsAbilities'),
  domains('Domains', 'in_domains'),
  spells('Spells', 'in_spells'),
  knownSpells('Known', 'in_InfoKnown', index: 0),
  preparedSpells('Prepared', 'in_InfoPrepared', index: 1),
  spellbooks('Spellbooks', 'in_InfoSpellbooks', index: 2),
  inventory('Inventory', 'in_inventory'),
  purchase('Purchase', 'in_purchase', index: 0),
  equipping('Equipping', 'in_equipping', index: 1),
  description('Description', 'in_descrip'),
  tempBonus('TempMod', 'in_InfoTempMod'),
  companions('Companions', 'in_companions'),
  characterSheet('Character Sheet', 'in_character_sheet');

  final String text;
  final String label;
  final int index;

  const Tab(this.text, String label, {this.index = 0})
      : label = label.isEmpty ? text : label;

  @override
  String toString() => text;

  static bool exists(String name) => getTab(name) != null;

  static Tab? getTab(String name) {
    for (final tab in Tab.values) {
      if (tab.text.toLowerCase() == name.toLowerCase()) return tab;
    }
    return null;
  }
}
