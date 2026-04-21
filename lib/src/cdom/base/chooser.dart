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
// Translation of pcgen.cdom.base.Chooser
import 'package:flutter_pcgen/src/cdom/base/choose_driver.dart';
import 'package:flutter_pcgen/src/cdom/base/persistent.dart';

// A Chooser can restore and remove choices for a PlayerCharacter, and is
// saved with the character's persistent state.
abstract interface class Chooser<T> implements Persistent<T> {
  void restoreChoice(dynamic pc, ChooseDriver owner, T item);
  void removeChoice(dynamic pc, ChooseDriver owner, T item);
  void applyChoice(ChooseDriver owner, T item, dynamic pc);
  bool allow(T item, dynamic pc, bool allowStack);
  List<T> getCurrentlySelected(ChooseDriver owner, dynamic pc);
}
