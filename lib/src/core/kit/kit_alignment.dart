import '../../cdom/base/cdom_single_ref.dart';
import '../kit.dart';
import '../pc_alignment.dart';
import '../player_character.dart';
import 'base_kit.dart';

class KitAlignment extends BaseKit {
  List<CDOMSingleRef<PCAlignment>>? _alignments;
  PCAlignment? _align;

  void addAlignment(CDOMSingleRef<PCAlignment> ref) {
    _alignments ??= [];
    _alignments!.add(ref);
  }

  List<CDOMSingleRef<PCAlignment>>? getAlignments() => _alignments;

  @override
  void apply(PlayerCharacter aPC) {
    if (_align != null) aPC.setAlignment(_align!);
  }

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    _align = null;
    final alignments = _alignments;
    if (alignments == null || alignments.isEmpty) return false;

    if (alignments.length == 1) {
      _align = alignments[0].get();
    } else {
      // Multiple options: pick the first valid one (UI chooser not available)
      _align = alignments[0].get();
    }
    apply(aPC);
    return aPC.canBeAlignment(_align!);
  }

  @override
  String getObjectName() => 'Alignment';

  @override
  String toString() {
    final alignments = _alignments;
    if (alignments == null || alignments.isEmpty) return '';
    if (alignments.length == 1) return alignments[0].get().getDisplayName();
    final names = alignments.map((r) => r.get().getDisplayName()).join(', ');
    return 'One of ($names)';
  }
}
