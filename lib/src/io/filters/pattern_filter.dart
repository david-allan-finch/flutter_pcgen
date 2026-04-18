// Translation of pcgen.io.filters.PatternFilter

import '../../core/player_character.dart';
import 'output_filter.dart';

/// Filters characters by matching a regex pattern against some string property.
class PatternFilter implements OutputFilter {
  final RegExp _pattern;

  PatternFilter(String pattern) : _pattern = RegExp(pattern);

  @override
  bool accept(PlayerCharacter pc) =>
      _pattern.hasMatch(pc.getName());
}
