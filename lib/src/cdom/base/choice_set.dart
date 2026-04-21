//
// Copyright 2006 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.base.ChoiceSet
import '../enumeration/grouping_state.dart';
import '../enumeration/nature.dart';
import '../reference/cdom_single_ref.dart';
import 'concrete_prereq_object.dart';
import 'primitive_choice_set.dart';
import 'selectable_set.dart';

// ChoiceSet is a named container wrapping a PrimitiveChoiceSet that implements
// SelectableSet. Also contains a static inner-class AbilityChoiceSet.
class ChoiceSet<T> extends ConcretePrereqObject implements SelectableSet<T> {
  final PrimitiveChoiceSet<T> _pcs;
  final String _setName;
  String? _title;
  final bool _useAny;

  ChoiceSet(String name, PrimitiveChoiceSet<T> choice, [bool any = false])
      : _pcs = choice,
        _setName = name,
        _useAny = any;

  @override
  String getLSTformat() => _pcs.getLSTformat(_useAny);

  @override
  Type getChoiceClass() => _pcs.getChoiceClass();

  @override
  List<T> getSet(dynamic pc) => _pcs.getSet(pc).toList();

  @override
  String getName() => _setName;

  @override
  void setTitle(String choiceTitle) {
    _title = choiceTitle;
  }

  @override
  String? getTitle() => _title;

  @override
  GroupingState getGroupingState() => _pcs.getGroupingState();

  @override
  int get hashCode => _setName.hashCode ^ _pcs.hashCode;

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is ChoiceSet) {
      return _setName == obj._setName && _pcs == obj._pcs;
    }
    return false;
  }
}

// AbilityChoiceSet extends ChoiceSet to carry category and nature information
// for ability selections.
class AbilityChoiceSet extends ChoiceSet<dynamic> {
  final dynamic _arcs; // AbilityRefChoiceSet

  AbilityChoiceSet(String name, dynamic choice)
      : _arcs = choice,
        super(name, choice);

  CDOMSingleRef<dynamic> getCategory() => _arcs.getCategory();

  Nature getNature() => _arcs.getNature();
}
