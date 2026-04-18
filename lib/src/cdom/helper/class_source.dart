import '../base/identified.dart';
import '../../core/pc_class.dart';

// Associates a PCClass with a caster level for domain source tracking.
class ClassSource implements Identified {
  final PCClass pcclass;
  final int level;

  ClassSource(this.pcclass, [this.level = -1]);

  @override
  String getKeyName() => '${pcclass.getFullKey()} $level';

  @override
  String? getDisplayName() => '${pcclass.getDisplayName()} $level';

  @override
  int get hashCode => pcclass.hashCode - level;

  @override
  bool operator ==(Object o) =>
      o is ClassSource && level == o.level && pcclass == o.pcclass;

  @override
  String toString() => 'ClassSource: ${getDisplayName()}';
}
