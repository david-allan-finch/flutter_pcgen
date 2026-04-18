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
