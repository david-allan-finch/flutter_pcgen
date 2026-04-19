// Translation of pcgen.persistence.lst.CompanionModLoader

import '../../core/character/companion_mod.dart';
import '../../rules/context/load_context.dart';
import 'simple_loader.dart';
import 'source_entry.dart';

/// Loads CompanionMod objects from LST files.
///
/// Extends SimpleLoader<CompanionMod> in Java. The first token on each line
/// is "FOLLOWER:<class>=<level>" or similar; the remainder are TOKEN:value pairs.
class CompanionModLoader extends SimpleLoader<CompanionMod> {
  CompanionModLoader() : super(CompanionMod);

  @override
  CompanionMod? getLoadable(dynamic context, String firstToken, Uri sourceUri) {
    // The first token is the class/level specification for the companion mod
    // e.g. "Sorcerer=1" or "Familiar=1"
    final mod = CompanionMod();
    mod.setName(firstToken);
    mod.setSourceURI(sourceUri.toString());
    if (context is LoadContext) {
      context.getReferenceContext().register(mod);
    }
    return mod;
  }
}
