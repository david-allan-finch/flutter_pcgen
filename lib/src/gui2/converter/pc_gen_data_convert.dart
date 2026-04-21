// Translation of pcgen.gui2.converter.PCGenDataConvert

import 'package:flutter/material.dart';
import 'convert_panel.dart';

/// Entry point for the LST data conversion tool.
/// Shows the ConvertPanel in a dialog window.
class PCGenDataConvert {
  PCGenDataConvert._();

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        child: SizedBox(
          width: 700,
          height: 500,
          child: Scaffold(
            appBar: AppBar(title: const Text('PCGen Data Converter')),
            body: const ConvertPanel(),
          ),
        ),
      ),
    );
  }
}
