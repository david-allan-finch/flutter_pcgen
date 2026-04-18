import '../choiceset/collection_to_ability_selection.dart';
import '../content/ability_selection.dart';
import 'basic_choose_information.dart';

// CategorizedAbilitySelectionChooseInformation extends BasicChooseInformation
// to add awareness of an AbilityCategory for ability selection choices.
class CategorizedAbilitySelectionChooseInformation
    extends BasicChooseInformation<AbilitySelection> {
  final CollectionToAbilitySelection _casChoiceSet;

  CategorizedAbilitySelectionChooseInformation(
      String name, CollectionToAbilitySelection choice)
      : _casChoiceSet = choice,
        super(name, choice, choice.getCategory().getPersistentFormat());

  dynamic getCategory() => _casChoiceSet.getCategory();
}
