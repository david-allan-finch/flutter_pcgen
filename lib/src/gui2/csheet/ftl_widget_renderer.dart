// FtlWidgetSink — streams the FTL evaluator's output directly into Flutter widgets.
//
// Pipeline: .htm.ftl → FTL evaluator → FtlWidgetSink.write() → Widget
// No HTML string is ever materialised; no external HTML parser is used.
//
// CSS handling: the <style> block is captured and parsed. Class attributes
// on HTML elements are resolved against the parsed CSS map, so background
// colours, text colours, font sizes, weights, and borders from the template
// CSS are applied directly to Flutter widget properties.

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/io/freemarker/ftl_engine.dart';

// ─── Public API ───────────────────────────────────────────────────────────────

class FtlWidgetSink extends FtlSink {
  static const _defHeaderBg = Color(0xFF37474F);
  static const _defHeaderFg = Colors.white;
  static const _borderCol   = Color(0xFFB0BEC5);

  // ─── Parser state ────────────────────────────────────────────────────────

  _Mode _mode = _Mode.normal;

  final _tagBuf   = StringBuffer(); // chars inside < >
  final _textBuf  = StringBuffer(); // plain-text accumulator
  final _styleBuf = StringBuffer(); // chars inside <style>…</style>
  String _skipUntil = '';

  // ─── CSS ─────────────────────────────────────────────────────────────────

  final _cssMap = <String, _CssStyle>{};

  // ─── Widget stack ─────────────────────────────────────────────────────────

  final _root  = _Column();
  late final List<_Builder> _stack;

  FtlWidgetSink() { _stack = [_root]; }

  _Builder get _top => _stack.last;

  // ─── FtlSink interface ────────────────────────────────────────────────────

  @override
  void write(String s) {
    for (var i = 0; i < s.length; i++) {
      _process(s[i]);
    }
  }

  void _process(String c) {
    switch (_mode) {
      case _Mode.normal:
        if (c == '<') { _flushText(); _tagBuf.clear(); _mode = _Mode.tag; }
        else _textBuf.write(c);

      case _Mode.tag:
        if (_tagBuf.isEmpty && c == '!') {
          _tagBuf.write(c);
        } else if (_tagBuf.toString() == '!' && c == '-') {
          _tagBuf.write(c);
        } else if (_tagBuf.toString() == '!-' && c == '-') {
          _mode = _Mode.comment; _tagBuf.clear();
        } else if (c == '>') {
          _processTag(_tagBuf.toString().trim());
          _tagBuf.clear();
          // Only return to normal if _handleOpen didn't set a different mode
          if (_mode == _Mode.tag) _mode = _Mode.normal;
        } else {
          _tagBuf.write(c);
        }

      case _Mode.comment:
        _tagBuf.write(c);
        if (_tagBuf.length >= 3) {
          final end = _tagBuf.toString().substring(_tagBuf.length - 3);
          if (end == '-->') { _tagBuf.clear(); _mode = _Mode.normal; }
        }

      case _Mode.skip:
        _tagBuf.write(c);
        if (_tagBuf.length >= _skipUntil.length) {
          final tail = _tagBuf.toString().substring(
              _tagBuf.length - _skipUntil.length).toLowerCase();
          if (tail == _skipUntil) { _tagBuf.clear(); _mode = _Mode.normal; }
          // Trim buffer to avoid unbounded growth
          if (_tagBuf.length > _skipUntil.length + 4) {
            final s = _tagBuf.toString();
            _tagBuf.clear();
            _tagBuf.write(s.substring(s.length - _skipUntil.length - 4));
          }
        }

      case _Mode.styleCapture:
        _styleBuf.write(c);
        if (_styleBuf.length >= 8) {
          final tail = _styleBuf.toString().substring(
              _styleBuf.length - 8).toLowerCase();
          if (tail == '</style>') {
            final css = _styleBuf.toString();
            _parseCss(css.substring(0, css.length - 8));
            _styleBuf.clear(); _mode = _Mode.normal;
          }
        }
    }
  }

