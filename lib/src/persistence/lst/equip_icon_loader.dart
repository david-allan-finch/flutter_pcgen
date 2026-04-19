// Translation of pcgen.persistence.lst.EquipIconLoader

import 'lst_line_file_loader.dart';

/// Loads equipment icon path mappings from equipicon .lst files.
///
/// Each line maps an equipment type/name to an icon file path.
/// Used only for GUI display; no runtime effect.
class EquipIconLoader extends LstLineFileLoader {
  // icon type → icon path map (game mode specific)
  final Map<String, String> _iconMap = {};

  Map<String, String> get iconMap => Map.unmodifiable(_iconMap);

  @override
  void parseLine(dynamic context, String lstLine, Uri sourceUri) {
    if (lstLine.isEmpty || lstLine.startsWith('#')) return;

    final cols = lstLine.split('\t');
    if (cols.isEmpty) return;

    final firstToken = cols[0].trim();
    final colonIdx = firstToken.indexOf(':');
    if (colonIdx <= 0) return;

    final key = firstToken.substring(0, colonIdx).trim();
    final value = firstToken.substring(colonIdx + 1).trim();
    if (key.isEmpty || value.isEmpty) return;

    _iconMap[key] = value;
  }
}
