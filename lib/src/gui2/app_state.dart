// Global application state notifiers.
//
// Using ValueNotifier rather than a full state management solution keeps
// the dependency graph simple. Tabs and widgets listen directly.

import 'package:flutter/foundation.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/facade/core/character_facade.dart';

/// The dataset for the currently-viewed character.
/// Switches automatically when you switch between open characters so the
/// UI tabs always show data relevant to the character being edited.
///
/// Previously this was a single global dataset for the whole app. It is now
/// per-character-view: the registry (datasetRegistry) holds one DataSet per
/// game mode, and this notifier reflects whichever one the active character uses.
final ValueNotifier<DataSet?> loadedDataSet = ValueNotifier(null);

/// Registry of loaded DataSets keyed by game mode name (lower-case).
/// Once a game mode's sources are loaded they stay in memory so switching
/// between characters from different game modes is instant.
final Map<String, DataSet> datasetRegistry = {};

/// Set to the currently active character when one is selected.
/// Null when no character is open/selected.
final ValueNotifier<CharacterFacade?> currentCharacter = ValueNotifier(null);
