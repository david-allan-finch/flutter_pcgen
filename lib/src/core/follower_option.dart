//
// Copyright 2006 (C) Aaron Divinsky <boomer70@yahoo.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.FollowerOption
import 'package:flutter_pcgen/src/cdom/base/concrete_prereq_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/core/race.dart';

// A possible companion/follower choice with an optional level adjustment.
class FollowerOption extends ConcretePrereqObject implements Comparable<FollowerOption> {
  final CDOMReference<Race> ref;
  final String listName; // CompanionList name (e.g. "Familiar")
  int adjustment = 0;

  FollowerOption(this.ref, this.listName);

  Race? getRace() {
    final contained = ref.getContainedObjects();
    return contained.length == 1 ? contained.first : null;
  }

  CDOMReference<Race> getRaceRef() => ref;

  @override
  int compareTo(FollowerOption other) {
    final r = getRace();
    final or = other.getRace();
    if (r == null && or == null) return 0;
    if (r == null) return -1;
    if (or == null) return 1;
    return r.getKeyName().compareTo(or.getKeyName());
  }

  @override
  String toString() => ref.getLSTformat();
}