  void _flushText() {
    final t = _textBuf.toString();
    _textBuf.clear();
    if (t.trim().isNotEmpty) _top.addText(_decodeEntities(t));
  }

  static String _decodeEntities(String s) => s
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&#160;', ' ')
      .replaceAll('&amp;',  '&')
      .replaceAll('&lt;',   '<')
      .replaceAll('&gt;',   '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'");

  // ─── CSS parsing ──────────────────────────────────────────────────────────

  void _parseCss(String css) {
    // Strip /* comments */
    final stripped = css.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
    // Find rule blocks: selector { properties }
    final ruleRe = RegExp(r'([^{]+)\{([^}]*)\}');
    for (final m in ruleRe.allMatches(stripped)) {
      final selectors = m.group(1)!.trim().split(',');
      final propStr   = m.group(2)!;
      final style = _CssStyle.parse(propStr);
      for (final sel in selectors) {
        final s = sel.trim();
        // Only handle simple class selectors like .ab or compound like .sa-table th
        // Extract all class names (start with .)
        final classRe = RegExp(r'\.([a-zA-Z0-9_-]+)');
        for (final cm in classRe.allMatches(s)) {
          final cls = cm.group(1)!;
          _cssMap[cls] = (_cssMap[cls] ?? _CssStyle()).merge(style);
        }
      }
    }
  }

  _CssStyle _resolve(String? classAttr) {
    if (classAttr == null || classAttr.isEmpty) return _CssStyle();
    var merged = _CssStyle();
    for (final cls in classAttr.split(RegExp(r'\s+'))) {
      final s = _cssMap[cls];
      if (s != null) merged = merged.merge(s);
    }
    return merged;
  }

  // ─── Tag processing ───────────────────────────────────────────────────────

  void _processTag(String inner) {
    if (inner.isEmpty) return;
    final selfClose = inner.endsWith('/');
    final closing   = inner.startsWith('/');
    final body      = closing
        ? inner.substring(1).trimLeft()
        : selfClose ? inner.substring(0, inner.length - 1).trimRight()
        : inner;
    final name = _tagName(body);
    final classAttr  = _attrValue(body, 'class');
    final bgAttr     = _attrValue(body, 'bgcolor');
    final alignAttr  = _attrValue(body, 'align');

    if (closing) {
      _handleClose(name);
    } else {
      _handleOpen(name, classAttr, bgAttr, alignAttr, body);
      if (selfClose) _handleClose(name);
    }
  }

  String _tagName(String body) {
    final end = body.indexOf(RegExp(r'[\s/>]'));
    return (end < 0 ? body : body.substring(0, end)).toLowerCase();
  }

  String? _attrValue(String attrs, String name) {
    final re = RegExp('$name=["\']([^"\']*)["\']', caseSensitive: false);
    return re.firstMatch(attrs)?.group(1);
  }

  // ─── Open tags ────────────────────────────────────────────────────────────

  void _handleOpen(String name, String? classAttr, String? bgColor,
      String? alignAttr, String attrs) {
    final css = _resolve(classAttr);
    // Inline bgcolor attribute supplements CSS
    if (bgColor != null && css.bgColor == null) {
      css.bgColor = _CssStyle._parseColor(bgColor);
    }
    // Inline align attribute supplements CSS
    if (alignAttr != null && css.textAlign == null) {
      switch (alignAttr.toLowerCase()) {
        case 'center': css.textAlign = TextAlign.center; break;
        case 'right':  css.textAlign = TextAlign.right;  break;
        case 'left':   css.textAlign = TextAlign.left;   break;
      }
    }

    switch (name) {
      case 'style':
        _styleBuf.clear(); _mode = _Mode.styleCapture; return;
      case 'script':
        _mode = _Mode.skip; _skipUntil = '</script>'; return;
      case 'head':
        _mode = _Mode.skip; _skipUntil = '</head>'; return;
      case 'html': case 'body': case 'meta': case 'link': case 'doctype': return;
      case 'title': _mode = _Mode.skip; _skipUntil = '</title>'; return;

      case 'h1': _stack.add(_Heading(1, css)); return;
      case 'h2': _stack.add(_Heading(2, css)); return;
      case 'h3': _stack.add(_Heading(3, css)); return;
      case 'h4': case 'h5': case 'h6': _stack.add(_Heading(4, css)); return;
      case 'p':   _stack.add(_Para(css)); return;
      case 'div': _stack.add(_Div(css)); return;
      case 'table': _stack.add(_TableB(css)); return;
      case 'thead': case 'tbody': case 'tfoot': return;
      case 'tr':  _stack.add(_RowB()); return;
      case 'th':  _stack.add(_CellB(isHeader: true,  css: css)); return;
      case 'td':  _stack.add(_CellB(isHeader: false, css: css)); return;
      case 'ul':  _stack.add(_ListB(ordered: false)); return;
      case 'ol':  _stack.add(_ListB(ordered: true));  return;
      case 'li':  _stack.add(_ListItemB()); return;
      case 'center': _stack.add(_Div(_CssStyle(), center: true)); return;

      case 'hr':
        _top.addWidget(const Divider(height: 10, thickness: 1, color: _borderCol));
        return;
      case 'br': _top.addText(' '); return;

      case 'b': case 'strong': _top.pushStyle(_Style.bold); return;
      case 'i': case 'em':     _top.pushStyle(_Style.italic); return;
      case 'font':
        if (css.textColor != null) _top.pushCssColor(css.textColor!);
        return;
    }
  }

  // ─── Close tags ───────────────────────────────────────────────────────────

  void _handleClose(String name) {
    _flushText();
    switch (name) {
      case 'b': case 'strong': case 'i': case 'em':
        _top.popStyle(); return;
      case 'font': _top.popCssColor(); return;

      case 'h1': case 'h2': case 'h3': case 'h4': case 'h5': case 'h6':
      case 'p': case 'div': case 'center':
      case 'table': case 'tr': case 'th': case 'td':
      case 'ul': case 'ol': case 'li':
        if (_stack.length > 1) {
          final done = _stack.removeLast();
          final w = done.build();
          if (w != null) _top.addWidget(w);
        }
        return;
      case 'html': case 'body': case 'head':
      case 'meta': case 'link': case 'title':
      case 'thead': case 'tbody': case 'tfoot':
      case 'br': case 'hr': return;
    }
  }

  // ─── Final widget ─────────────────────────────────────────────────────────

  Widget build() {
    _flushText();
    while (_stack.length > 1) {
      final done = _stack.removeLast();
      final w = done.build();
      if (w != null) _top.addWidget(w);
    }
    final rootWidget = _root.build();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: rootWidget ?? const SizedBox.shrink(),
    );
  }
}

