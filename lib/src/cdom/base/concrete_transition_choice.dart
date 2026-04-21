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
// Translation of pcgen.cdom.base.ConcreteTransitionChoice
import 'package:flutter_pcgen/src/cdom/enumeration/association_list_key.dart';
import 'cdom_object.dart';
import 'choice_actor.dart';
import 'selectable_set.dart';
import 'transition_choice.dart';

// ConcreteTransitionChoice holds a SelectableSet and a formula for the count
// of selections, driving a GUI chooser when needed.
class ConcreteTransitionChoice<T> implements TransitionChoice<T> {
  final SelectableSet<T> _choices;
  final dynamic _choiceCount; // Formula
  bool _required = true;
  ChoiceActor<T>? _choiceActor;
  bool _allowStack = false;
  int? _stackLimit;

  ConcreteTransitionChoice(SelectableSet<T> set, dynamic count)
      : _choices = set,
        _choiceCount = count;

  @override
  SelectableSet<T> getChoices() => _choices;

  @override
  dynamic getCount() => _choiceCount;

  @override
  bool operator ==(Object obj) {
    if (obj is ConcreteTransitionChoice) {
      if (_choiceCount == obj._choiceCount ||
          (_choiceCount != null && _choiceCount == obj._choiceCount)) {
        return _choices == obj._choices;
      }
    }
    return false;
  }

  @override
  int get hashCode =>
      _choices.hashCode + 29 * (_choiceCount == null ? -1 : _choiceCount.hashCode);

  @override
  List<T> driveChoice(dynamic pc) {
    final int numChoices = _choiceCount.resolve(pc, '').toInt();
    final bool pickAll = (numChoices == 0x7fffffff);

    final set = _choices.getSet(pc);
    final List<T> allowed = [];
    final List<dynamic> assocList = pc.getAssocList(this, AssociationListKey.add) ?? [];

    for (final T item in set) {
      if (_choiceActor == null || _choiceActor!.allow(item, pc, _allowStack)) {
        if (_stackLimit != null && _stackLimit! > 0) {
          int takenCount = 0;
          for (final choice in assocList) {
            if (choice == item) takenCount++;
          }
          if (_stackLimit! <= takenCount) continue;
        }
        allowed.add(item);
      }
    }

    if (pickAll || numChoices == set.length) {
      return allowed;
    } else {
      // stub: GUI chooser not available in Dart translation
      // stub
      return allowed;
    }
  }

  @override
  void setRequired(bool isRequired) {
    _required = isRequired;
  }

  @override
  void setChoiceActor(ChoiceActor<T> actor) {
    _choiceActor = actor;
  }

  @override
  void act(List<T> choicesMade, CDOMObject owner, dynamic apc) {
    if (_choiceActor == null) {
      throw StateError('Cannot act without a defined ChoiceActor');
    }
    for (final T choice in choicesMade) {
      _choiceActor!.applyChoice(owner, choice, apc);
      apc.addAssoc(this, AssociationListKey.add, choice);
    }
  }

  T castChoice(dynamic item) => item as T;

  @override
  void allowStack(bool allow) {
    _allowStack = allow;
  }

  @override
  void setStackLimit(int limit) {
    _stackLimit = limit;
  }

  @override
  bool allowsStacking() => _allowStack;

  @override
  int? getStackLimit() => _stackLimit;

  @override
  ChoiceActor<T>? getChoiceActor() => _choiceActor;
}
