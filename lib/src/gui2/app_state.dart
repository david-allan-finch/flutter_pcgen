// Global application state notifiers.
//
// Using ValueNotifier rather than a full state management solution keeps
// the dependency graph simple. Tabs and widgets listen directly.

import 'package:flutter/foundation.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/facade/core/character_facade.dart';

/// Set to the loaded DataSet after SourceFileLoader completes.
/// Null when no sources have been loaded.
final ValueNotifier<DataSet?> loadedDataSet = ValueNotifier(null);

/// Set to the currently active character when one is selected.
/// Null when no character is open/selected.
final ValueNotifier<CharacterFacade?> currentCharacter = ValueNotifier(null);