// ─── Parser modes ─────────────────────────────────────────────────────────────

enum _Mode { normal, tag, comment, skip, styleCapture }
enum _Style { bold, italic }

// ─── CSS style model ──────────────────────────────────────────────────────────

class _CssStyle {
  Color?       textColor;
  Color?       bgColor;
  double?      fontSize;   // logical pixels
  FontWeight?  fontWeight;
  TextAlign?   textAlign;
  BoxBorder?   border;

  _CssStyle();

  /// Parse a CSS property block (content between { and }).
  static _CssStyle parse(String propBlock) {
    final s = _CssStyle();
    for (final raw in propBlock.split(';')) {
      final colonIdx = raw.indexOf(':');
      if (colonIdx < 0) continue;
      final prop = raw.substring(0, colonIdx).trim().toLowerCase();
      final val  = raw.substring(colonIdx + 1).trim().toLowerCase();
      switch (prop) {
        case 'color':            s.textColor  = _parseColor(val); break;
        case 'background':
        case 'background-color': s.bgColor    = _parseColor(val); break;
        case 'font-size':        s.fontSize   = _parseFontSize(val); break;
        case 'font-weight':
          if (val.contains('bold')) s.fontWeight = FontWeight.bold; break;
        case 'text-align':
          switch (val) {
            case 'center': s.textAlign = TextAlign.center; break;
            case 'right':  s.textAlign = TextAlign.right;  break;
            case 'left':   s.textAlign = TextAlign.left;   break;
          }
          break;
        case 'border':
          s.border = _parseBorder(val); break;
        case 'border-top':
          // keep it simple — just flag that a top border exists
          break;
      }
    }
    return s;
  }

