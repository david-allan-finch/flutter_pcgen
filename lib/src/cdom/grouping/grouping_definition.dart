//
// Copyright 2018 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.grouping.GroupingDefinition
import 'grouping_collection.dart';
import 'grouping_info.dart';

// Parser that converts a persistent grouping string into a GroupingCollection.
abstract interface class GroupingDefinition<T> {
  String getIdentification();
  Type getUsableLocation();
  GroupingCollection<T> process(dynamic context, GroupingInfo<T> info);
  bool requiresDirect();
}
