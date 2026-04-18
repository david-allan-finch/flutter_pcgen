import 'package:flutter/material.dart';

class PCGenApp extends StatelessWidget {
  const PCGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PCGen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('PCGen loading...')),
      ),
    );
  }
}
