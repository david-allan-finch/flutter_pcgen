//
// Copyright (c) Thomas Parker, 2013-14.
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.meta.CorePerspective
// Named perspective for displaying facet data (e.g. "Granted Languages").
final class CorePerspective {
  static final CorePerspective language = CorePerspective._('Granted Languages');
  static final CorePerspective domain = CorePerspective._('Granted Domains');
  static final CorePerspective armorprof = CorePerspective._('Armor Proficiencies');
  static final CorePerspective shieldprof = CorePerspective._('Shield Proficiencies');

  static final Map<String, CorePerspective> _map = {
    'LANGUAGE': language,
    'DOMAIN': domain,
    'ARMORPROF': armorprof,
    'SHIELDPROF': shieldprof,
  };

  final String _name;

  CorePerspective._(String name) : _name = name;

  @override
  String toString() => _name;

  static List<CorePerspective> getAllConstants() => List.unmodifiable(_map.values);
}
