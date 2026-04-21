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
// Translation of pcgen.cdom.base.ConcretePersistentTransitionChoice
import '../enumeration/association_list_key.dart';
import 'cdom_object.dart';
import 'choice_actor.dart';
import 'concrete_transition_choice.dart';
import 'persistent_choice_actor.dart';
import 'persistent_transition_choice.dart';
import 'selectable_set.dart';

// ConcretePersistentTransitionChoice extends ConcreteTransitionChoice to add
// encoding/decoding and persistent-restore behaviour.
class ConcretePersistentTransitionChoice<T> extends ConcreteTransitionChoice<T>
    implements PersistentTransitionChoice<T> {
  PersistentChoiceActor<T>? _choiceActor;

  ConcretePersistentTransitionChoice(SelectableSet<T> set, dynamic count)
      : super(set, count);

  @override
  void setChoiceActor(ChoiceActor<T> actor) {
    _choiceActor = actor as PersistentChoiceActor<T>;
    super.setChoiceActor(actor);
  }

  @override
  String encodeChoice(T item) => _choiceActor!.encodeChoice(item);

  @override
  T decodeChoice(dynamic context, String persistentFormat) =>
      _choiceActor!.decodeChoice(context, persistentFormat);

  @override
  void restoreChoice(dynamic pc, CDOMObject owner, T item) {
    pc.addAssoc(this, AssociationListKey.add, item);
    _choiceActor!.restoreChoice(pc, owner, item);
  }

  @override
  void remove(CDOMObject owner, dynamic pc) {
    final List<dynamic>? ch = pc.removeAllAssocs(this, AssociationListKey.add);
    if (ch != null) {
      for (final o in ch) {
        _choiceActor!.removeChoice(pc, owner, castChoice(o));
      }
    }
  }

  @override
  PersistentChoiceActor<T>? getChoiceActor() => _choiceActor;

  @override
  Type getChoiceClass() => getChoices().getChoiceClass();
}
