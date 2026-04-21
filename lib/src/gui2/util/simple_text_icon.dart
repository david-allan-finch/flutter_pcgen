// Translation of pcgen.gui2.util.SimpleTextIcon

import 'package:flutter/material.dart';

/// Creates a widget that renders a plain text string as an icon-like element.
/// Useful when text needs special treatment (e.g. rollover state on a button).
/// HTML is not interpreted; the text is displayed verbatim.
class SimpleTextIcon extends StatelessWidget {
  final String text;
  final Color color;
  final TextStyle? textStyle;

  const SimpleTextIcon({
    super.key,
    required this.text,
    this.color = Colors.black,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (textStyle ?? DefaultTextStyle.of(context).style)
        .copyWith(color: color);
    return Text(text, style: effectiveStyle);
  }
}
