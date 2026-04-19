// Translation of pcgen.persistence.lst.KitLoader

import '../../core/kit.dart';
import '../../rules/context/load_context.dart';
import 'lst_object_file_loader.dart';
import 'source_entry.dart';

/// Loads Kit objects from LST files.
///
/// KitLoader extends LstObjectFileLoader<Kit> in Java.
class KitLoader extends LstObjectFileLoader<Kit> {
  @override
  Kit? parseLine(LoadContext context, Kit? kit, String lstLine, SourceEntry source) {
    final fields = lstLine.split('\t');
    if (fields.isEmpty) return null;

    final firstName = fields[0].trim();
    if (firstName.isEmpty) return null;

    final currentKit = kit ?? Kit();
    if (kit == null) {
      currentKit.setName(firstName);
      currentKit.setSourceURI(source.getURI().toString());
      context.getReferenceContext().register(currentKit);
    }

    // Process remaining token:value pairs
    for (int i = 1; i < fields.length; i++) {
      final token = fields[i].trim();
      if (token.isEmpty) continue;
      // TODO: dispatch token via TokenStore / LstUtils.processToken
    }

    return currentKit;
  }

  @override
  Kit? getObjectKeyed(LoadContext context, String key) {
    return context.getReferenceContext()
        .getAllConstructed<Kit>(Kit)
        .cast<Kit?>()
        .firstWhere((k) => k?.getKeyName() == key, orElse: () => null);
  }
}
