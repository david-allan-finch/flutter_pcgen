//
// Copyright 2021 (C) Eitan Adler <lists@eitanadler.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
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
