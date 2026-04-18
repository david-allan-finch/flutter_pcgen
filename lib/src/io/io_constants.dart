// Translation of pcgen.io.IOConstants

/// Constants used in PCG character file I/O.
class IOConstants {
  static const String tagVersion = 'VERSION';
  static const String tagName = 'NAME';
  static const String tagRace = 'RACE';
  static const String tagClass = 'CLASS';
  static const String tagStats = 'STATS';
  static const String tagSkills = 'SKILLS';
  static const String tagFeats = 'FEATS';
  static const String tagEquipment = 'EQUIPMENT';
  static const String tagNotes = 'NOTES';
  static const String tagEol = '\n';
  static const String tagSep = '|';
  static const String tagAssign = ':';
  static const String notesBegin = 'NOTES:BEGIN';
  static const String notesEnd = 'NOTES:END';

  IOConstants._();
}
