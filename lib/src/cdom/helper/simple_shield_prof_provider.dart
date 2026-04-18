import '../../core/shield_prof.dart';
import 'abstract_simple_prof_provider.dart';

// A SimpleShieldProfProvider grants proficiency for a single ShieldProf, and
// also provides equipment-level resolution via getShieldProf().
class SimpleShieldProfProvider extends AbstractSimpleProfProvider<ShieldProf> {
  SimpleShieldProfProvider(ShieldProf proficiency) : super(proficiency);

  // Returns true if the equipment's shield proficiency matches this provider.
  @override
  bool providesProficiencyFor(dynamic equipment) {
    return providesProficiency(equipment.getShieldProf() as ShieldProf);
  }

  @override
  int get hashCode => getLstFormat().hashCode;

  @override
  bool operator ==(Object o) =>
      identical(this, o) ||
      (o is SimpleShieldProfProvider && hasSameProf(o));
}
