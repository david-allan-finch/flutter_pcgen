//
// Copyright 2006 Aaron Divinsky <boomer70@yahoo.com>
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
// Translation of pcgen.cdom.base.ConcretePrereqObject
import 'package:flutter_pcgen/src/base/util/list_set.dart';
import 'package:flutter_pcgen/src/cdom/prereq/prerequisite.dart';
import 'prereq_object.dart';

// Provides a quick foundation class that implements PrereqObject.
class ConcretePrereqObject implements PrereqObject {
  ListSet<Prerequisite>? _thePrereqs;

  @override
  List<Prerequisite> getPrerequisiteList() {
    if (_thePrereqs == null) return const [];
    return List.unmodifiable(_thePrereqs!);
  }

  bool hasPreReqTypeOf(String matchType) {
    if (!hasPrerequisites()) return false;
    return getPrerequisiteList().any(
      (prereq) => _hasPreReqKindOf(prereq, matchType),
    );
  }

  bool _hasPreReqKindOf(Prerequisite prereq, String matchType) {
    if (prereq.kind != null &&
        prereq.kind!.toUpperCase() == matchType.toUpperCase()) {
      return true;
    }
    return prereq
        .getPrerequisites()
        .any((p) => _hasPreReqKindOf(p, matchType));
  }

  ConcretePrereqObject clone() {
    final obj = ConcretePrereqObject();
    if (_thePrereqs != null) {
      obj._thePrereqs = ListSet<Prerequisite>();
      obj._thePrereqs!.addAll(_thePrereqs!);
    }
    return obj;
  }

  @override
  void addAllPrerequisites(Iterable<Prerequisite> prereqs) {
    for (final pre in prereqs) {
      addPrerequisite(pre);
    }
  }

  @override
  void addPrerequisite(Prerequisite preReq) {
    _thePrereqs ??= ListSet<Prerequisite>();
    _thePrereqs!.add(preReq);
  }

  @override
  void clearPrerequisiteList() {
    _thePrereqs = null;
  }

  @override
  int getPrerequisiteCount() {
    return _thePrereqs?.length ?? 0;
  }

  @override
  bool hasPrerequisites() {
    return _thePrereqs != null;
  }

  bool equalsPrereqObject(PrereqObject other) {
    if (identical(this, other)) return true;
    final otherHas = other.hasPrerequisites();
    if (!hasPrerequisites()) return !otherHas;
    if (!otherHas) return false;
    final otherPRL = other.getPrerequisiteList();
    if (otherPRL.length != _thePrereqs!.length) return false;
    final removed = List<Prerequisite>.from(_thePrereqs!);
    removed.removeWhere((p) => otherPRL.contains(p));
    return removed.isEmpty;
  }

  bool qualifies(dynamic aPC, Object? owner) {
    if (!hasPrerequisites()) return true;
    // PrereqHandler.passesAll deferred to full prereq system implementation
    return true;
  }

  @override
  bool isAvailable(dynamic aPC) => true;

  @override
  bool isActive(dynamic aPC) => true;
}
