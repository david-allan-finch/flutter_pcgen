import 'info_facade.dart';

// Facade interface for Equipment items visible in the UI.
abstract interface class EquipmentFacade implements InfoFacade {
  List<String> getTypes();
  String? getIcon(); // file path
  List<String> getTypesForDisplay();
  String getRawSpecialProperties();
}
