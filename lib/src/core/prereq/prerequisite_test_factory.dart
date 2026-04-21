// Copyright (c) Chris Ward, 2003.
//
// Translation of pcgen.core.prereq.PrerequisiteTestFactory

import 'package:flutter_pcgen/src/core/prereq/prerequisite.dart';
import 'package:flutter_pcgen/src/core/prereq/prerequisite_test.dart';

/// Singleton factory that maps prerequisite kinds to their tester objects.
class PrerequisiteTestFactory {
  static PrerequisiteTestFactory? _instance;
  final Map<String, PrerequisiteTest> _testLookup = {};

  PrerequisiteTestFactory._();

  static PrerequisiteTestFactory getInstance() {
    return _instance ??= PrerequisiteTestFactory._();
  }

  /// Registers a tester for the kind it reports via [PrerequisiteTest.kindHandled].
  void register(PrerequisiteTest testClass) {
    final kind = testClass.kindHandled().toUpperCase();
    if (_testLookup.containsKey(kind)) {
      // Log: duplicate registration
      return;
    }
    _testLookup[kind] = testClass;
  }

  /// Returns the appropriate tester for [kind], or null if none is registered.
  PrerequisiteTest? getTest(String? kind) {
    if (kind == null) {
      // null kind → PreMultTester equivalent (handle AND/OR composite prereqs)
      return _testLookup['MULT'];
    }
    return _testLookup[kind.toUpperCase()];
  }

  static void clear() => _instance?._testLookup.clear();
}
