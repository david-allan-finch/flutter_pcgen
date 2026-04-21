//
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.rules.context.AssociatedChanges
import 'package:flutter_pcgen/src/base/util/map_to_list.dart';
import 'package:flutter_pcgen/src/cdom/base/associated_prereq_object.dart';

abstract interface class AssociatedChanges<T> {
  bool includesGlobalClear();

  List<T>? getAdded();

  List<T>? getRemoved();

  MapToList<T, AssociatedPrereqObject>? getAddedAssociations();

  MapToList<T, AssociatedPrereqObject>? getRemovedAssociations();
}
