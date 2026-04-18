import '../base/cdom_object.dart';

// Represents one "head" of a weapon (weapons can have multiple heads, e.g. double axe).
final class EquipmentHead extends CDOMObject {
  static const String pcEquipmentPart = 'PC.EQUIPMENT.PART';

  final dynamic _headSource; // VarScoped owner
  final int _index;

  EquipmentHead(dynamic source, int idx)
      : _headSource = source,
        _index = idx {
    if (source == null) throw ArgumentError('Source for EquipmentHead cannot be null');
  }

  int getHeadIndex() => _index;

  dynamic getOwner() => _headSource;

  @override
  int get hashCode => _index ^ _headSource.hashCode;

  @override
  bool operator ==(Object obj) {
    if (identical(this, obj)) return true;
    if (obj is! EquipmentHead) return false;
    return obj._index == _index && obj._headSource == _headSource;
  }

  @override
  bool isType(String type) => false;

  @override
  String? getLocalScopeName() => pcEquipmentPart;
}
