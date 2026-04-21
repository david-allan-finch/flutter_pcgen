//
// Copyright 2013 (C) James Dempsey <jdempsey@users.sourceforge.net>
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
// Translation of pcgen.cdom.enumeration.SkillFilter
// Controls which skills are shown on an output sheet.
enum SkillFilter {
  ranks(0, 'RANKS', 'Skills with Ranks'),
  nonDefault(1, 'NONDEFAULT', 'Non-Default'),
  usable(2, 'USABLE', 'Usable'),
  all(3, 'ALL', 'All Skills'),
  // Deprecated: retained for compatibility with saved characters.
  skillsTab(4, '', 'Skill Tab'),
  selected(5, 'SELECTED', null);

  final int value;
  final String token;
  final String? text;

  const SkillFilter(this.value, this.token, this.text);

  int getValue() => value;
  String getToken() => token;

  @override
  String toString() => text ?? name;

  static SkillFilter? getByValue(int value) {
    for (final filter in SkillFilter.values) {
      if (filter.value == value) return filter;
    }
    return null;
  }

  static SkillFilter? getByToken(String value) {
    for (final filter in SkillFilter.values) {
      if (filter.token.toLowerCase() == value.toLowerCase()) return filter;
    }
    return null;
  }
}
