import '../enumeration/grouping_state.dart';
import '../reference/cdom_single_ref.dart';
import 'categorized.dart';
import 'category.dart';
import 'choose_driver.dart';
import 'choose_information.dart';
import 'chooser.dart';
import 'categorized_chooser.dart';
import 'primitive_choice_set.dart';
import 'choose_information_utilities.dart';

// CategorizedChooseInformation is like BasicChooseInformation but is aware of
// a Category, delegating to CategorizedChooser when decoding.
class CategorizedChooseInformation<T extends Categorized<T>>
    implements ChooseInformation<T> {
  final PrimitiveChoiceSet<T> _pcs;
  final CDOMSingleRef<Category<T>> _category;
  final String _setName;
  String? _title;
  Chooser<T>? _choiceActor;

  CategorizedChooseInformation(
      String name, CDOMSingleRef<Category<T>> cat, PrimitiveChoiceSet<T> choice)
      : _setName = name,
        _category = cat,
        _pcs = choice;

  @override
  void setChoiceActor(dynamic actor) {
    _choiceActor = actor as Chooser<T>;
  }

  @override
  String encodeChoice(T item) => _choiceActor!.encodeChoice(item);

  @override
  T decodeChoice(dynamic context, String persistentFormat) {
    final actor = _choiceActor;
    if (actor is CategorizedChooser<T>) {
      return actor.decodeChoiceWithCategory(context, persistentFormat, _category.get()!);
    }
    return actor!.decodeChoice(context, persistentFormat);
  }

  @override
  dynamic getChoiceActor() => _choiceActor;

  @override
  bool operator ==(Object obj) {
    if (obj is CategorizedChooseInformation) {
      if (_title != obj._title) return false;
      return _setName == obj._setName &&
          _category == obj._category &&
          _pcs == obj._pcs;
    }
    return false;
  }

  @override
  int get hashCode => _setName.hashCode + 29;

  @override
  String getLSTformat() => _pcs.getLSTformat(false);

  @override
  Type getReferenceClass() => _category.get()!.getReferenceClass();

  @override
  List<T> getSet(dynamic pc, [dynamic driver]) {
    return List.unmodifiable(_pcs.getSet(pc));
  }

  @override
  String getName() => _setName;

  void setTitle(String choiceTitle) {
    _title = choiceTitle;
  }

  @override
  String? getTitle() => _title;

  @override
  GroupingState getGroupingState() => _pcs.getGroupingState();

  CDOMSingleRef<Category<T>> getCategory() => _category;

  @override
  void restoreChoice(dynamic pc, dynamic owner, T item) {
    _choiceActor!.restoreChoice(pc, owner as ChooseDriver, item);
  }

  // stub: GUI chooser manager creation
  dynamic getChoiceManager(ChooseDriver owner, int cost) {
    // stub
    return null;
  }

  String composeDisplay(List<T> collection) {
    return ChooseInformationUtilities.buildEncodedString(collection);
  }

  void removeChoice(dynamic pc, ChooseDriver owner, T item) {
    _choiceActor!.removeChoice(pc, owner, item);
  }

  @override
  String getPersistentFormat() => _category.get()!.getPersistentFormat();

  @override
  bool allowsPersistentStorage() => true;
}