  /// Merge [other] into this, with [other] taking precedence for non-null values.
  _CssStyle merge(_CssStyle other) {
    final m = _CssStyle();
    m.textColor  = other.textColor  ?? textColor;
    m.bgColor    = other.bgColor    ?? bgColor;
    m.fontSize   = other.fontSize   ?? fontSize;
    m.fontWeight = other.fontWeight ?? fontWeight;
    m.textAlign  = other.textAlign  ?? textAlign;
    m.border     = other.border     ?? border;
    return m;
  }

  bool get isEmpty => textColor == null && bgColor == null && fontSize == null &&
      fontWeight == null && textAlign == null && border == null;

  TextStyle? toTextStyle({Color? fallbackColor}) {
    if (textColor == null && fontSize == null && fontWeight == null) return null;
    return TextStyle(
      color:      textColor ?? fallbackColor,
      fontSize:   fontSize,
      fontWeight: fontWeight,
    );
  }

  // ─── CSS value parsers ────────────────────────────────────────────────────

  static Color? _parseColor(String val) {
    final v = val.trim().toLowerCase();
    // Named colours
    const named = {
      'black': Color(0xFF000000), 'white': Color(0xFFFFFFFF),
      'red':   Color(0xFFFF0000), 'blue':  Color(0xFF0000FF),
      'green': Color(0xFF008000), 'gray':  Color(0xFF808080),
      'grey':  Color(0xFF808080), 'lightgray': Color(0xFFD3D3D3),
      'lightgrey': Color(0xFFD3D3D3), 'darkgray': Color(0xFFA9A9A9),
      'silver': Color(0xFFC0C0C0), 'navy': Color(0xFF000080),
      'yellow': Color(0xFFFFFF00), 'orange': Color(0xFFFFA500),
      'transparent': Color(0x00000000),
    };
    if (named.containsKey(v)) return named[v];
    // Hex
    if (v.startsWith('#')) {
      final hex = v.substring(1);
      if (hex.length == 3) {
        final r = int.tryParse(hex[0] + hex[0], radix: 16) ?? 0;
        final g = int.tryParse(hex[1] + hex[1], radix: 16) ?? 0;
        final b = int.tryParse(hex[2] + hex[2], radix: 16) ?? 0;
        return Color.fromARGB(255, r, g, b);
      }
      if (hex.length == 6) {
        final r = int.tryParse(hex.substring(0, 2), radix: 16) ?? 0;
        final g = int.tryParse(hex.substring(2, 4), radix: 16) ?? 0;
        final b = int.tryParse(hex.substring(4, 6), radix: 16) ?? 0;
        return Color.fromARGB(255, r, g, b);
      }
    }
    return null;
  }

  static double? _parseFontSize(String val) {
    const keywords = {
      'xx-small': 8.0, 'x-small': 10.0, 'small': 12.0,
      'medium': 14.0,  'large': 18.0,    'x-large': 22.0,
      'xx-large': 26.0,
    };
    final v = val.trim().toLowerCase();
    if (keywords.containsKey(v)) return keywords[v];
    // pt values
    final ptMatch = RegExp(r'^([\d.]+)pt$').firstMatch(v);
    if (ptMatch != null) return double.tryParse(ptMatch.group(1)!)! * 1.33;
    // px values
    final pxMatch = RegExp(r'^([\d.]+)px$').firstMatch(v);
    if (pxMatch != null) return double.tryParse(pxMatch.group(1)!);
    return null;
  }

