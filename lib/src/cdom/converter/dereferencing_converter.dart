import '../../core/player_character.dart';

// A Converter that resolves an ObjectContainer to its contained objects,
// optionally filtered by a PrimitiveFilter.
class DereferencingConverter<T> {
  final PlayerCharacter _character;

  DereferencingConverter(PlayerCharacter pc) : _character = pc;

  List<T> convert(dynamic orig) =>
      List<T>.from(orig.getContainedObjects());

  Set<T> convertWithFilter(dynamic orig, dynamic lim) => Set<T>.from(
      (orig.getContainedObjects() as Iterable<T>)
          .where((o) => lim.allow(_character, o)));
}
