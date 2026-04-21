// Translation of pcgen.gui2.util.table.IntegerEditor

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A table cell editor for integer values.
class IntegerEditor extends StatefulWidget {
  final int? value;
  final int? minValue;
  final int? maxValue;
  final void Function(int?)? onChanged;

  const IntegerEditor({
    super.key,
    this.value,
    this.minValue,
    this.maxValue,
    this.onChanged,
  });

  @override
  State<IntegerEditor> createState() => _IntegerEditorState();
}

class _IntegerEditorState extends State<IntegerEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.value?.toString() ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (text) {
        final parsed = int.tryParse(text);
        if (parsed != null) {
          final min = widget.minValue;
          final max = widget.maxValue;
          if ((min == null || parsed >= min) && (max == null || parsed <= max)) {
            widget.onChanged?.call(parsed);
          }
        } else if (text.isEmpty) {
          widget.onChanged?.call(null);
        }
      },
    );
  }
}
