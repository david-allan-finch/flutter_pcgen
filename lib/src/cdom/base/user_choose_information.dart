import '../../core/player_character.dart';
import '../enumeration/association_list_key.dart';
import '../enumeration/grouping_state.dart';
import 'choose_driver.dart';
import 'choose_information.dart';
import 'choose_information_utilities.dart';
import 'chooser.dart';
import 'choose_selection_actor.dart';

// ChooseInformation that accepts free-text user input.
class UserChooseInformation
    implements ChooseInformation<String>, Chooser<String> {
  static const String uciName = 'User Input';

  String? _title;

  @override
  String getName() => uciName;

  @override
  String getTitle() => _title ?? 'Provide User Input';

  void setTitle(String chooseTitle) => _title = chooseTitle;

  @override
  String getLSTformat() => '*USERINPUT';

  @override
  GroupingState getGroupingState() => GroupingState.allowsNone;

  @override
  List<String> getSet(PlayerCharacter pc) => ['USERINPUT'];

  @override
  String composeDisplay(List<dynamic> collection) =>
      ChooseInformationUtilities.buildEncodedString(collection);

  @override
  void restoreChoice(PlayerCharacter pc, ChooseDriver owner, String choice) =>
      pc.addAssoc(owner, _listKey(), choice);

  @override
  List<String>? getCurrentlySelected(ChooseDriver owner, PlayerCharacter pc) =>
      pc.getAssocList(owner, _listKey());

  @override
  void applyChoice(ChooseDriver owner, String choice, PlayerCharacter pc) {
    restoreChoice(pc, owner, choice);
    final actors = owner.getActors();
    if (actors != null) {
      for (final csa in actors) {
        (csa as ChooseSelectionActor<String>).applyChoice(owner, choice, pc);
      }
    }
  }

  @override
  void removeChoice(PlayerCharacter pc, ChooseDriver owner, String choice) {
    pc.removeAssoc(owner, _listKey(), choice);
    final actors = owner.getActors();
    if (actors != null) {
      for (final csa in actors) {
        (csa as ChooseSelectionActor<String>).removeChoice(owner, choice, pc);
      }
    }
  }

  @override
  Chooser<String> getChoiceActor() => this;

  @override
  void setChoiceActor(Chooser<String> actor) {} // ignored

  @override
  bool allow(String choice, PlayerCharacter pc, bool allowStack) => true;

  @override
  String decodeChoice(dynamic context, String choice) => choice;

  @override
  String encodeChoice(String choice) => choice;

  @override
  dynamic getChoiceManager(ChooseDriver owner, int cost) =>
      null; // UserInputManager stub

  @override
  String getPersistentFormat() => 'STRING';

  @override
  String? encodeChoiceOrNull(String choice) => choice;

  static AssociationListKey<String> _listKey() =>
      AssociationListKey.getKeyFor(String, 'CHOOSE*USERCHOICE');
}
