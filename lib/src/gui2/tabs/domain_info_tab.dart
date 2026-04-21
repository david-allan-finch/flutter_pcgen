// Translation of pcgen.gui2.tabs.DomainInfoTab

import 'package:flutter/material.dart';

/// Tab panel for selecting cleric domains.
class DomainInfoTab extends StatefulWidget {
  const DomainInfoTab({super.key});

  @override
  State<DomainInfoTab> createState() => DomainInfoTabState();
}

class DomainInfoTabState extends State<DomainInfoTab> {
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
                child: Text('Available Domains',
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
                child: Text('Domain Info',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Expanded(
                  child: Center(child: Text('Select a domain to see info'))),
            ],
          ),
        ),
      ],
    );
  }
}
