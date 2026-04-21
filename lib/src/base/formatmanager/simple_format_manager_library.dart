import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'format_manager_library.dart';

class SimpleFormatManagerLibrary implements FormatManagerLibrary {
  final Map<String, FormatManager<dynamic>> _managers = {};

  void addFormatManager(FormatManager<dynamic> manager) {
    _managers[manager.getIdentifierType()] = manager;
  }

  @override
  FormatManager<dynamic>? getFormatManager(String formatName) =>
      _managers[formatName];

  @override
  bool hasFormatManager(String formatName) => _managers.containsKey(formatName);
}
