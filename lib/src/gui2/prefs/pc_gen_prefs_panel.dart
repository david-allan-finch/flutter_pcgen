// Translation of pcgen.gui2.prefs.PCGenPrefsPanel

import 'package:flutter/material.dart';

/// Abstract base for PCGen preferences panels.
abstract class PCGenPrefsPanel extends StatefulWidget {
  const PCGenPrefsPanel({super.key});

  String getTitle();
  void applyPreferences();
  void resetPreferences();
}
