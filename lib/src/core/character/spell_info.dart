import '../ability.dart';
import '../globals.dart';
import 'character_spell.dart';

// Helper class for CharacterSpell — stores book, level, times, and metamagic feats.
final class SpellInfo implements Comparable<SpellInfo> {
  static const int timesAtWill = -1;

  final CharacterSpell _owner;
  List<Ability>? featList;
  final String book;
  final int origLevel;
  final int actualLevel;
  int times;
  String? timeUnit;
  int actualPPCost = -1;
  int numPages = 0;
  String? fixedDC;

  SpellInfo(this._owner, this.origLevel, this.actualLevel, this.times, String? book)
      : book = book ?? Globals.getDefaultSpellBook();

  CharacterSpell getOwner() => _owner;

  void addFeatsToList(List<Ability> feats) {
    featList ??= [];
    featList!.addAll(feats);
  }

  @override
  int compareTo(SpellInfo other) {
    int compare = book.compareTo(other.book);
    if (compare == 0) compare = origLevel.compareTo(other.origLevel);
    if (compare == 0) compare = actualLevel.compareTo(other.actualLevel);
    if (compare == 0) compare = times.compareTo(other.times);
    if (compare == 0) {
      final tu = timeUnit;
      final otu = other.timeUnit;
      if (tu == null && otu != null) compare = -1;
      else if (tu != null && otu == null) compare = 1;
      else if (tu != null && otu != null) compare = tu.compareTo(otu);
    }
    if (compare == 0) compare = actualPPCost.compareTo(other.actualPPCost);
    if (compare == 0) compare = numPages.compareTo(other.numPages);
    if (compare == 0) {
      final fd = fixedDC;
      final ofd = other.fixedDC;
      if (fd == null && ofd != null) compare = -1;
      else if (fd != null && ofd == null) compare = 1;
      else if (fd != null && ofd != null) compare = fd.compareTo(ofd);
    }
    if (compare == 0) {
      final fl = featList;
      final ofl = other.featList;
      if (fl == null && ofl != null) compare = -1;
      else if (fl != null && ofl == null) compare = 1;
      else if (fl != null && ofl != null) {
        compare = fl.length.compareTo(ofl.length);
        if (compare == 0) {
          for (int i = 0; i < fl.length; i++) {
            compare = fl[i].compareTo(ofl[i]);
            if (compare != 0) break;
          }
        }
      }
    }
    return compare;
  }

  @override
  String toString() {
    final fl = featList;
    if (fl == null || fl.isEmpty) return '';
    final buf = StringBuffer(' [${fl[0]}');
    for (int i = 1; i < fl.length; i++) {
      buf.write(', ${fl[i]}');
    }
    buf.write('] ');
    return buf.toString();
  }
}
