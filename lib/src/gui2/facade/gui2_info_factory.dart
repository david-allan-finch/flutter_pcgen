// *
// Copyright James Dempsey, 2010
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
// Translation of pcgen.gui2.facade.Gui2InfoFactory

/// Factory class that produces HTML info strings for various PCGen objects
/// (abilities, spells, equipment, skills, races, classes, etc.) for display
/// in the GUI info panes. Equivalent to Java's Gui2InfoFactory.
class Gui2InfoFactory {
  Gui2InfoFactory._();

  // ---- Ability info -------------------------------------------------------

  static String getAbilityInfo(dynamic ability) {
    if (ability == null) return '';
    final buf = StringBuffer('<html><body>');
    _heading(buf, _str(ability, 'name'));
    _row(buf, 'Category', _str(ability, 'category'));
    _row(buf, 'Type', _str(ability, 'type'));
    _row(buf, 'Description', _str(ability, 'description'));
    _row(buf, 'Source', _str(ability, 'source'));
    buf.write('</body></html>');
    return buf.toString();
  }

  // ---- Skill info ---------------------------------------------------------

  static String getSkillInfo(dynamic skill) {
    if (skill == null) return '';
    final buf = StringBuffer('<html><body>');
    _heading(buf, _str(skill, 'name'));
    _row(buf, 'Key Ability', _str(skill, 'keyAbility'));
    _row(buf, 'Use Untrained', _bool(skill, 'useUntrained') ? 'Yes' : 'No');
    _row(buf, 'Armor Check Penalty', _bool(skill, 'armorCheckPenalty') ? 'Yes' : 'No');
    _row(buf, 'Description', _str(skill, 'description'));
    _row(buf, 'Source', _str(skill, 'source'));
    buf.write('</body></html>');
    return buf.toString();
  }

  // ---- Race info ----------------------------------------------------------

  static String getRaceInfo(dynamic race) {
    if (race == null) return '';
    final buf = StringBuffer('<html><body>');
    _heading(buf, _str(race, 'name'));
    _row(buf, 'Type', _str(race, 'type'));
    _row(buf, 'Subtype', _str(race, 'subtype'));
    _row(buf, 'Size', _str(race, 'size'));
    _row(buf, 'Movement', _str(race, 'movement'));
    _row(buf, 'Vision', _str(race, 'vision'));
    _row(buf, 'Favored Class', _str(race, 'favoredClass'));
    _row(buf, 'Description', _str(race, 'description'));
    _row(buf, 'Source', _str(race, 'source'));
    buf.write('</body></html>');
    return buf.toString();
  }

  // ---- Class info ---------------------------------------------------------

  static String getClassInfo(dynamic charClass) {
    if (charClass == null) return '';
    final buf = StringBuffer('<html><body>');
    _heading(buf, _str(charClass, 'name'));
    _row(buf, 'Alignment', _str(charClass, 'alignment'));
    _row(buf, 'HD', _str(charClass, 'hd'));
    _row(buf, 'BAB', _str(charClass, 'bab'));
    _row(buf, 'Fort', _str(charClass, 'fort'));
    _row(buf, 'Ref', _str(charClass, 'ref'));
    _row(buf, 'Will', _str(charClass, 'will'));
    _row(buf, 'Skill Points/Level', _str(charClass, 'skillPoints'));
    _row(buf, 'Description', _str(charClass, 'description'));
    _row(buf, 'Source', _str(charClass, 'source'));
    buf.write('</body></html>');
    return buf.toString();
  }

  // ---- Spell info ---------------------------------------------------------

  static String getSpellInfo(dynamic spell) {
    if (spell == null) return '';
    final buf = StringBuffer('<html><body>');
    _heading(buf, _str(spell, 'name'));
    _row(buf, 'School', _str(spell, 'school'));
    _row(buf, 'Subschool', _str(spell, 'subschool'));
    _row(buf, 'Descriptor', _str(spell, 'descriptor'));
    _row(buf, 'Level', _str(spell, 'levelString'));
    _row(buf, 'Components', _str(spell, 'components'));
    _row(buf, 'Casting Time', _str(spell, 'castingTime'));
    _row(buf, 'Range', _str(spell, 'range'));
    _row(buf, 'Target/Area', _str(spell, 'target'));
    _row(buf, 'Duration', _str(spell, 'duration'));
    _row(buf, 'Saving Throw', _str(spell, 'save'));
    _row(buf, 'Spell Resistance', _str(spell, 'sr'));
    final desc = _str(spell, 'description');
    if (desc.isNotEmpty) {
      buf.write('<p>${_esc(desc)}</p>');
    }
    _row(buf, 'Source', _str(spell, 'source'));
    buf.write('</body></html>');
    return buf.toString();
  }

