// Translation of pcgen.gui2.dialog.DataInstaller

import 'package:flutter/material.dart';

/// Dialog/tool for installing PCGen data sets from network or files.
class DataInstaller extends StatefulWidget {
  const DataInstaller({super.key});

  @override
  State<DataInstaller> createState() => _DataInstallerState();
}

class _DataInstallerState extends State<DataInstaller> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Install Data')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download, size: 64),
            SizedBox(height: 16),
            Text('Data installation interface'),
          ],
        ),
      ),
    );
  }
}
