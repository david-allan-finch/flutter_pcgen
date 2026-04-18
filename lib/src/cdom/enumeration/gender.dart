// Represents genders available in PCGen.
enum Gender {
  male,
  female,
  neuter,
  host,
  unknown;

  static Gender getDefaultValue() => Gender.male;

  static Gender getGenderByName(String name) {
    for (final gender in values) {
      if (gender.name.toLowerCase() == name.toLowerCase()) return gender;
    }
    // Legacy fallback: try display name match (Male, Female, etc.)
    return values.firstWhere(
      (g) => g.name.toLowerCase() == name.toLowerCase(),
      orElse: () => Gender.unknown,
    );
  }

  String getDisplayName() {
    return name[0].toUpperCase() + name.substring(1);
  }
}
