import 'info_facade.dart';

// Facade interface for Ability objects exposed to the UI.
abstract interface class AbilityFacade implements InfoFacade {
  List<String> getTypes();
  bool isMult();
  bool isStackable();
  double getCost();
}
