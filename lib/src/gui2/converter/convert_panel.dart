// Translation of pcgen.gui2.converter.ConvertPanel

import 'package:flutter/material.dart';

/// Main panel for the LST data converter wizard.
class ConvertPanel extends StatefulWidget {
  const ConvertPanel({super.key});

  @override
  State<ConvertPanel> createState() => _ConvertPanelState();
}

class _ConvertPanelState extends State<ConvertPanel> {
  int _currentStep = 0;

  static const List<String> _stepTitles = [
    'Welcome',
    'Select Game Mode',
    'Select Campaigns',
    'Select Source Directory',
    'Select Output Directory',
    'Run Conversion',
    'Summary',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'PCGen Data Converter — Step ${_currentStep + 1}: ${_stepTitles[_currentStep]}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const Divider(),
        Expanded(
          child: Center(
            child: Text(_stepTitles[_currentStep]),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_currentStep > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('Back'),
                ),
              const SizedBox(width: 8),
              if (_currentStep < _stepTitles.length - 1)
                ElevatedButton(
                  onPressed: () => setState(() => _currentStep++),
                  child: const Text('Next'),
                ),
              if (_currentStep == _stepTitles.length - 1)
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Finish'),
                ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
