// Copyright (c) Thomas Parker, 2009.
//
// Translation of pcgen.cdom.facet.SpellBookFacet

import '../enumeration/char_id.dart';
import '../../core/character/spell_book.dart';
import '../../core/equipment.dart';
import 'base/abstract_storage_facet.dart';
import 'equipment_facet.dart';
import 'event/data_facet_change_event.dart';
import 'event/data_facet_change_listener.dart';

/// Tracks [SpellBook] objects for a Player Character, keyed by name.
class SpellBookFacet extends AbstractStorageFacet<CharID>
    implements DataFacetChangeListener<CharID, Equipment> {
  late EquipmentFacet equipmentFacet;

  static const String _typeSpellBook = 'SPELLBOOK';

  @override
  void dataAdded(DataFacetChangeEvent<CharID, Equipment> dfce) {
    final eq = dfce.getCDOMObject();
    if (eq.isType(_typeSpellBook)) {
      final id = dfce.getCharID();
      final baseBookname = eq.getName();
      final qty = eq.qty().toInt();
      for (int i = 0; i < qty; i++) {
        final bookName = i > 0 ? '$baseBookname #${i + 1}' : baseBookname;
        var book = getBookNamed(id, bookName);
        if (book == null) {
          book = SpellBook(bookName, SpellBook.typeSpellBook);
        }
        book.setEquip(eq);
        if (!containsBookNamed(id, book.getName())) {
          add(id, book);
        }
      }
    }
  }

  @override
  void dataRemoved(DataFacetChangeEvent<CharID, Equipment> dfce) {
    // Nothing for now — TODO: make symmetric with dataAdded
  }

  void add(CharID id, SpellBook sb) {
    (_getConstructingMap(id))[sb.getName()] = sb;
  }

  void addAll(CharID id, Iterable<SpellBook> list) {
    for (final sb in list) {
      add(id, sb);
    }
  }

  void removeAll(CharID id) {
    removeCache(id);
  }

  SpellBook? getBookNamed(CharID id, String name) =>
      _getCachedMap(id)?[name];

  bool containsBookNamed(CharID id, String name) =>
      _getCachedMap(id)?.containsKey(name) ?? false;

  Iterable<String> getBookNames(CharID id) =>
      _getCachedMap(id)?.keys ?? const [];

  Iterable<SpellBook> getBooks(CharID id) =>
      _getCachedMap(id)?.values ?? const [];

  @override
  void copyContents(CharID source, CharID copy) {
    final map = _getCachedMap(source);
    if (map != null) {
      _getConstructingMap(copy).addAll(map);
    }
  }

  Map<String, SpellBook>? _getCachedMap(CharID id) =>
      getCache(id) as Map<String, SpellBook>?;

  Map<String, SpellBook> _getConstructingMap(CharID id) {
    var map = _getCachedMap(id);
    if (map == null) {
      map = {};
      setCache(id, map);
    }
    return map;
  }

  void init() {
    equipmentFacet.addDataFacetChangeListener(this);
  }
}
