// Translation of pcgen.gui2.kits.KitPanel

import 'package:flutter/material.dart';

/// Panel for browsing and applying kits to a character.
class KitPanel extends StatefulWidget {
  final dynamic character;

  const KitPanel({super.key, required this.character});

  @override
  State<KitPanel> createState() => _KitPanelState();
}

class _KitPanelState extends State<KitPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Kits'),
          automaticallyImplyLeading: false,
        ),
        const Expanded(
          child: Center(child: Text('Available kits')),
        ),
      ],
    );
  }
}
