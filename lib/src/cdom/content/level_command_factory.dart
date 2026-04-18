import '../../core/pc_class.dart';
import '../base/concrete_prereq_object.dart';
import '../base/cdom_single_ref.dart';

// Identifies a PCClass to be applied with a given number of levels to a PC.
class LevelCommandFactory extends ConcretePrereqObject implements Comparable<LevelCommandFactory> {
  final CDOMSingleRef<PCClass> pcClassRef;
  final String levels; // formula string

  LevelCommandFactory(this.pcClassRef, this.levels);

  String getLevelCount() => levels;
  PCClass getPCClass() => pcClassRef.get();
  String getLSTformat() => pcClassRef.getLSTformat(false);

  @override
  int get hashCode => pcClassRef.hashCode * 29 + levels.hashCode;

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is! LevelCommandFactory) return false;
    return levels == obj.levels && pcClassRef == obj.pcClassRef;
  }

  @override
  int compareTo(LevelCommandFactory other) {
    final cr = pcClassRef.getLSTformat(false).compareTo(other.pcClassRef.getLSTformat(false));
    if (cr != 0) return cr;
    return levels.compareTo(other.levels);
  }
}
