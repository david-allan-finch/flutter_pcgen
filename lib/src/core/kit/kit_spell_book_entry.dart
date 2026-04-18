// Copyright (c) Aaron Divinsky, 2005.
//
// Translation of pcgen.core.kit.KitSpellBookEntry

/// A single spell entry within a kit spell book, including its book name,
/// spell, optional feat modifiers, and copy count.
class KitSpellBookEntry {
  final String? bookName;
  final dynamic spell;
  final int copies;
  final List<dynamic> modifiers;

  dynamic _pcClass;

  KitSpellBookEntry(this.bookName, this.spell, List<dynamic>? mods, this.copies)
      : modifiers = List.unmodifiable(mods ?? const []);

  String? getBookName() => bookName;
  dynamic getSpell() => spell;
  int getCopies() => copies;
  List<dynamic> getModifiers() => modifiers;

  void setPCClass(dynamic cls) => _pcClass = cls;
  dynamic getPCClass() => _pcClass;

  @override
  String toString() => spell.getDisplayName();
}
