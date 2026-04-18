import '../race.dart';

// Represents a companion/familiar/mount linked to a PlayerCharacter.
final class Follower implements Comparable<Object> {
  String fileName;
  String name;
  Race? race;
  String type; // CompanionList name (e.g. "Familiar", "Mount", "Follower")
  int usedHD = 0;
  int adjustment = 0;

  Follower(this.fileName, this.name, this.type);

  @override
  int compareTo(Object obj) {
    final aF = obj as Follower;
    return fileName.compareTo(aF.fileName);
  }

  @override
  String toString() => name;

  Follower clone() => Follower(fileName, name, type)
    ..race = race
    ..usedHD = usedHD
    ..adjustment = adjustment;
}
