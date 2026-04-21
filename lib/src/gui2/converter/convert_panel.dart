//
// Copyright (c) 2009 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
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
