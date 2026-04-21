// Translation of pcgen.gui3.dialog.AboutDialogController

import 'package:flutter/foundation.dart';

/// Controller for the About dialog — provides app version/credit info.
class AboutDialogController extends ChangeNotifier {
  String _version = '';
  String _buildDate = '';
  String _website = 'https://pcgen.org';

  String get version => _version;
  String get buildDate => _buildDate;
  String get website => _website;

  void load({required String version, required String buildDate}) {
    _version = version;
    _buildDate = buildDate;
    notifyListeners();
  }
}
