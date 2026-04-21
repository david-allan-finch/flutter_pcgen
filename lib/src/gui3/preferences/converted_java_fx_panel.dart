//
// Copyright 2019 (C) Eitan Adler <lists@eitanadler.com>
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
// Translation of pcgen.gui3.preferences.ConvertedJavaFXPanel

import 'package:flutter/material.dart';

/// Base class for preference panels that were converted from JavaFX FXML.
/// In Flutter, each panel is simply a StatefulWidget.
abstract class ConvertedJavaFXPanel extends StatefulWidget {
  const ConvertedJavaFXPanel({super.key});

  /// The title to show in the preferences sidebar.
  String get panelTitle;
}
