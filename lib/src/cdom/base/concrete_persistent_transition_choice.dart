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
