import '../util/format_manager.dart';

abstract interface class FormatManagerLibrary {
  FormatManager<dynamic>? getFormatManager(String formatName);
  bool hasFormatManager(String formatName);
}