  // ---- Equipment info -----------------------------------------------------

  static String getEquipmentInfo(dynamic equip) {
    if (equip == null) return '';
    final buf = StringBuffer('<html><body>');
    _heading(buf, _str(equip, 'name'));
    _row(buf, 'Type', _str(equip, 'type'));
    _row(buf, 'Weight', _str(equip, 'weight'));
    _row(buf, 'Cost', _str(equip, 'cost'));
    _row(buf, 'AC Bonus', _str(equip, 'acBonus'));
    _row(buf, 'Max Dex', _str(equip, 'maxDex'));
    _row(buf, 'Armor Check Penalty', _str(equip, 'acPenalty'));
    _row(buf, 'Damage', _str(equip, 'damage'));
    _row(buf, 'Critical', _str(equip, 'critical'));
    _row(buf, 'Range', _str(equip, 'range'));
    _row(buf, 'Description', _str(equip, 'description'));
    _row(buf, 'Source', _str(equip, 'source'));
    buf.write('</body></html>');
    return buf.toString();
  }

  // ---- Domain info --------------------------------------------------------

  static String getDomainInfo(dynamic domain) {
    if (domain == null) return '';
    final buf = StringBuffer('<html><body>');
    _heading(buf, _str(domain, 'name'));
    _row(buf, 'Description', _str(domain, 'description'));
    _row(buf, 'Source', _str(domain, 'source'));
    buf.write('</body></html>');
    return buf.toString();
  }

  // ---- Template info ------------------------------------------------------

  static String getTemplateInfo(dynamic template) {
    if (template == null) return '';
    final buf = StringBuffer('<html><body>');
    _heading(buf, _str(template, 'name'));
    _row(buf, 'Type', _str(template, 'type'));
    _row(buf, 'Description', _str(template, 'description'));
    _row(buf, 'Source', _str(template, 'source'));
    buf.write('</body></html>');
    return buf.toString();
  }

  // ---- Kit info -----------------------------------------------------------

  static String getKitInfo(dynamic kit) {
    if (kit == null) return '';
    final buf = StringBuffer('<html><body>');
    _heading(buf, _str(kit, 'name'));
    _row(buf, 'Description', _str(kit, 'description'));
    _row(buf, 'Source', _str(kit, 'source'));
    buf.write('</body></html>');
    return buf.toString();
  }

  // ---- Temp bonus info ----------------------------------------------------

  static String getTempBonusInfo(dynamic bonus) {
    if (bonus == null) return '';
    final buf = StringBuffer('<html><body>');
    _heading(buf, _str(bonus, 'name'));
    _row(buf, 'Expression', _str(bonus, 'expression'));
    _row(buf, 'Type', _str(bonus, 'type'));
    _row(buf, 'Description', _str(bonus, 'description'));
    _row(buf, 'Source', _str(bonus, 'source'));
    buf.write('</body></html>');
    return buf.toString();
  }

  // ---- Companion info -----------------------------------------------------

  static String getCompanionInfo(dynamic companion) {
    if (companion == null) return '';
    final buf = StringBuffer('<html><body>');
    _heading(buf, _str(companion, 'name'));
    _row(buf, 'Type', _str(companion, 'type'));
    _row(buf, 'Race', _str(companion, 'race'));
    _row(buf, 'Description', _str(companion, 'description'));
    buf.write('</body></html>');
    return buf.toString();
  }

  // ---- Helpers ------------------------------------------------------------

  static void _heading(StringBuffer buf, String text) {
    if (text.isNotEmpty) buf.write('<h3>${_esc(text)}</h3>');
  }

  static void _row(StringBuffer buf, String label, String value) {
    if (value.isEmpty) return;
    buf.write('<b>${_esc(label)}:</b> ${_esc(value)}<br>');
  }

  static String _str(dynamic obj, String key) {
    if (obj is Map) return obj[key]?.toString() ?? '';
    return '';
  }

  static bool _bool(dynamic obj, String key) {
    if (obj is Map) return obj[key] as bool? ?? false;
    return false;
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
