import '../pc_stat.dart';

// Records a stat modification that occurred at a specific level.
final class PCLevelInfoStat {
  final PCStat stat;
  int mod;

  PCLevelInfoStat(this.stat, this.mod);

  void modifyStat(int argMod) { mod += argMod; }

  @override
  String toString() => '${stat.getKeyName()}=$mod';
}
