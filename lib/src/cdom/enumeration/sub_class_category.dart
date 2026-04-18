import '../inst/abstract_category.dart';
import '../../core/sub_class.dart';

// Type-safe constant that also acts as a Category<SubClass>.
final class SubClassCategory extends AbstractCategory<SubClass> {
  static final Map<String, SubClassCategory> _typeMap = {};
  static int _ordinalCount = 0;

  final int _ordinal;

  SubClassCategory._(String name)
      : _ordinal = _ordinalCount++ {
    setName(name);
  }

  static SubClassCategory getConstant(String name) {
    final lookup = name.replaceAll('_', ' ');
    if (lookup.isEmpty) throw ArgumentError('Type Name cannot be zero length');
    return _typeMap.putIfAbsent(lookup.toLowerCase(), () => SubClassCategory._(lookup));
  }

  static SubClassCategory valueOf(String name) {
    final result = _typeMap[name.toLowerCase()];
    if (result == null) throw ArgumentError(name);
    return result;
  }

  static List<SubClassCategory>? getAllConstants() {
    if (_typeMap.isEmpty) return null;
    return List.unmodifiable(_typeMap.values);
  }

  static void clearConstants() { _typeMap.clear(); }

  int getOrdinal() => _ordinal;

  @override
  void setName(String name) {
    // Only allowed during construction (called from constructor)
    super.setName(name);
  }

  @override
  SubClass newInstance() {
    final sc = SubClass();
    sc.setCDOMCategory(this);
    return sc;
  }

  @override
  Type get referenceClass => SubClass;

  @override
  String getReferenceDescription() => 'SubClass Category ${getKeyName()}';

  @override
  String getPersistentFormat() => 'SUBCLASS=${getKeyName()}';
}
