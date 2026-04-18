import '../../cdom/base/cdom_object.dart';
import '../../cdom/enumeration/object_key.dart';
import '../../rules/context/load_context.dart';
import 'lst_object_file_loader.dart';
import 'source_entry.dart';

// Generic loader for CDOMObjects — creates an instance via [factory] then applies LST tokens.
class GenericLoader<T extends CDOMObject> extends LstObjectFileLoader<T> {
  final T Function() factory;
  final List<Function(LoadContext, T, String, SourceEntry)> _tokenHandlers = [];

  GenericLoader(this.factory);

  void addTokenHandler(Function(LoadContext, T, String, SourceEntry) handler) {
    _tokenHandlers.add(handler);
  }

  @override
  T? parseLine(LoadContext context, T? object, String lstLine, SourceEntry source) {
    final bool isNew = object == null;
    final T po = isNew ? factory() : object;

    final fields = lstLine.split('\t');
    if (fields.isEmpty) return null;

    po.setName(fields[0]);
    po.put(ObjectKey.sourceCampaign, source.getCampaign());
    po.setSourceURI(source.getURI());

    if (isNew) {
      context.getReferenceContext().register(po);
    }

    for (int i = 1; i < fields.length; i++) {
      _processToken(context, po, source, fields[i]);
    }

    completeObject(context, source, po);
    return null; // one line per object
  }

  void _processToken(LoadContext context, T obj, SourceEntry source, String token) {
    if (token.trim().isEmpty) return;
    for (final handler in _tokenHandlers) {
      handler(context, obj, token, source);
    }
  }

  @override
  T? getObjectKeyed(LoadContext context, String key) {
    return context.getReferenceContext().getAllConstructed<T>(T).cast<T?>().firstWhere(
      (o) => o?.getKeyName() == key,
      orElse: () => null,
    );
  }
}
