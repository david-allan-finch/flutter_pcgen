// Standard spell component types.
enum Component {
  verbal('V', 'Spell.Components.Verbal'),
  somatic('S', 'Spell.Components.Somatic'),
  material('M', 'Spell.Components.Material'),
  divineFocus('DF', 'Spell.Components.DivineFocus'),
  focus('F', 'Spell.Components.Focus'),
  experience('XP', 'Spell.Components.Experience'),
  other('See text', 'Spell.Components.SeeText');

  final String key;
  final String nameKey;

  const Component(this.key, this.nameKey);

  String getKey() => key;

  static Component getComponentFromKey(String aKey) {
    for (final c in Component.values) {
      if (c.key.toLowerCase() == aKey.toLowerCase()) return c;
    }
    return Component.other;
  }

  @override
  String toString() => nameKey;
}
