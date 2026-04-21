//
// Copyright (c) Thomas Parker, 2013.
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
// Translation of pcgen.cdom.meta.FacetBehavior
// Categorizes how a facet is used (Model, Input, Conditional, etc.).
final class FacetBehavior {
  static final FacetBehavior model = FacetBehavior._('Model');
  static final FacetBehavior input = FacetBehavior._('Input');
  static final FacetBehavior conditional = FacetBehavior._('Conditional');
  static final FacetBehavior conditionalGranted = FacetBehavior._('Conditional-Granted');

  static final Map<String, FacetBehavior> _map = {
    'MODEL': model,
    'INPUT': input,
    'CONDITIONAL': conditional,
    'CONDITIONAL-GRANTED': conditionalGranted,
  };

  final String _type;

  FacetBehavior._(String type) : _type = type;

  static FacetBehavior getKeyFor(String type) =>
      _map.putIfAbsent(type.toUpperCase(), () => FacetBehavior._(type));

  @override
  String toString() => _type;

  static List<FacetBehavior> getAllConstants() => List.unmodifiable(_map.values);
}
