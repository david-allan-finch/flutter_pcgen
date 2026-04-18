import '../../core/game_mode.dart';

// Facade interface for Campaign source books.
abstract interface class CampaignFacade {
  bool showInMenu();
  List<GameMode> getGameModes();
  String getName();
  String getPublisher();
  String getFormat();
  String getSetting();
  String getBookTypes();
  List<String> getBookTypeList();
  String getStatus();
  String getKeyName();
  String getSourceShort();
}
