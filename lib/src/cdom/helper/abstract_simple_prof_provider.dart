import '../base/cdom_object.dart';
import 'prof_provider.dart';

// An AbstractSimpleProfProvider grants proficiency based on a single
// proficiency object. It never grants proficiency by Equipment TYPE and
// always qualifies (it never contains prerequisites).
abstract class AbstractSimpleProfProvider<T extends CDOMObject>
    implements ProfProvider<T> {
  final T _prof;

  AbstractSimpleProfProvider(T proficiency) : _prof = proficiency;

  // Returns true only if the given proficiency equals the stored one.
  @override
  bool providesProficiency(T proficiency) => _prof == proficiency;

  // Always returns true; this provider has no prerequisites.
  @override
  bool qualifies(dynamic playerCharacter, Object? owner) => true;

  // Always returns false; this provider never grants type-based proficiency.
  @override
  bool providesEquipmentType(String type) => false;

  // Returns the key name of the single proficiency as the LST format.
  @override
  String getLstFormat() => _prof.getKeyName() ?? '';

  // Returns true if both providers hold the same underlying proficiency.
  bool hasSameProf(AbstractSimpleProfProvider<T> aspp) =>
      _prof == aspp._prof;
}
