import 'choose_selection_actor.dart';
import 'choose_information.dart';

// A ChooseDriver is an object that drives the CHOOSE mechanism (e.g. a
// CDOMObject with a CHOOSE token). It provides all the information needed
// to present and apply selections.
abstract interface class ChooseDriver {
  ChooseInformation<dynamic> getChooseInfo();
  dynamic getSelectFormula(); // Formula
  List<ChooseSelectionActor<dynamic>> getActors();
  String getFormulaSource();
  dynamic getNumChoices(); // Formula
  String getDisplayName();
}
