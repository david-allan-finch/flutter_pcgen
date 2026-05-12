// FtlWidgetSink — streams the FTL evaluator's output directly into Flutter widgets.
//
// Pipeline: .htm.ftl → FTL evaluator → FtlWidgetSink.write() → Widget
// No HTML string is ever materialised; no external HTML parser is used.
//
// The sink receives the evaluator's writes character-by-character, recognises
// HTML structure tags (<table>, <tr>, <td>, <h3>, etc.) and builds the
// corresponding Flutter widget tree on-the-fly.

import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/io/freemarker/ftl_engine.dart';

// ─── Public API ───────────────────────────────────────────────────────────────

class FtlWidgetSink extends FtlSink {
  static const _headerBg  = Color(0xFF37474F);
  static const _headerFg  = Colors.white;
  static const _labelBg   = Color(0xFFECEFF1);
  static const _borderCol = Color(0xFFB0BEC5);
  static const _accentCol = Color(0xFF1565C0);

  // ─── Parser state ────────────────────────────────────────────────────────

  // Modes: normal text, inside a tag, inside a comment, skipping a block (style/script)
  _Mode _mode = _Mode.normal;

  final _tagBuf  = StringBuffer(); // chars inside current < >
  final _textBuf = StringBuffer(); // plain text accumulator
  String _skipUntil = '';          // closing tag to exit skip mode (e.g. '</style>')

  // ─── Widget stack ─────────────────────────────────────────────────────────

  final _root   = _Column();
  late final List<_Builder> _stack;

  FtlWidgetSink() {
    _stack = [_root];
  }

  _Builder get _top => _stack.last;

  // ─── FtlSink interface ───────────────────────────────────────────────────

  @override
  void write(String s) {
    for (var i = 0; i < s.length; i++) {
      final c = s[i];
      _process(c, s, i);
    }
  }

  void _process(String c, String s, int i) {
    switch (_mode) {
      case _Mode.normal:
        if (c == '<') {
          _flushText();
          _tagBuf.clear();
          _mode = _Mode.tag;
        } else {
          _textBuf.write(c);
        }

      case _Mode.tag:
        if (_tagBuf.isEmpty && c == '!') {
          // Could be <!-- comment --> or <!DOCTYPE>
          _tagBuf.write(c);
        } else if (_tagBuf.toString() == '!' && c == '-') {
          _tagBuf.write(c); // '!-'
        } else if (_tagBuf.toString() == '!-' && c == '-') {
          // Entering <!-- comment -->
          _mode = _Mode.comment;
          _tagBuf.clear();
        } else if (c == '>') {
          _processTag(_tagBuf.toString().trim());
          _tagBuf.clear();
          _mode = _Mode.normal;
        } else {
          _tagBuf.write(c);
        }

      case _Mode.comment:
        // Skip until -->
        _tagBuf.write(c);
        final t = _tagBuf.toString();
        if (t.endsWith('-->')) {
          _tagBuf.clear();
          _mode = _Mode.normal;
        }

      case _Mode.skip:
        // Skip until _skipUntil (e.g. '</style>')
        _tagBuf.write(c);
        final t = _tagBuf.toString().toLowerCase();
        if (t.endsWith(_skipUntil)) {
          _tagBuf.clear();
          _mode = _Mode.normal;
        }
        // Trim buffer to avoid unbounded growth
        if (_tagBuf.length > _skipUntil.length + 4) {
          final buf = _tagBuf.toString();
          _tagBuf.clear();
          _tagBuf.write(buf.substring(buf.length - (_skipUntil.length + 4)));
        }
    }
  }

  void _flushText() {
    final t = _textBuf.toString();
    _textBuf.clear();
    if (t.trim().isNotEmpty) _top.addText(t);
  }

  // ─── Tag dispatcher ───────────────────────────────────────────────────────

  void _processTag(String inner) {
    if (inner.isEmpty) return;

    // Self-closing: <br/> <hr/> <img .../>
    final selfClose = inner.endsWith('/');
    final closing   = inner.startsWith('/');
    final body      = closing ? inner.substring(1).trimLeft()
                    : selfClose ? inner.substring(0, inner.length - 1).trimRight()
                    : inner;
    final name      = _tagName(body);

    if (closing) {
      _handleClose(name);
    } else {
      _handleOpen(name, body);
      if (selfClose) _handleClose(name);
    }
  }

  String _tagName(String body) {
    final end = body.indexOf(RegExp(r'[\s/>]'));
    return (end < 0 ? body : body.substring(0, end)).toLowerCase();
  }

  // ─── Open tags ────────────────────────────────────────────────────────────

