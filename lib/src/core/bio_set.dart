// Bio data sets for age/height/weight randomization by race.
class BioSet {
  final Map<String, Map<String, List<String>>> _ageMap = {};

  void addToMap(String region, String race, String tag, String value) {
    _ageMap
        .putIfAbsent(region, () => {})
        .putIfAbsent(race, () => [])
        .add(value);
  }

  List<String> getTagForRace(String region, String race) {
    return _ageMap[region]?[race] ?? [];
  }
}
