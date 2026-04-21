import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_pcgen/src/app.dart';

void main() {
  // Configure logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PCGenApp());
}
