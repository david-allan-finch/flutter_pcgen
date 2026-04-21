//
// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.helper.ConditionalAbility
import '../base/associated_prereq_object.dart';
import '../base/cdom_object.dart';
import '../../core/ability.dart';

// Holds an Ability, its AssociatedPrereqObject, and its parent CDOMObject.
class ConditionalAbility {
  final Ability _ability;
  final AssociatedPrereqObject _assoc;
  final CDOMObject _parent;

  ConditionalAbility(Ability abil, AssociatedPrereqObject apo, CDOMObject cdo)
      : _ability = abil,
        _assoc = apo,
        _parent = cdo;

  CDOMObject getParent() => _parent;
  AssociatedPrereqObject getAPO() => _assoc;
  Ability getAbility() => _ability;
}
