import '../../core/armor_prof.dart';
import 'abstract_simple_prof_provider.dart';

// A SimpleArmorProfProvider grants proficiency for a single ArmorProf, and
// also provides equipment-level resolution via getArmorProf().
class SimpleArmorProfProvider extends AbstractSimpleProfProvider<ArmorProf> {
  SimpleArmorProfProvider(ArmorProf proficiency) : super(proficiency);

  // Returns true if the equipment's armor proficiency matches this provider.
  @override
  bool providesProficiencyFor(dynamic equipment) {
    return providesProficiency(equipment.getArmorProf() as ArmorProf);
  }

  @override
  int get hashCode => getLstFormat().hashCode;

  @override
  bool operator ==(Object o) =>
      identical(this, o) ||
      (o is SimpleArmorProfProvider && hasSameProf(o));
}
