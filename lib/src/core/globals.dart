import 'data_set.dart';
import 'game_mode.dart';
import 'pc_class.dart';
import 'player_character.dart';

// Global singleton state for PCGen - mirrors pcgen.core.Globals.
class Globals {
  Globals._();

  static GameMode? _gameMode;
  static DataSet? _currentDataSet;
  static final List<PlayerCharacter> _pcList = [];
  static int _currentPCIndex = 0;

  static GameMode? get gameMode => _gameMode;
  static void setGameMode(GameMode mode) { _gameMode = mode; }

  static DataSet? get currentDataSet => _currentDataSet;
  static void setCurrentDataSet(DataSet ds) { _currentDataSet = ds; }

  static List<PlayerCharacter> get pcList => List.unmodifiable(_pcList);
  static void addPC(PlayerCharacter pc) { _pcList.add(pc); }
  static void removePC(PlayerCharacter pc) { _pcList.remove(pc); }

  static PlayerCharacter? get currentPC {
    if (_pcList.isEmpty) return null;
    if (_currentPCIndex >= _pcList.length) _currentPCIndex = 0;
    return _pcList[_currentPCIndex];
  }

  static void setCurrentPC(PlayerCharacter pc) {
    final idx = _pcList.indexOf(pc);
    if (idx >= 0) _currentPCIndex = idx;
  }

  static int getSkillMultiplierForLevel(int level) {
    return _gameMode?.getSkillMultiplierForLevel(level) ?? (level <= 1 ? 4 : 2);
  }

  static int maxPCStatValue() => _gameMode?.getStatMax() ?? 18;
  static int minPCStatValue() => _gameMode?.getStatMin() ?? 3;

  static List<PCClass> getClassList() => _currentDataSet?.classes ?? [];

  // Settings
  static bool showOutputNameForOtherItems = false;
}
