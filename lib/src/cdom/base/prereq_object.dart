import '../prereq/prerequisite.dart';

// An object that contains a list of Prerequisites.
abstract interface class PrereqObject {
  void addPrerequisite(Prerequisite prereq);
  void addAllPrerequisites(Iterable<Prerequisite> prereqs);
  bool hasPrerequisites();
  List<Prerequisite> getPrerequisiteList();
  void clearPrerequisiteList();
  int getPrerequisiteCount();
  bool isAvailable(dynamic aPC);
  bool isActive(dynamic aPC);
}
