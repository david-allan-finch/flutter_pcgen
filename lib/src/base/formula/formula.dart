// A Formula is a mathematical formula which requires a context to resolve.
abstract interface class Formula {
  // Resolves the formula relative to the given PlayerCharacter and source.
  num resolve(dynamic pc, String source);

  // Resolves the static formula (no PC context needed).
  num resolveStatic();

  // Resolves formula for Equipment context.
  num resolveEquipment(dynamic equipment, bool primary, dynamic pc, String source);

  // Returns true if the formula is known to be static.
  bool isStatic();

  // Returns true if the formula is valid.
  bool isValid();
}
