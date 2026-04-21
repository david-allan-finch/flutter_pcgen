// Translation of pcgen.gui2.tabs.TemplateInfoTab

import 'package:flutter/material.dart';

/// Tab panel for applying character templates.
class TemplateInfoTab extends StatefulWidget {
  const TemplateInfoTab({super.key});

  @override
  State<TemplateInfoTab> createState() => TemplateInfoTabState();
}

class TemplateInfoTabState extends State<TemplateInfoTab> {
  dynamic _character;

  void setCharacter(dynamic character) => setState(() => _character = character);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Available Templates',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(child: ListView(children: const [])),
            ],
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Applied Templates',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(child: ListView(children: const [])),
            ],
          ),
        ),
      ],
    );
  }
}
