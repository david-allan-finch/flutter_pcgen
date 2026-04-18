import '../../../cdom/base/choose_information.dart';
import '../../../cdom/enumeration/object_key.dart';
import '../../player_character.dart';
import '../../skill.dart';
import 'output_name_formatting.dart';

// Produces qualified display names for Abilities and Skills (with sub-choices).
final class QualifiedName {
  QualifiedName._();

  static String qualifiedNameForAbilities(dynamic pc, List<dynamic> list) {
    // dynamic = PlayerCharacter, list = List<CNAbility>
    final a = _validateCNAList(list);
    if (a == null) return '';
    final outputName = OutputNameFormatting.getOutputName(a);
    if ('[BASE]'.toLowerCase() == outputName.toLowerCase()) {
      return a.getDisplayName();
    }
    final buf = StringBuffer(outputName);
    final chooseInfo = a.get(ObjectKey.chooseInfo) as ChooseInformation?;
    if (chooseInfo != null) {
      _processChooseInfo(buf, pc, chooseInfo, list);
    }
    return buf.toString();
  }

  static void _processChooseInfo(
      StringBuffer buf, dynamic pc, ChooseInformation chooseInfo, List<dynamic> list) {
    final allSelections = [];
    for (final cna in list) {
      if (pc.hasAssociations(cna)) {
        allSelections.addAll(pc.getDetailedAssociations(cna));
      }
    }
    final choiceInfo = chooseInfo.composeDisplay(allSelections).toString();
    if (choiceInfo.isNotEmpty) {
      buf.write(' (');
      buf.write(choiceInfo);
      buf.write(')');
    }
  }

  static String qualifiedNameForSkill(dynamic pc, Skill s) {
    final outputName = OutputNameFormatting.getOutputName(s);
    if (!pc.hasAssociations(s)) return outputName;

    final assocList = List<String>.from(pc.getAssociationList(s))..sort();
    return '$outputName(${assocList.join(', ')})';
  }

  static dynamic _validateCNAList(List<dynamic> list) =>
      list.isEmpty ? null : list.first.getAbility();
}
