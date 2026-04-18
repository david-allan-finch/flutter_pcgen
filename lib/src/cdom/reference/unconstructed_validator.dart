import '../base/class_identity.dart';

// Indicates what behaviors are allowed for a given class/ClassIdentity,
// such as unconstructed references and duplicates.
abstract interface class UnconstructedValidator {
  // Returns true if the given class allows duplicate objects to exist.
  bool allowDuplicates(Type objClass);

  // Returns true if the given key for the given ClassIdentity is allowed to
  // remain unconstructed.
  bool allowUnconstructed(ClassIdentity<dynamic> identity, String key);
}
