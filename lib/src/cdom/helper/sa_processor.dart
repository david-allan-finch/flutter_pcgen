import '../../core/player_character.dart';
import '../../core/special_ability.dart';

// Processes a SpecialAbility, resolving %CHOICE substitutions from the PC.
class SAProcessor {
  final PlayerCharacter _pc;

  SAProcessor(PlayerCharacter pc) : _pc = pc;

  SpecialAbility act(SpecialAbility sa, Object source) {
    final key = sa.getKeyName();
    final idx = key.indexOf('%CHOICE');
    if (idx == -1) return sa;

    final sb = StringBuffer(key.substring(0, idx));
    if (source is dynamic && _pc.hasAssociations(source)) {
      final assocList = List<String>.from(_pc.getAssociationList(source))..sort();
      sb.write(assocList.join(', '));
    } else {
      sb.write('<undefined>');
    }
    sb.write(key.substring(idx + 7));
    return SpecialAbility(sb.toString(), sa.getSADesc());
  }
}
