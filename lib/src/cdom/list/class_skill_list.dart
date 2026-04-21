//
// Copyright 2007, 2008 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.list.ClassSkillList
import '../base/cdom_list_object.dart';
import '../enumeration/type.dart' as cdom;
import '../../core/skill.dart';

// A named list of skills associated with a PCClass.
class ClassSkillList extends CDOMListObject<Skill> {
  Set<cdom.Type>? _types;

  @override
  Type get listClass => Skill;

  void addType(cdom.Type type) {
    _types ??= {};
    _types!.add(type);
  }

  @override
  bool isType(String type) {
    if (type.isEmpty || _types == null) return false;
    for (final part in type.split('.')) {
      if (!_types!.any((t) => t.toString().toLowerCase() == part.toLowerCase())) return false;
    }
    return true;
  }
}
