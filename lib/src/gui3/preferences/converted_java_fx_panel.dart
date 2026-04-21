// Translation of pcgen.gui3.preferences.ConvertedJavaFXPanel

import 'package:flutter/material.dart';

/// Base class for preference panels that were converted from JavaFX FXML.
/// In Flutter, each panel is simply a StatefulWidget.
abstract class ConvertedJavaFXPanel extends StatefulWidget {
  const ConvertedJavaFXPanel({super.key});

  /// The title to show in the preferences sidebar.
  String get panelTitle;
}
