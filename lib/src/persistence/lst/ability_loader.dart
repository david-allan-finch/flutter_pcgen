import '../../core/ability.dart';
import '../../core/ability_category.dart';
import '../../rules/context/load_context.dart';
import 'lst_object_file_loader.dart';
import 'source_entry.dart';

// Loads Ability objects from LST files.
class AbilityLoader extends LstObjectFileLoader<Ability> {
  @override
  Ability? parseLine(LoadContext context, Ability? ability, String lstLine, SourceEntry source) {
    Ability anAbility = ability ?? Ability();
    final bool isNew = ability == null;

    final fields = lstLine.split('\t');
    if (fields.isEmpty) return null;

    anAbility.setName(fields[0]);
    anAbility.setSourceURI(source.getURI());

    String? categoryToken;
    final remaining = <String>[];

    for (int i = 1; i < fields.length; i++) {
      final token = fields[i];
      if (token.startsWith('CATEGORY:')) {
        categoryToken = token.substring(9);
      } else {
        remaining.add(token);
      }
    }

    if (isNew) {
      if (categoryToken != null) {
        final cat = AbilityCategory.getCategory(categoryToken);
        if (cat != null) {
          anAbility.setCategory(cat);
        } else {
          // Invalid category — skip
          return null;
        }
      }
      context.getReferenceContext().register(anAbility);
    }

    // Process remaining tokens (BONUS, PRExxx, TYPE, etc.)
    for (final token in remaining) {
      _processToken(context, anAbility, token, source);
    }

    completeObject(context, source, anAbility);
    return null;
  }

  void _processToken(LoadContext context, Ability obj, String token, SourceEntry source) {
    // Token dispatch would go here in full implementation
  }

  @override
  Ability? getObjectKeyed(LoadContext context, String key) {
    return context.getReferenceContext()
        .getAllConstructed<Ability>(Ability)
        .cast<Ability?>()
        .firstWhere((a) => a?.getKeyName() == key, orElse: () => null);
  }
}
