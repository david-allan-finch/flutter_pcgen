// Controls which skills are shown on an output sheet.
enum SkillFilter {
  ranks(0, 'RANKS', 'Skills with Ranks'),
  nonDefault(1, 'NONDEFAULT', 'Non-Default'),
  usable(2, 'USABLE', 'Usable'),
  all(3, 'ALL', 'All Skills'),
  // Deprecated: retained for compatibility with saved characters.
  skillsTab(4, '', 'Skill Tab'),
  selected(5, 'SELECTED', null);

  final int value;
  final String token;
  final String? text;

  const SkillFilter(this.value, this.token, this.text);

  int getValue() => value;
  String getToken() => token;

  @override
  String toString() => text ?? name;

  static SkillFilter? getByValue(int value) {
    for (final filter in SkillFilter.values) {
      if (filter.value == value) return filter;
    }
    return null;
  }

  static SkillFilter? getByToken(String value) {
    for (final filter in SkillFilter.values) {
      if (filter.token.toLowerCase() == value.toLowerCase()) return filter;
    }
    return null;
  }
}
