//
// Copyright 2008-18 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.list.CompanionList
import '../base/category.dart';
import '../base/cdom_list_object.dart';
import '../../core/race.dart';

// A typed list of companion races (Familiar, Mount, Follower, etc.).
class CompanionList extends CDOMListObject<Race> implements Category<dynamic> {
  @override
  Type get listClass => Race;

  @override
  bool isType(String type) => false;

  @override
  Category<dynamic>? getParentCategory() => null;

  @override
  bool isMember(dynamic item) {
    // item would be CompanionMod — check category field
    return false; // simplified
  }

  String getPersistentFormat() => 'COMPANIONLIST=${getKeyName()}';

  String getReferenceDescription() => 'CompanionMod of TYPE ${getKeyName()}';

  @override
  int get hashCode => getKeyName().hashCode;

  @override
  bool operator ==(Object o) =>
      o is CompanionList && getKeyName() == o.getKeyName();
}
