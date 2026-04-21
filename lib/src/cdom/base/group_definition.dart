//
// Copyright 2014 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.base.GroupDefinition
import '../enumeration/grouping_state.dart';

// A GroupDefinition is a factory that can produce named ObjectContainers
// (groups of objects). Used for dynamic groupings based on FACT/FACTSET data.
abstract interface class GroupDefinition<T> {
  GroupingState getGroupingState();
  Type getReferenceClass();
  dynamic getChoiceActor();
  String getLSTformat(dynamic context, dynamic obj);
  dynamic getPrimitive(dynamic context, String value);
}
