// Translation of pcgen.persistence.lst.GlobalModifierLoader

import '../../rules/context/load_context.dart';
import 'lst_line_file_loader.dart';

/// Loads global modifier definitions from a globalmodifier.lst file.
///
/// Each line must be a single TOKEN:value (no tabs allowed per Java impl).
/// The tokens are applied to a singleton "Global Modifiers" object in the
/// reference context.
class GlobalModifierLoader extends LstLineFileLoader {
  static const String globalModifiersName = 'Global Modifiers';

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    // GlobalModifier lines must not contain tabs
    if (lstLine.contains('\t')) {
      // errorPrint: tabs not allowed in global modifier file
      return;
    }

    final tok = lstLine.trim();
    final colonIdx = tok.indexOf(':');
    if (colonIdx <= 0) {
      // errorPrint: missing or leading colon
      return;
    }

    if (context is LoadContext) {
      // TODO: obtain GlobalModifiers object from context.getReferenceContext()
      //       and dispatch token via LstUtils.processToken
    }
  }
}
