// Type-safe enumeration of legal String characteristics of a PC.
enum PCStringKey {
  assets, bio, birthplace, birthday, catchphrase, city, companions,
  description, eyeColor, gmNotes, handed, interests, location, magic,
  name, personality1, personality2, phobias, playersName, residence,
  speechTendency, tabName,
  // Internal keys
  fileName, portraitPath, spellBookAutoAddKnown, currentEquipSetName;

  static PCStringKey getStringKey(String s) {
    return PCStringKey.values.firstWhere(
      (e) => e.name.toUpperCase() == s.toUpperCase(),
      orElse: () => throw ArgumentError('Unknown PCStringKey: $s'),
    );
  }
}
