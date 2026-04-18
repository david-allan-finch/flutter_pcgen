// Represents the handedness options available in PCGen.
enum Handed {
  right,
  left,
  ambidextrous,
  none,
  other;

  @override
  String toString() {
    switch (this) {
      case Handed.right: return 'Right';
      case Handed.left: return 'Left';
      case Handed.ambidextrous: return 'Both';
      case Handed.none: return 'None';
      case Handed.other: return 'Other';
    }
  }
}
