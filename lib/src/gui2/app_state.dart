// Global application state notifiers.
//
// Using ValueNotifier rather than a full state management solution keeps
// the dependency graph simple. Tabs and widgets listen directly.

import 'package:flutter/foundation.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';

/// Set to the loaded DataSet after SourceFileLoader completes.
/// Null when no sources have been loaded.
final ValueNotifier<DataSet?> loadedDataSet = ValueNotifier(null);
