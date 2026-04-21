// Translation of pcgen.gui3.dialog.ExportDialogController

import 'package:flutter/foundation.dart';

/// Controller for the Export dialog — handles template selection and export actions.
class ExportDialogController extends ChangeNotifier {
  final dynamic _character;
  final List<String> _templates = [];
  String? _selectedTemplate;
  String _outputPath = '';
  bool _exporting = false;
  bool _done = false;
  String _status = '';

  ExportDialogController(this._character);

  List<String> get templates => List.unmodifiable(_templates);
  String? get selectedTemplate => _selectedTemplate;
  String get outputPath => _outputPath;
  bool get exporting => _exporting;
  bool get done => _done;
  String get status => _status;

  void setTemplates(List<String> templates) {
    _templates
      ..clear()
      ..addAll(templates);
    _selectedTemplate = _templates.isNotEmpty ? _templates.first : null;
    notifyListeners();
  }

  void selectTemplate(String template) {
    _selectedTemplate = template;
    notifyListeners();
  }

  void setOutputPath(String path) {
    _outputPath = path;
    notifyListeners();
  }

  Future<void> export() async {
    if (_selectedTemplate == null) return;
    _exporting = true;
    _done = false;
    _status = 'Exporting...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500)); // simulate work

    _exporting = false;
    _done = true;
    _status = 'Export complete: $_outputPath';
    notifyListeners();
  }

  void reset() {
    _done = false;
    _status = '';
    notifyListeners();
  }
}
