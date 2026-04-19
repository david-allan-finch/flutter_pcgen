// Translation of pcgen.persistence.lst.FeatLoader

import '../../core/ability.dart';
import '../../core/ability_category.dart';
import '../../rules/context/load_context.dart';
import 'ability_loader.dart';
import 'source_entry.dart';

/// Loads Feat objects from LST files.
///
/// FeatLoader extends AbilityLoader in Java. Feats are Ability objects whose
/// category defaults to FEAT if no CATEGORY: token is present.
class FeatLoader extends AbilityLoader {
  static final AbilityCategory _featCategory =
      AbilityCategory.getCategory('FEAT') ?? AbilityCategory('FEAT');

  @override
  Ability? parseLine(
      LoadContext context, Ability? ability, String lstLine, SourceEntry source) {
    // Inject a default CATEGORY:FEAT before delegating
    if (!lstLine.contains('CATEGORY:')) {
      lstLine = lstLine.contains('\t')
          ? lstLine.replaceFirst('\t', '\tCATEGORY:FEAT\t')
          : '$lstLine\tCATEGORY:FEAT';
    }
    return super.parseLine(context, ability, lstLine, source);
  }
}