  void _handleOpen(String name, String attrs) {
    switch (name) {
      // Skip these blocks entirely
      case 'style':  _mode = _Mode.skip; _skipUntil = '</style>';  return;
      case 'script': _mode = _Mode.skip; _skipUntil = '</script>'; return;
      case 'head':   _mode = _Mode.skip; _skipUntil = '</head>';   return;
      // Ignore structural/meta tags
      case 'html': case 'body': case 'meta': case 'link':
      case 'title': case 'doctype': return;

      // Block elements that push a new builder
      case 'h1': _stack.add(_Heading(1)); return;
      case 'h2': _stack.add(_Heading(2)); return;
      case 'h3': _stack.add(_Heading(3)); return;
      case 'h4': case 'h5': case 'h6': _stack.add(_Heading(4)); return;
      case 'p':   _stack.add(_Para()); return;
      case 'div': _stack.add(_Div()); return;
      case 'table': _stack.add(_TableB()); return;
      case 'tr':    _stack.add(_RowB()); return;
      case 'th':    _stack.add(_CellB(isHeader: true));  return;
      case 'td':    _stack.add(_CellB(isHeader: false)); return;
      case 'ul':    _stack.add(_ListB(ordered: false)); return;
      case 'ol':    _stack.add(_ListB(ordered: true));  return;
      case 'li':    _stack.add(_ListItemB()); return;

      // Self-handled
      case 'hr':
        _top.addWidget(const Divider(height: 10, thickness: 1, color: _borderCol));
        return;
      case 'br':
        _top.addText(' ');
        return;

      // Inline formatting — mark current text context
      case 'b': case 'strong': _top.pushStyle(_Style.bold); return;
      case 'i': case 'em':     _top.pushStyle(_Style.italic); return;
      case 'center':            _stack.add(_Div(center: true)); return;

      // Everything else (span, a, font, input, img, …) — ignore tag
    }
  }

  // ─── Close tags ───────────────────────────────────────────────────────────

  void _handleClose(String name) {
    _flushText();

    switch (name) {
      case 'b': case 'strong':
      case 'i': case 'em':
        _top.popStyle(); return;

      case 'h1': case 'h2': case 'h3': case 'h4': case 'h5': case 'h6':
      case 'p': case 'div': case 'center':
      case 'table': case 'tr': case 'th': case 'td':
      case 'ul': case 'ol': case 'li':
        if (_stack.length > 1) {
          final done = _stack.removeLast();
          final widget = done.build(
            headerBg: _headerBg, headerFg: _headerFg,
            labelBg: _labelBg, borderCol: _borderCol, accentCol: _accentCol,
          );
          if (widget != null) _top.addWidget(widget);
        }
        return;

      // Ignored close tags
      case 'html': case 'body': case 'head':
      case 'meta': case 'link': case 'title': case 'br': case 'hr':
        return;
    }
  }

  // ─── Final widget ─────────────────────────────────────────────────────────

  Widget build() {
    _flushText();
    // Close any unclosed tags by flushing remaining stack items
    while (_stack.length > 1) {
      final done = _stack.removeLast();
      final w = done.build(
        headerBg: _headerBg, headerFg: _headerFg,
        labelBg: _labelBg, borderCol: _borderCol, accentCol: _accentCol,
      );
      if (w != null) _top.addWidget(w);
    }
    final rootWidget = _root.build(
      headerBg: _headerBg, headerFg: _headerFg,
      labelBg: _labelBg, borderCol: _borderCol, accentCol: _accentCol,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: rootWidget ?? const SizedBox.shrink(),
    );
  }
}

// ─── Parser modes ─────────────────────────────────────────────────────────────

enum _Mode { normal, tag, comment, skip }
enum _Style { bold, italic }

// ─── Builder base ─────────────────────────────────────────────────────────────

abstract class _Builder {
  final _textBuf  = StringBuffer();
  final _children = <Widget>[];
  final _styles   = <_Style>[];

  void addText(String t) => _textBuf.write(t);
  void addWidget(Widget w) {
    _flushPending();
    _children.add(w);
  }
  void pushStyle(_Style s) => _styles.add(s);
  void popStyle() { if (_styles.isNotEmpty) _styles.removeLast(); }

  void _flushPending() {
    final t = _textBuf.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    _textBuf.clear();
    if (t.isEmpty) return;
    final bold   = _styles.contains(_Style.bold);
    final italic = _styles.contains(_Style.italic);
    _children.add(Text(t, style: TextStyle(
        fontSize: 11,
        fontWeight: bold   ? FontWeight.bold   : FontWeight.normal,
        fontStyle: italic  ? FontStyle.italic  : FontStyle.normal)));
  }

  Widget? build({required Color headerBg, required Color headerFg,
                 required Color labelBg,  required Color borderCol,
                 required Color accentCol});
}

// ─── Concrete builders ────────────────────────────────────────────────────────

