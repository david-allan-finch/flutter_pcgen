import '../content/processor.dart';

// A Processor that remaps an armor type string to a different type.
class ChangeArmorType implements Processor<String> {
  final String _source;
  final String _result;

  ChangeArmorType(String sourceType, String resultType)
      : _source = sourceType,
        _result = resultType;

  @override
  String applyProcessor(String sourceType, Object? context) =>
      _source.toLowerCase() == sourceType.toLowerCase() ? _result : sourceType;

  @override
  Type getModifiedClass() => String;

  List<String> applyProcessorToList(Iterable<String> armorTypes) {
    final returnList = <String>[];
    for (final type in armorTypes) {
      final mod = applyProcessor(type, null);
      returnList.add(mod.toUpperCase());
    }
    return returnList;
  }

  @override
  String getLSTformat() =>
      _result.isEmpty ? _source : '$_source|$_result';

  @override
  int get hashCode => 31 * _source.hashCode + _result.hashCode;

  @override
  bool operator ==(Object obj) =>
      obj is ChangeArmorType &&
      obj._source == _source &&
      obj._result == _result;
}
