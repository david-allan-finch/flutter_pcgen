// Translation of pcgen.persistence.lst.SizeAdjustmentLoader

import '../../core/size_adjustment.dart';
import '../../rules/context/load_context.dart';
import 'lst_line_file_loader.dart';

/// Loads SizeAdjustment objects from a size.lst game mode file.
///
/// In Java this extends LstLineFileLoader. Each line defines one size category.
/// The first tab-column is the size name/key; the rest are TOKEN:value pairs.
class SizeAdjustmentLoader extends LstLineFileLoader {
  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    final fields = lstLine.split('\t');
    if (fields.isEmpty) return;

    final name = fields[0].trim();
    if (name.isEmpty) return;

    final size = SizeAdjustment();
    size.setName(name);
    size.setSourceURI(sourceUri.toString());

    if (context is LoadContext) {
      context.getReferenceContext().register(size);
    }

    // Apply remaining tokens
    for (int i = 1; i < fields.length; i++) {
      final tok = fields[i].trim();
      if (tok.isEmpty) continue;
      // TODO: dispatch via TokenStore
    }
  }
}
