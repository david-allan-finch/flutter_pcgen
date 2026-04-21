// Translation of pcgen.gui3.dialog.OptionsPathDialogController

import 'options_path_dialog_model.dart';

/// Controller for the Options Path dialog.
class OptionsPathDialogController {
  final OptionsPathDialogModel model;

  OptionsPathDialogController() : model = OptionsPathDialogModel();

  void apply() {
    // In a real implementation, persist the paths to preferences.
  }

  void cancel() {
    // Reset model to last saved values.
  }
}