class _Column extends _Builder {
  @override
  Widget? build({required Color headerBg, required Color headerFg,
                 required Color labelBg,  required Color borderCol,
                 required Color accentCol}) {
    _flushPending();
    if (_children.isEmpty) return null;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _children);
  }
}

class _Heading extends _Builder {
  final int level;
  _Heading(this.level);
  @override
  Widget? build({required Color headerBg, required Color headerFg,
                 required Color labelBg,  required Color borderCol,
                 required Color accentCol}) {
    _flushPending();
    final t = _children.whereType<Text>().map((w) => w.data ?? '').join(' ').trim();
    if (t.isEmpty) return null;
    if (level <= 3) {
      // Section header band
      return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: headerBg,
        child: Text(t, style: TextStyle(
            fontSize: level == 1 ? 14 : level == 2 ? 12 : 11,
            fontWeight: FontWeight.bold, color: headerFg)),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Text(t, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.bold, color: accentCol)),
    );
  }
}

class _Para extends _Builder {
  @override
  Widget? build({required Color headerBg, required Color headerFg,
                 required Color labelBg,  required Color borderCol,
                 required Color accentCol}) {
    _flushPending();
    if (_children.isEmpty) return null;
    if (_children.length == 1 && _children.first is Text) {
      final t = (_children.first as Text).data ?? '';
      if (t.trim().isEmpty) return null;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: _children),
    );
  }
}

class _Div extends _Builder {
  final bool center;
  _Div({this.center = false});
  @override
  Widget? build({required Color headerBg, required Color headerFg,
                 required Color labelBg,  required Color borderCol,
                 required Color accentCol}) {
    _flushPending();
    if (_children.isEmpty) return null;
    final col = Column(
        crossAxisAlignment:
            center ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
        children: _children);
    return center ? Center(child: col) : col;
  }
}

// ─── Table ────────────────────────────────────────────────────────────────────

class _TableB extends _Builder {
  final _rows = <_RowB>[];

  @override void addWidget(Widget w) {
    // Only accept _RowB results (TableRow); ignore stray text/widgets
    if (w is _RowWidget) _rows.add(w.row);
  }

  @override
  Widget? build({required Color headerBg, required Color headerFg,
                 required Color labelBg,  required Color borderCol,
                 required Color accentCol}) {
    if (_rows.isEmpty) return null;
    final maxCols = _rows.fold(0, (m, r) => r.cells.length > m ? r.cells.length : m);
    if (maxCols == 0) return null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Table(
        border: TableBorder.all(color: borderCol, width: 0.5),
        defaultColumnWidth: const FlexColumnWidth(),
        children: _rows.map((row) {
          final cells = List<Widget>.from(row.cells);
          while (cells.length < maxCols) {
            cells.add(Container(
              decoration: BoxDecoration(border: Border.all(color: borderCol, width: 0.5)),
            ));
          }
          return TableRow(children: cells.map((c) => c).toList());
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

  @override
  Widget? build({required Color headerBg, required Color headerFg,
                 required Color labelBg,  required Color borderCol,
                 required Color accentCol}) {
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
  _CellB({required this.isHeader});

  @override
  Widget? build({required Color headerBg, required Color headerFg,
                 required Color labelBg,  required Color borderCol,
                 required Color accentCol}) {
    _flushPending();
    final content = _children.isEmpty
        ? const SizedBox.shrink()
        : _children.length == 1 ? _children.first
        : Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: _children);
    final cell = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      color: isHeader ? const Color(0xFFD0D7DC) : null,
      child: content,
    );
    return _CellWidget(cell);
  }

  @override void addWidget(Widget w) {
    _flushPending();
    _children.add(w);
  }
}

// ─── Lists ────────────────────────────────────────────────────────────────────

class _ListB extends _Builder {
  final bool ordered;
  int _index = 0;
  _ListB({required this.ordered});

  @override void addWidget(Widget w) {
    _index++;
    _children.add(_buildItem(w, _index));
  }

  Widget _buildItem(Widget content, int i) {
    final bullet = ordered ? '$i.' : '•';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 20,
            child: Text(bullet, style: const TextStyle(fontSize: 11))),
        Expanded(child: content),
      ]),
    );
  }

  @override
  Widget? build({required Color headerBg, required Color headerFg,
                 required Color labelBg,  required Color borderCol,
                 required Color accentCol}) {
    if (_children.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: _children),
    );
  }
}

class _ListItemB extends _Builder {
  @override
  Widget? build({required Color headerBg, required Color headerFg,
                 required Color labelBg,  required Color borderCol,
                 required Color accentCol}) {
    _flushPending();
    if (_children.isEmpty) return null;
    return _children.length == 1 ? _children.first
        : Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: _children);
  }
}
