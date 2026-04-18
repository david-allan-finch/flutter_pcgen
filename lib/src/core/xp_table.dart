import 'level_info.dart';
import 'pcobject.dart';

// Maps level strings to LevelInfo objects for an XP progression table.
final class XPTable extends PObject {
  final String _name;
  final Map<String, LevelInfo> _infoMap = {};

  XPTable([String? xpTable]) : _name = xpTable ?? 'Default';

  String getName() => _name;

  void addLevelInfo(String level, LevelInfo levelInfo) =>
      _infoMap[level] = levelInfo;

  LevelInfo? getLevelInfo(String levelString) => _infoMap[levelString];
}
