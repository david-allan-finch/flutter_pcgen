//
// Copyright (c) 2009 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.helper.ClassSource
import '../base/identified.dart';
import '../../core/pc_class.dart';

// Associates a PCClass with a caster level for domain source tracking.
class ClassSource implements Identified {
  final PCClass pcclass;
  final int level;

  ClassSource(this.pcclass, [this.level = -1]);

  @override
  String getKeyName() => '${pcclass.getFullKey()} $level';

  @override
  String? getDisplayName() => '${pcclass.getDisplayName()} $level';

  @override
  int get hashCode => pcclass.hashCode - level;

  @override
  bool operator ==(Object o) =>
      o is ClassSource && level == o.level && pcclass == o.pcclass;

  @override
  String toString() => 'ClassSource: ${getDisplayName()}';
}
