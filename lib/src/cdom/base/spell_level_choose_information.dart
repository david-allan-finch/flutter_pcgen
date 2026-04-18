import '../../core/player_character.dart';
import '../enumeration/grouping_state.dart';
import '../helper/spell_level.dart';
import '../helper/spell_level_info.dart';
import 'choose_driver.dart';
import 'choose_information.dart';
import 'choose_information_utilities.dart';
import 'chooser.dart';
import 'constants.dart';

// ChooseInformation for spell-level selections.
class SpellLevelChooseInformation implements ChooseInformation<SpellLevel> {
  final List<SpellLevelInfo> info;
  final String setName;
  String? title;
  Chooser<SpellLevel>? choiceActor;

  SpellLevelChooseInformation(String name, List<SpellLevelInfo> choice)
      : setName = name,
        info = List.from(choice) {
    if (info.isEmpty) {
      throw ArgumentError('PrimitiveChoiceSet cannot be empty');
    }
  }

  @override
  void setChoiceActor(Chooser<SpellLevel> actor) => choiceActor = actor;

  @override
  Chooser<SpellLevel>? getChoiceActor() => choiceActor;

  @override
  String encodeChoice(SpellLevel choice) => choiceActor!.encodeChoice(choice);

  @override
  SpellLevel? decodeChoice(dynamic context, String persistenceFormat) =>
      choiceActor?.decodeChoice(context, persistenceFormat);

  @override
  List<SpellLevel> getSet(PlayerCharacter pc) {
    final set = <SpellLevel>{};
    for (final sli in info) {
      set.addAll(sli.getLevels(pc));
    }
    return set.toList();
  }

  @override
  String getName() => setName;

  @override
  String getTitle() => title ?? setName;

  void setTitleStr(String choiceTitle) => title = choiceTitle;

  @override
  String getLSTformat() => info.join(Constants.pipe);

  @override
  GroupingState getGroupingState() => GroupingState.allowsNone;

  @override
  void restoreChoice(PlayerCharacter pc, ChooseDriver owner, SpellLevel choice) =>
      choiceActor?.restoreChoice(pc, owner, choice);

  @override
  void removeChoice(PlayerCharacter pc, ChooseDriver owner, SpellLevel choice) =>
      choiceActor?.removeChoice(pc, owner, choice);

  @override
  dynamic getChoiceManager(ChooseDriver owner, int cost) =>
      null; // CDOMChoiceManager stub

  @override
  String composeDisplay(List<dynamic> collection) =>
      ChooseInformationUtilities.buildEncodedString(collection);

  @override
  String getPersistentFormat() => 'INVALID*NOT*PERSISTENT*';

  @override
  int get hashCode => setName.hashCode + 29;

  @override
  bool operator ==(Object obj) {
    if (obj is SpellLevelChooseInformation) {
      if (title != obj.title) return false;
      return setName == obj.setName && info == obj.info;
    }
    return false;
  }
}
