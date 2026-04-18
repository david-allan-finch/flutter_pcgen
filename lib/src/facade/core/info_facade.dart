// Base interface for game objects visible in the UI.
abstract interface class InfoFacade {
  String getSource();
  String getSourceForNodeDisplay();
  String getKeyName();
  bool isNamePI();
  String getType();
}
