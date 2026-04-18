import '../core/game_mode.dart';
import '../core/settings_handler.dart';
import 'system_loader.dart';

// Singleton factory for accessing the system loader.
final class PersistenceManager {
  PersistenceManager._();
  static final PersistenceManager _instance = PersistenceManager._();
  static PersistenceManager getInstance() => _instance;

  // stub — LstSystemLoader not yet translated
  SystemLoader? _loader; // set externally

  void setChosenCampaignSourcefiles(List<String> l, [GameMode? game]) {
    final g = game ?? SettingsHandler.getGame();
    _loader?.setChosenCampaignSourcefiles(l, g);
  }

  List<String> getChosenCampaignSourcefiles([GameMode? game]) {
    final g = game ?? SettingsHandler.getGame();
    return _loader?.getChosenCampaignSourcefiles(g) ?? [];
  }
}
