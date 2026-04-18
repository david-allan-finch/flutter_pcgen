// Translation of pcgen.io.filters.CharacterFilter

import '../../core/player_character.dart';
import 'output_filter.dart';

/// Filters characters based on a predicate function.
class CharacterFilter implements OutputFilter {
  final bool Function(PlayerCharacter) _predicate;

  CharacterFilter(this._predicate);

  @override
  bool accept(PlayerCharacter pc) => _predicate(pc);
}
