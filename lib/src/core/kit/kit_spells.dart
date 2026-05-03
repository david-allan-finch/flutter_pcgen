// Copyright (c) Greg Bingleman, 2001.
//
// Translation of pcgen.core.kit.KitSpells

import 'package:flutter_pcgen/src/core/kit/base_kit.dart';
import 'package:flutter_pcgen/src/core/kit/kit_spell_book_entry.dart';

/// Applies spells to a character's spell book via a kit.
class KitSpells extends BaseKit {
  String? spellBook;

  /// Reference to the casting PCClass.
  dynamic castingClass;

  /// Map: KnownSpellIdentifier → (modifierList → count).
  /// Using Map<dynamic, Map<List<dynamic>, int>> to mirror Java's DoubleKeyMap.
  final Map<dynamic, Map<List<dynamic>?, int>> spells = {};

  dynamic countFormula;

  List<KitSpellBookEntry>? _theSpells;

  void setCount(dynamic formula) => countFormula = formula;
  dynamic getCount() => countFormula;

  void addSpell(dynamic ksi, List<dynamic>? modifiers, int count) {
    spells.putIfAbsent(ksi, () => {})[modifiers] = count;
  }

  @override
  bool testApply(dynamic aKit, dynamic aPC, List<String> warnings) {
    _theSpells = null;

    final aClass = _findDefaultSpellClass(castingClass, aPC);
    if (aClass == null) {
      warnings.add('SPELLS: Character does not have $castingClass spellcasting class.');
      return false;
    }

    final workingBook = spellBook ?? _defaultSpellBook(aPC);
    if (!aClass.getSafeObject(CDOMObjectKey.getConstant('MEMORIZE_SPELLS')) &&
        workingBook != _defaultSpellBook(aPC)) {
      warnings.add('SPELLS: ${aClass.getDisplayName()} can only add to ${_defaultSpellBook(aPC)}');
      return false;
    }

    final aSpellList = <KitSpellBookEntry>[];
    for (final ksi in spells.keys) {
      final contained = ksi.getContainedSpells(
          aPC, [aClass.get('CLASS_SPELLLIST')]);
      final feats = spells[ksi]!;
      for (final sp in contained) {
        for (final entry in feats.entries) {
          aSpellList.add(KitSpellBookEntry(spellBook, sp, entry.key, entry.value));
        }
      }
    }

    // Handle count formula / chooser limiting
    final choiceFormula = getCount();
    int numberOfChoices = choiceFormula != null
        ? (choiceFormula.resolve(aPC, '').toInt())
        : aSpellList.length;

    if (numberOfChoices > aSpellList.length) {
      numberOfChoices = aSpellList.length;
    }

    // TODO: chooser UI for kits — for now take all up to the limit
    _theSpells = aSpellList.take(numberOfChoices).toList();
    return _theSpells!.isNotEmpty;
  }

  @override
  void apply(dynamic aPC) {
    if (_theSpells == null) return;
    for (final entry in _theSpells!) {
      final spell = entry.getSpell();
      final book = entry.getBookName() ?? _defaultSpellBook(aPC);
      // TODO: aPC.addSpellBook / addSpell
      aPC.addSpell(spell, entry.getModifiers(), entry.getPCClass(), book,
          entry.getCopies(), entry.getCopies());
    }
  }

  @override
  String getObjectName() => 'Spells';

  @override
  String toString() {
    final buf = StringBuffer();
    if (castingClass != null) buf.write(castingClass.getLSTformat(false));
    buf.write(' ');
    buf.write(spellBook ?? '');
    buf.write(': ');
    bool needComma = false;
    for (final entry in spells.entries) {
      if (needComma) buf.write(',');
      needComma = true;
      buf.write(entry.key.getLSTformat());
      for (final fe in entry.value.entries) {
        if (fe.key != null) {
          buf.write(' [');
          buf.write(fe.key!.map((r) => r.getLSTformat(false)).join(','));
          buf.write(']');
        }
        if (fe.value > 1) buf.write(' (${fe.value})');
      }
    }
    return buf.toString();
  }
}

dynamic _findDefaultSpellClass(dynamic castingClass, dynamic aPC) {
  if (castingClass == null) {
    // Find first spellcasting class on the character
    for (final cls in aPC.getClassList()) {
      if (cls.get('CLASS_SPELLLIST') != null) return cls;
    }
    return null;
  }
  final cls = castingClass.get();
  return aPC.getClassKeyed(cls.getKeyName());
}

String _defaultSpellBook(dynamic aPC) => 'Known Spells';
