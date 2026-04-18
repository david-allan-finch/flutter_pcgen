import '../../base/util/format_manager.dart';
import '../base/loadable.dart';

// Abstract base for user-defined content items (variables, functions, facts).
abstract class UserContent implements Loadable {
  String? _name;
  String? _sourceUri;
  String? _explanation;

  @override
  void setName(String name) => _name = name;

  @override
  String getKeyName() => _name ?? '';

  @override
  void setSourceURI(String source) => _sourceUri = source;

  @override
  String? getSourceURI() => _sourceUri;

  void setExplanation(String value) => _explanation = value;

  String? getExplanation() => _explanation;

  String getDisplayName();

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;
}