  static BoxBorder? _parseBorder(String val) {
    // e.g. "1px solid black"  "1pt solid #aaa"  "5px solid lightgray"
    final parts = val.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return null;
    final widthStr = parts[0];
    final color    = parts.length >= 3 ? _parseColor(parts[2]) : null;
    double width = 1;
    final wm = RegExp(r'^([\d.]+)(?:px|pt)?$').firstMatch(widthStr);
    if (wm != null) width = double.tryParse(wm.group(1)!) ?? 1;
    return Border.all(
      width: width,
      color: color ?? const Color(0xFF000000),
    );
  }
}

// Auto-contrast: if bg is dark and no explicit fg given, use white text.
Color? _autoFg(Color? bg, Color? fg) {
  if (fg != null) return fg;
  if (bg == null) return null;
  return bg.computeLuminance() < 0.35 ? Colors.white : Colors.black;
}

// ─── Builder base ──────────────────────────────────────────────────────────────

abstract class _Builder {
  final _textBuf   = StringBuffer();
  final _children  = <Widget>[];
  final _styles    = <_Style>[];
  final _cssColors = <Color>[]; // color stack for <font color=...>

  void addText(String t) => _textBuf.write(t);

  void addWidget(Widget w) {
    _flushPending();
    _children.add(w);
  }

  void pushStyle(_Style s) => _styles.add(s);
  void popStyle()  { if (_styles.isNotEmpty) _styles.removeLast(); }
  void pushCssColor(Color c) => _cssColors.add(c);
  void popCssColor() { if (_cssColors.isNotEmpty) _cssColors.removeLast(); }

  void _flushPending() {
    final t = _textBuf.toString().replaceAll(RegExp(r'[ \t\r\n]+'), ' ');
    _textBuf.clear();
    if (t.trim().isEmpty) return;
    final bold   = _styles.contains(_Style.bold);
    final italic = _styles.contains(_Style.italic);
    final col    = _cssColors.isNotEmpty ? _cssColors.last : null;
    _children.add(Text(t, style: TextStyle(
        fontSize:   11,
        fontWeight: bold   ? FontWeight.bold   : FontWeight.normal,
        fontStyle:  italic ? FontStyle.italic  : FontStyle.normal,
        color: col)));
  }

  Widget? build();
}

// ─── Concrete builders ─────────────────────────────────────────────────────────

class _Column extends _Builder {
  @override Widget? build() {
    _flushPending();
    if (_children.isEmpty) return null;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _children);
  }
}

class _Heading extends _Builder {
  final int level;
  final _CssStyle css;
  _Heading(this.level, this.css);

  @override Widget? build() {
    _flushPending();
    final t = _children.whereType<Text>().map((w) => w.data ?? '').join(' ').trim();
    if (t.isEmpty) return null;

    final bg  = css.bgColor;
    final fg  = css.textColor ?? (bg != null ? Colors.white : null);
    final fs  = css.fontSize ?? (level == 1 ? 16.0 : level == 2 ? 13.0 : 11.0);

    return Container(
      margin:  const EdgeInsets.only(top: 8, bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color:   bg ?? (level <= 3 ? const Color(0xFF37474F) : null),
      child:   Text(t, style: TextStyle(
          fontSize: fs, fontWeight: FontWeight.bold,
          color: fg ?? Colors.white)),
    );
  }
}

class _Para extends _Builder {
  final _CssStyle css;
  _Para(this.css);
  @override Widget? build() {
    _flushPending();
    if (_children.isEmpty) return null;
    final single = _children.length == 1 && _children.first is Text
        ? (_children.first as Text).data?.trim() ?? '' : '';
    if (single.isEmpty && _children.length == 1 && _children.first is Text) return null;
    Widget content = _children.length == 1
        ? _children.first
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: _children);
    if (css.bgColor != null) {
      content = Container(color: css.bgColor, padding: const EdgeInsets.all(2),
          child: content);
    }
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: content);
  }
}

