//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.cdom.enumeration.Component
// Standard spell component types.
enum Component {
  verbal('V', 'Spell.Components.Verbal'),
  somatic('S', 'Spell.Components.Somatic'),
  material('M', 'Spell.Components.Material'),
  divineFocus('DF', 'Spell.Components.DivineFocus'),
  focus('F', 'Spell.Components.Focus'),
  experience('XP', 'Spell.Components.Experience'),
  other('See text', 'Spell.Components.SeeText');

  final String key;
  final String nameKey;

  const Component(this.key, this.nameKey);

  String getKey() => key;

  static Component getComponentFromKey(String aKey) {
    for (final c in Component.values) {
      if (c.key.toLowerCase() == aKey.toLowerCase()) return c;
    }
    return Component.other;
  }

  @override
  String toString() => nameKey;
}
