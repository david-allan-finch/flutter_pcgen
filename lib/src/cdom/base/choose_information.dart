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
// Translation of pcgen.cdom.base.ChooseInformation
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';

// Holds the set of choices and related metadata for the CHOOSE system.
// Encodes/decodes to persistent LST strings.
abstract interface class ChooseInformation<T> {
  String getName();
  String getLSTformat();
  String getTitle();
  GroupingState getGroupingState();
  Type getReferenceClass();
  T decodeChoice(dynamic context, String persistentFormat);
  String encodeChoice(T choice);
  List<T> getSet(dynamic pc, dynamic driver);
  void restoreChoice(dynamic pc, dynamic owner, T choice);
  dynamic getChoiceActor();
  void setChoiceActor(dynamic actor);
  bool allowsPersistentStorage();
}
