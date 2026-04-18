// Copyright 2010 Tom Parker <thpr@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.AbilityCategoryLoader

import 'lst_line_file_loader.dart';
import 'overlap_loader.dart';

/// Parses ABILITYCATEGORY lines from game-mode miscinfo.lst or campaign LST files.
class AbilityCategoryLoader extends LstLineFileLoader {
  final OverlapLoader<dynamic> _loader = OverlapLoader(dynamic);

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    final colonLoc = lstLine.indexOf(':');
    if (colonLoc <= 0 || colonLoc == lstLine.length - 1) {
      // TODO: log error
      return;
    }
    final key = lstLine.substring(0, colonLoc);
    if (key != 'ABILITYCATEGORY') {
      // TODO: log error
      return;
    }
    _loader.parseLine(context, lstLine.substring(colonLoc + 1), sourceUri);
  }
}
