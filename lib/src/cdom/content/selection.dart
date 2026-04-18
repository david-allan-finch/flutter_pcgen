import '../base/cdom_object.dart';

// Generic container pairing a CDOMObject with an optional selection string.
class Selection<BT extends CdomObject, SEL> {
  final BT _base;
  final SEL? _selection;

  Selection(BT obj, SEL? sel)
      : _base = obj,
        _selection = sel;

  BT getObject() => _base;
  SEL? getSelection() => _selection;

  @override
  bool operator ==(Object other) {
    if (other is Selection<BT, SEL>) {
      final selEqual = _selection == other._selection;
      return selEqual && _base == other._base;
    }
    return false;
  }

  @override
  int get hashCode => _base.hashCode ^ (_selection?.hashCode ?? 0);
}
