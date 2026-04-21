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
// Translation of pcgen.cdom.base.CDOMObjectUtilities
import 'cdom_object.dart';
import 'loadable.dart';
import 'persistent_transition_choice.dart';
import 'transition_choice.dart';
import '../enumeration/list_key.dart';

// CDOMObjectUtilities provides static helpers for working with CDOMObjects,
// including applying/removing ADD and REMOVE transition choices.
class CDOMObjectUtilities {
  CDOMObjectUtilities._();

  /// Compares the key names of two Loadable objects; null sorts last.
  static int compareKeys(Loadable cdo1, Loadable cdo2) {
    final base = cdo1.getKeyName();
    if (base == null) {
      return (cdo2.getKeyName() == null) ? 0 : -1;
    } else {
      return (cdo2.getKeyName() == null) ? 1 : base.compareTo(cdo2.getKeyName()!);
    }
  }

  static void addAdds(CDOMObject cdo, dynamic pc) {
    if (!pc.isAllowInteraction()) return;
    final List<PersistentTransitionChoice> addList =
        cdo.getListFor(ListKey.add) ?? [];
    for (final tc in addList) {
      _driveChoice(cdo, tc, pc);
    }
  }

  static void removeAdds(CDOMObject cdo, dynamic pc) {
    if (!pc.isAllowInteraction()) return;
    final List<PersistentTransitionChoice> addList =
        cdo.getListFor(ListKey.add) ?? [];
    for (final tc in addList) {
      tc.remove(cdo, pc);
    }
  }

  static void checkRemovals(CDOMObject cdo, dynamic pc) {
    if (!pc.isAllowInteraction()) return;
    final List<PersistentTransitionChoice> removeList =
        cdo.getListFor(ListKey.remove) ?? [];
    for (final tc in removeList) {
      _driveChoice(cdo, tc, pc);
    }
  }

  static void restoreRemovals(CDOMObject cdo, dynamic pc) {
    if (!pc.isAllowInteraction()) return;
    final List<PersistentTransitionChoice> removeList =
        cdo.getListFor(ListKey.remove) ?? [];
    for (final tc in removeList) {
      tc.remove(cdo, pc);
    }
  }

  static void _driveChoice<T>(CDOMObject cdo, TransitionChoice<T> tc, dynamic pc) {
    tc.act(tc.driveChoice(pc), cdo, pc);
  }
}