class _Div extends _Builder {
  final _CssStyle css;
  final bool center;
  _Div(this.css, {this.center = false});
  @override Widget? build() {
    _flushPending();
    if (_children.isEmpty) return null;
    Widget col = Column(
        crossAxisAlignment:
            center ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
        children: _children);
    if (css.bgColor != null) {
      col = Container(color: css.bgColor, child: col);
    }
    return center ? Center(child: col) : col;
  }
}

// ─── Table ─────────────────────────────────────────────────────────────────────

class _TableB extends _Builder {
  final _CssStyle css;
  final _rows = <_RowB>[];
  _TableB(this.css);

  @override void addWidget(Widget w) {
    if (w is _RowWidget) _rows.add(w.row);
  }

  @override Widget? build() {
    if (_rows.isEmpty) return null;
    final maxCols = _rows.fold(0, (m, r) => r.cells.length > m ? r.cells.length : m);
    if (maxCols == 0) return null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Table(
        border: TableBorder.all(color: const Color(0xFFB0BEC5), width: 0.5),
        defaultColumnWidth: const FlexColumnWidth(),
        children: _rows.map((row) {
          var cells = List<Widget>.from(row.cells);
          while (cells.length < maxCols) {
            cells.add(Container(
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFB0BEC5), width: 0.5)),
            ));
          }
          return TableRow(children: cells);
        }).toList(),
      ),
    );
  }
}

class _RowWidget extends StatelessWidget {
  final _RowB row;
  const _RowWidget(this.row, {super.key});
  @override Widget build(BuildContext context) => const SizedBox.shrink();
}

class _RowB extends _Builder {
  final cells = <Widget>[];
  @override void addWidget(Widget w) {
    if (w is _CellWidget) cells.add(w.cell);
  }
  @override Widget? build() {
    if (cells.isEmpty) return null;
    return _RowWidget(this);
  }
}

class _CellWidget extends StatelessWidget {
  final Widget cell;
  const _CellWidget(this.cell, {super.key});
  @override Widget build(BuildContext context) => const SizedBox.shrink();
}

class _CellB extends _Builder {
  final bool isHeader;
  final _CssStyle css;
  _CellB({required this.isHeader, required this.css});

  @override void addWidget(Widget w) { _flushPending(); _children.add(w); }

  @override Widget? build() {
    _flushPending();

    // Determine effective styles from CSS + header flag
    final bg  = css.bgColor ?? (isHeader ? const Color(0xFFD0D7DC) : null);
    final fg  = _autoFg(bg, css.textColor);
    final fs  = css.fontSize ?? 10.0;
    final fw  = css.fontWeight ?? (isHeader ? FontWeight.bold : FontWeight.normal);
    final ta  = css.textAlign ?? (isHeader ? TextAlign.center : TextAlign.start);

    // Re-style any plain Text children with cell's colour/size
    final styledChildren = _children.map((child) {
      if (child is Text) {
        return Text(child.data ?? '',
            textAlign: ta,
            style: (child.style ?? const TextStyle()).copyWith(
                fontSize: fs, fontWeight: fw, color: fg));
      }
      return child;
    }).toList();

    Widget content = styledChildren.isEmpty
        ? const SizedBox.shrink()
        : styledChildren.length == 1 ? styledChildren.first
        : Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: styledChildren);

    final cell = Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: css.border,
      ),
      child: content,
    );
    return _CellWidget(cell);
  }
}

// ─── Lists ─────────────────────────────────────────────────────────────────────

class _ListB extends _Builder {
  final bool ordered;
  int _index = 0;
  _ListB({required this.ordered});
  @override void addWidget(Widget w) {
    _index++;
    final bullet = ordered ? '$_index.' : '•';
    _children.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 20, child: Text(bullet, style: const TextStyle(fontSize: 11))),
        Expanded(child: w),
      ]),
    ));
  }
  @override Widget? build() {
    if (_children.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: _children),
    );
  }
}

class _ListItemB extends _Builder {
  @override Widget? build() {
    _flushPending();
    if (_children.isEmpty) return null;
    return _children.length == 1 ? _children.first
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: _children);
  }
}
