import '../core/game_mode.dart';

// Abstract factory interface for loading PCGen system files.
abstract interface class SystemLoader {
  static const String tabDelim = '\t';

  void setChosenCampaignSourcefiles(List<String> l, GameMode game);
  List<String> getChosenCampaignSourcefiles(GameMode game);
}
