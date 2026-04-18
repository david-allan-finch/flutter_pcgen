import 'game_mode.dart';

// Wraps a GameMode for display/comparison in mode selection lists.
final class GameModeDisplay implements Comparable<Object> {
  final GameMode gameMode;

  GameModeDisplay(this.gameMode);

  GameMode getGameMode() => gameMode;

  @override
  String toString() => gameMode.getDisplayName();

  @override
  int compareTo(Object obj) {
    if (obj is GameModeDisplay) {
      final iOrder = obj.gameMode.getDisplayOrder();
      if (iOrder < gameMode.getDisplayOrder()) return 1;
      if (iOrder > gameMode.getDisplayOrder()) return -1;
      return gameMode
          .getDisplayName()
          .toLowerCase()
          .compareTo(obj.gameMode.getDisplayName().toLowerCase());
    }
    return 1;
  }
}
