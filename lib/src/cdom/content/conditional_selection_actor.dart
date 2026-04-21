//
// Copyright (c) 2013 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.content.ConditionalSelectionActor
import '../base/choose_selection_actor.dart';
import '../base/concrete_prereq_object.dart';
import '../base/choose_driver.dart';

// A ConditionalSelectionActor decorates a ChooseSelectionActor to make
// application conditional on Prerequisites. Removal is always unconditional.
class ConditionalSelectionActor<T> extends ConcretePrereqObject
    implements ChooseSelectionActor<T> {
  final ChooseSelectionActor<T> _actor;

  ConditionalSelectionActor(ChooseSelectionActor<T> csa) : _actor = csa;

  static ConditionalSelectionActor<GT> getCSA<GT>(ChooseSelectionActor<GT> csa) =>
      ConditionalSelectionActor<GT>(csa);

  @override
  void applyChoice(ChooseDriver cdo, T choice, dynamic pc) {
    if (qualifies(pc, cdo)) {
      _actor.applyChoice(cdo, choice, pc);
    }
  }

  @override
  void removeChoice(ChooseDriver cdo, T choice, dynamic pc) {
    _actor.removeChoice(cdo, choice, pc);
  }

  @override
  String getSource() => _actor.getSource();

  @override
  String getLstFormat() {
    final sb = StringBuffer(_actor.getLstFormat());
    if (hasPrerequisites()) {
      sb.write('|');
      sb.write(getPrerequisiteList().map((p) => p.toString()).join('|'));
    }
    return sb.toString();
  }

  @override
  Type getChoiceClass() => _actor.getChoiceClass();

  @override
  bool operator ==(Object other) {
    if (other is ConditionalSelectionActor<T>) {
      return _actor == other._actor && equalsPrereqObject(other);
    }
    return false;
  }

  @override
  int get hashCode => _actor.hashCode;
}
