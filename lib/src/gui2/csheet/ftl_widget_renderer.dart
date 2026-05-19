// FtlWidgetSink — streams the FTL evaluator's output directly into Flutter widgets.
//
// Pipeline: .htm.ftl → FTL evaluator → FtlWidgetSink.write() → Widget
// No HTML string is ever materialised; no external HTML parser is used.
//
// CSS handling: the <style> block is captured and parsed. Class attributes
// on HTML elements are resolved against the parsed CSS map, so background
// colours, text colours, font sizes, weights, and borders from the template
// CSS are applied directly to Flutter widget properties.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
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

  // ─── Table cellpadding stack ──────────────────────────────────────────────
  // Each <table> pushes its cellpadding (in logical px); </table> pops.
  // Browser default cellpadding is 1px.
  final _cellPadStack = <double>[1.0];

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

  static String _decodeEntities(String s) {
    var r = s.replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
      final cp = int.tryParse(m.group(1)!);
      return cp != null ? String.fromCharCode(cp) : m.group(0)!;
    });
    r = r.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);', caseSensitive: false), (m) {
      final cp = int.tryParse(m.group(1)!, radix: 16);
      return cp != null ? String.fromCharCode(cp) : m.group(0)!;
    });
    return r
        .replaceAll('&nbsp;', '\u00A0')
        .replaceAll('&nl;',   '\n')
        .replaceAll('&amp;',  '&')
        .replaceAll('&lt;',   '<')
        .replaceAll('&gt;',   '>')
        .replaceAll('&quot;', '"')
        .replaceAll("&apos;", "'");
  }
  // Returns (widthFraction, widthFixed) — at most one is non-null.
  static (double?, double?) _parseCellWidth(String? w) {
    if (w == null || w.isEmpty) return (null, null);
    if (w.endsWith('%')) {
      final f = double.tryParse(w.substring(0, w.length - 1));
      return (f != null ? f / 100.0 : null, null);
    }
    final px = double.tryParse(w);
    return (null, px);
  }

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
        // Class selectors: .ab, .border9, compound .sa-table th → extract each class
        final classRe = RegExp(r'\.([a-zA-Z0-9_-]+)');
        for (final cm in classRe.allMatches(s)) {
          final cls = cm.group(1)!;
          _cssMap[cls] = (_cssMap[cls] ?? _CssStyle()).merge(style);
        }
        // ID selectors: #myid — stored with '#' prefix so class and id namespaces
        // don't collide.  Elements with id="myid" are looked up via _resolveId().
        final idRe = RegExp(r'#([a-zA-Z0-9_-]+)');
        for (final im in idRe.allMatches(s)) {
          final id = '#${im.group(1)!}';
          _cssMap[id] = (_cssMap[id] ?? _CssStyle()).merge(style);
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
    final idAttr     = _attrValue(body, 'id');
    final bgAttr     = _attrValue(body, 'bgcolor');
    final alignAttr  = _attrValue(body, 'align');
    final valignAttr = _attrValue(body, 'valign');

    if (closing) {
      _handleClose(name);
    } else {
      _handleOpen(name, classAttr, idAttr, bgAttr, alignAttr, valignAttr, body);
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

  void _handleOpen(String name, String? classAttr, String? idAttr,
      String? bgColor, String? alignAttr, String? valignAttr, String attrs) {
    // Resolve CSS: class selector first, then id selector (higher specificity).
    var css = _resolve(classAttr);
    if (idAttr != null) {
      final idStyle = _cssMap['#$idAttr'];
      if (idStyle != null) css = css.merge(idStyle);
    }
    // Inline style="..." attribute — higher priority than class styles.
    final styleAttr = _attrValue(attrs, 'style');
    if (styleAttr != null && styleAttr.isNotEmpty) {
      css = css.merge(_CssStyle.parse(styleAttr));
    }
    // Inline bgcolor attribute supplements CSS
    if (bgColor != null && css.bgColor == null) {
      css.bgColor = _CssStyle._parseColor(bgColor);
    }
    // Inline align attribute supplements CSS (HTML align attr = lower priority
    // than an explicit CSS text-align, so only apply when CSS didn't set one).
    if (alignAttr != null && css.textAlign == null) {
      switch (alignAttr.toLowerCase()) {
        case 'center': css.textAlign = TextAlign.center; break;
        case 'right':  css.textAlign = TextAlign.right;  break;
        case 'left':   css.textAlign = TextAlign.left;   break;
      }
    }
    // Inline valign attribute — vertical alignment for cells.
    if (valignAttr != null) {
      switch (valignAttr.toLowerCase()) {
        case 'top':    css.verticalAlign = CrossAxisAlignment.start;  break;
        case 'bottom': css.verticalAlign = CrossAxisAlignment.end;    break;
        case 'middle': css.verticalAlign = CrossAxisAlignment.center; break;
      }
    }

    switch (name) {
      case 'style':
        _styleBuf.clear(); _mode = _Mode.styleCapture; return;
      case 'script':
        _mode = _Mode.skip; _skipUntil = '</script>'; return;
      // Don't skip <head> — the <style> block lives inside it and must be
      // captured so CSS class rules (.ab, .abb, .borderbottom8 etc.) apply.
      case 'html': case 'head': case 'body': case 'meta': case 'link': case 'doctype': return;
      case 'title': _mode = _Mode.skip; _skipUntil = '</title>'; return;

      case 'h1': _stack.add(_Heading(1, css)); return;
      case 'h2': _stack.add(_Heading(2, css)); return;
      case 'h3': _stack.add(_Heading(3, css)); return;
      case 'h4': case 'h5': case 'h6': _stack.add(_Heading(4, css)); return;
      case 'p':   _stack.add(_Para(css)); return;
      case 'div': _stack.add(_Div(css)); return;
      case 'table':
        // border="0" means a layout-only table — no visible cell borders.
        // HTML default for border attribute is 0 (no border). Only apply
        // table-level borders when explicitly requested via border="1" etc.
        // Cell-level borders come from CSS classes (.abb, .abt, .border9…).
        final borderVal = int.tryParse(_attrValue(attrs, 'border') ?? '0') ?? 0;
        final cpAttr   = _attrValue(attrs, 'cellpadding');
        final cp = cpAttr != null ? (double.tryParse(cpAttr) ?? 1.0) : 1.0;
        final csAttr   = _attrValue(attrs, 'cellspacing');
        final cs = csAttr != null ? (double.tryParse(csAttr) ?? 0.0) : 0.0;
        _cellPadStack.add(cp);
        _stack.add(_TableB(css, showBorder: borderVal > 0, cellSpacing: cs));
        return;
      case 'thead': case 'tbody': case 'tfoot': return;
      case 'tr':
        // Auto-close any open row before starting a new one.
        // Browsers implicitly close a <tr> when a new <tr> starts;
        // many PCGen templates (e.g. the feat table) rely on this.
        while (_stack.length > 1 && _top is _RowB) {
          final done = _stack.removeLast();
          final w = done.build();
          if (w != null) _top.addWidget(w);
        }
        _stack.add(_RowB());
        return;
      case 'th':
        // Auto-close any open cell before starting a new one (browser behavior).
        if (_stack.length > 1 && _top is _CellB) {
          final done = _stack.removeLast();
          final w = done.build();
          if (w != null) _top.addWidget(w);
        }
        final csth = int.tryParse(_attrValue(attrs, 'colspan') ?? '') ?? 1;
        final rsth = int.tryParse(_attrValue(attrs, 'rowspan') ?? '') ?? 1;
        final wth  = _parseCellWidth(_attrValue(attrs, 'width'));
        _stack.add(_CellB(isHeader: true,  css: css, colspan: csth, rowspan: rsth,
                          widthFraction: wth.$1, widthFixed: wth.$2,
                          cellPad: _cellPadStack.last));
        return;
      case 'td':
        // Auto-close any open cell before starting a new one (browser behavior).
        if (_stack.length > 1 && _top is _CellB) {
          final done = _stack.removeLast();
          final w = done.build();
          if (w != null) _top.addWidget(w);
        }
        final cstd = int.tryParse(_attrValue(attrs, 'colspan') ?? '') ?? 1;
        final rstd = int.tryParse(_attrValue(attrs, 'rowspan') ?? '') ?? 1;
        final wtd  = _parseCellWidth(_attrValue(attrs, 'width'));
        _stack.add(_CellB(isHeader: false, css: css, colspan: cstd, rowspan: rstd,
                          widthFraction: wtd.$1, widthFixed: wtd.$2,
                          cellPad: _cellPadStack.last));
        return;
      case 'ul':  _stack.add(_ListB(ordered: false)); return;
      case 'ol':  _stack.add(_ListB(ordered: true));  return;
      case 'li':  _stack.add(_ListItemB()); return;
      case 'center': _stack.add(_Div(_CssStyle(), center: true)); return;
      case 'blockquote': _stack.add(_Blockquote(css)); return;

      case 'hr':
        _top.addWidget(const Divider(height: 10, thickness: 1, color: _borderCol));
        return;
      case 'br': _top.addText('\n'); return;

      case 'b': case 'strong': _top.pushStyle(_Style.bold); return;
      case 'i': case 'em':     _top.pushStyle(_Style.italic); return;
      // <u> underline tag — push inline text-decoration
      case 'u':
        _top.pushInline(const _InlineStyle(textDecoration: TextDecoration.underline));
        return;
      // <sup> superscript — push smaller font size (no true baseline shift in Flutter)
      case 'sup':
        _top.pushInline(_InlineStyle(
            fontSize: (_top._inlineFontSize ?? 11.0) * 0.75,
            // Flutter doesn't support superscript baseline offset directly;
            // the smaller size is the best approximation without a custom widget.
        ));
        return;
      case 'sub':
        _top.pushInline(_InlineStyle(fontSize: (_top._inlineFontSize ?? 11.0) * 0.75));
        return;
      // <input> cannot be interactive in Flutter (no JS). Render a placeholder
      // that takes up space so surrounding layout is preserved.
      case 'input': {
        final type = (_attrValue(attrs, 'type') ?? 'text').toLowerCase();
        if (type == 'checkbox') {
          _top.addText('☐'); // ☐
        } else {
          // text / number input — visible empty box
          _top.addWidget(Container(
            width: 60, height: 18,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF888888), width: 1),
            ),
          ));
        }
        return;
      }
      case 'font':
        // Read color= and size= HTML attributes; inline style= already merged above.
        final fontColorAttr = _attrValue(attrs, 'color');
        if (fontColorAttr != null && css.textColor == null) {
          css.textColor = _CssStyle._parseColor(fontColorAttr);
        }
        // <font size="N"> uses an HTML 1-7 scale where 3 = normal (≈12px).
        final fontSizeAttr = _attrValue(attrs, 'size');
        if (fontSizeAttr != null && css.fontSize == null) {
          const fontSizeScale = [8.0, 10.0, 12.0, 14.0, 18.0, 22.0, 26.0];
          final n = int.tryParse(fontSizeAttr.replaceAll('+', '').replaceAll('-', ''));
          if (n != null) {
            final idx = (n - 1).clamp(0, fontSizeScale.length - 1);
            css.fontSize = fontSizeScale[idx];
          }
        }
        _top.pushInline(_InlineStyle.fromCss(css));
        return;
      case 'span':
        _top.pushInline(_InlineStyle.fromCss(css));
        return;
    }
  }

  // ─── Close tags ───────────────────────────────────────────────────────────

  void _handleClose(String name) {
    _flushText();
    switch (name) {
      case 'b': case 'strong': case 'i': case 'em':
        // Flush before the style is popped so the text is captured with the
        // correct bold/italic state rather than at build() time when it's gone.
        _top._flushPending(); _top.popStyle(); return;
      case 'font': case 'span': case 'u': case 'sup': case 'sub':
        // Flush before popping so inline colour/size/weight apply to the text.
        _top._flushPending(); _top.popInline(); return;

      case 'h1': case 'h2': case 'h3': case 'h4': case 'h5': case 'h6':
      case 'p': case 'div': case 'center': case 'blockquote':
      case 'tr':
        // Auto-close any open cell before closing the row.
        if (_stack.length > 1 && _top is _CellB) {
          final done = _stack.removeLast();
          final w = done.build();
          if (w != null) _top.addWidget(w);
        }
        if (_stack.length > 1) {
          final done = _stack.removeLast();
          final w = done.build();
          if (w != null) _top.addWidget(w);
        }
        return;
      case 'th': case 'td':
      case 'ul': case 'ol': case 'li':
        if (_stack.length > 1) {
          final done = _stack.removeLast();
          final w = done.build();
          if (w != null) _top.addWidget(w);
        }
        return;
      case 'table':
        // Unwind any unclosed rows before building the table.
        while (_stack.length > 1 && _top is _RowB) {
          final done = _stack.removeLast();
          final w = done.build();
          if (w != null) _top.addWidget(w);
        }
        if (_stack.length > 1) {
          final done = _stack.removeLast();
          final w = done.build();
          if (w != null) _top.addWidget(w);
        }
        if (_cellPadStack.length > 1) _cellPadStack.removeLast();
        return;
      case 'html': case 'body': case 'head':
      case 'meta': case 'link': case 'title':
      case 'thead': case 'tbody': case 'tfoot':
      case 'br': case 'hr': case 'a': case 'img': case 'input': return;
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
    // Enforce a minimum content width so Expanded(flex) rows have enough room.
    // Row(Expanded) needs a bounded parent width; SizedBox provides that.
    // If the panel is narrower than minW, wrap in a horizontal scroll.
    return ColoredBox(
      color: Colors.white,
      child: LayoutBuilder(builder: (context, constraints) {
        const minW = 900.0;
        final panelW = constraints.maxWidth.isFinite ? constraints.maxWidth : minW;
        final contentW = panelW < minW ? minW : panelW;
        final inner = SizedBox(
          width: contentW,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: rootWidget ?? const SizedBox.shrink(),
          ),
        );
        return contentW > panelW
            ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: inner)
            : inner;
      }),
    );
  }
}

// ─── Parser modes ─────────────────────────────────────────────────────────────

enum _Mode { normal, tag, comment, skip, styleCapture }
enum _Style { bold, italic }

// ─── CSS style model ──────────────────────────────────────────────────────────

class _CssStyle {
  // ── Text / font ────────────────────────────────────────────────────────────
  Color?       textColor;
  Color?       bgColor;
  double?      fontSize;        // logical pixels
  FontWeight?  fontWeight;
  FontStyle?   fontStyle;       // italic / normal
  TextDecoration? textDecoration; // underline, line-through, overline
  TextAlign?   textAlign;
  String?      fontFamily;
  bool         uppercase  = false;
  bool         capitalize = false;
  bool         smallCaps  = false;
  double?      textIndent;   // first-line indent in logical pixels
  double?      lineHeight;      // multiplier of font size (TextStyle.height)
  double?      letterSpacing;   // logical pixels between characters
  double?      wordSpacing;     // logical pixels between words

  // ── Box / border ──────────────────────────────────────────────────────────
  BoxBorder?   border;
  BorderSide?  borderTop;
  BorderSide?  borderBottom;
  BorderSide?  borderLeft;
  BorderSide?  borderRight;
  double?      borderRadius;    // uniform border-radius in logical pixels

  // ── Spacing ───────────────────────────────────────────────────────────────
  // CSS padding/margin on block elements (div, p, li, heading).
  // Cells use cellpadding from the table; CSS padding overrides it when set.
  EdgeInsets?  padding;
  EdgeInsets?  margin;

  // ── Sizing ────────────────────────────────────────────────────────────────
  double?      width;           // explicit width for block elements (px)
  double?      height;          // explicit height for block elements (px)
  double?      minWidth;
  double?      maxWidth;
  double?      minHeight;
  double?      maxHeight;

  // ── Visibility / behaviour ────────────────────────────────────────────────
  CrossAxisAlignment verticalAlign = CrossAxisAlignment.center;
  bool         displayed = true;   // false → display:none
  bool         hidden    = false;  // true  → visibility:hidden (space kept)
  bool         noWrap    = false;  // white-space:nowrap
  double?      opacity;            // 0.0–1.0

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
        // ── colour ─────────────────────────────────────────────────────────
        case 'color':            s.textColor  = _parseColor(val); break;
        case 'background':
        case 'background-color': s.bgColor    = _parseColor(val); break;

        // ── font ───────────────────────────────────────────────────────────
        case 'font-size':  s.fontSize = _parseFontSize(val); break;
        case 'font-weight':
          final fw = int.tryParse(val);
          if (fw != null) {
            s.fontWeight = fw >= 600 ? FontWeight.bold : FontWeight.normal;
          } else if (val.contains('bold')) {
            s.fontWeight = FontWeight.bold;
          } else if (val == 'normal' || val == 'lighter') {
            s.fontWeight = FontWeight.normal;
          }
          break;
        case 'font-style':
          if (val.contains('italic') || val.contains('oblique'))
            s.fontStyle = FontStyle.italic;
          else if (val == 'normal')
            s.fontStyle = FontStyle.normal;
          break;
        case 'font-family':
          s.fontFamily = val.split(',').first.trim()
              .replaceAll("'", '').replaceAll('"', ''); break;
        case 'font-variant':
          if (val.contains('small-caps')) s.smallCaps = true; break;
        case 'font':
          // shorthand: e.g. "bold 12px Arial" — extract what we can
          final fparts = val.split(RegExp(r'\s+'));
          for (final fp in fparts) {
            final sz = _parseFontSize(fp);
            if (sz != null) { s.fontSize = sz; continue; }
            if (fp.contains('bold')) { s.fontWeight = FontWeight.bold; continue; }
            if (fp == 'italic' || fp == 'oblique') s.fontStyle = FontStyle.italic;
          }
          break;
        case 'line-height':
          // store raw value; applied relative to font-size at render time
          final lh = _parseLength(val) ?? (double.tryParse(val));
          if (lh != null) s.lineHeight = lh; break;
        case 'letter-spacing': s.letterSpacing = _parseLength(val); break;
        case 'word-spacing':   s.wordSpacing   = _parseLength(val); break;

        // ── text decoration ────────────────────────────────────────────────
        case 'text-decoration':
        case 'text-decoration-line':
          if (val.contains('underline'))    s.textDecoration = TextDecoration.underline;
          else if (val.contains('line-through')) s.textDecoration = TextDecoration.lineThrough;
          else if (val.contains('overline'))  s.textDecoration = TextDecoration.overline;
          else if (val == 'none')             s.textDecoration = TextDecoration.none;
          break;
        case 'text-align':
          switch (val.trim()) {
            case 'center': s.textAlign = TextAlign.center; break;
            case 'right':  s.textAlign = TextAlign.right;  break;
            case 'left':   s.textAlign = TextAlign.left;   break;
            case 'justify': s.textAlign = TextAlign.justify; break;
          }
          break;
        case 'text-transform':
          if (val.contains('uppercase')) s.uppercase = true;
          else if (val.contains('capitalize')) s.capitalize = true; break;
        case 'text-indent':
          s.textIndent = _parseLength(val); break;
        case 'page-break-after': case 'page-break-before': case 'page-break-inside':
          break; // printing concept — no-op in Flutter

        // ── border ─────────────────────────────────────────────────────────
        case 'border':
          s.border = _parseBorder(val); break;
        case 'border-top':
          s.borderTop    = _parseBorderSide(val); break;
        case 'border-bottom':
          s.borderBottom = _parseBorderSide(val); break;
        case 'border-left':
          s.borderLeft   = _parseBorderSide(val); break;
        case 'border-right':
          s.borderRight  = _parseBorderSide(val); break;
        case 'border-top-width':
          s.borderTop    = _updateSideWidth(s.borderTop,    _parseLength(val) ?? 1); break;
        case 'border-bottom-width':
          s.borderBottom = _updateSideWidth(s.borderBottom, _parseLength(val) ?? 1); break;
        case 'border-left-width':
          s.borderLeft   = _updateSideWidth(s.borderLeft,   _parseLength(val) ?? 1); break;
        case 'border-right-width':
          s.borderRight  = _updateSideWidth(s.borderRight,  _parseLength(val) ?? 1); break;
        case 'border-top-color':
          s.borderTop    = _updateSideColor(s.borderTop,    _parseColor(val)); break;
        case 'border-bottom-color':
          s.borderBottom = _updateSideColor(s.borderBottom, _parseColor(val)); break;
        case 'border-left-color':
          s.borderLeft   = _updateSideColor(s.borderLeft,   _parseColor(val)); break;
        case 'border-right-color':
          s.borderRight  = _updateSideColor(s.borderRight,  _parseColor(val)); break;
        case 'border-top-style':
          s.borderTop    ??= const BorderSide(); break;
        case 'border-bottom-style':
          s.borderBottom ??= const BorderSide(); break;
        case 'border-left-style':
          s.borderLeft   ??= const BorderSide(); break;
        case 'border-right-style':
          s.borderRight  ??= const BorderSide(); break;
        case 'border-radius':
          s.borderRadius = _parseLength(val); break;
        case 'border-top-left-radius':
        case 'border-top-right-radius':
        case 'border-bottom-left-radius':
        case 'border-bottom-right-radius':
          // individual corners: use the largest value as uniform radius
          final cr = _parseLength(val);
          if (cr != null && (s.borderRadius == null || cr > s.borderRadius!))
            s.borderRadius = cr;
          break;
        case 'border-collapse':
          // 'collapse' is the typical sheet default — no special action needed
          // since we draw borders per-cell rather than via table spacing.
          break;

        // ── spacing (padding / margin) ─────────────────────────────────────
        case 'padding':       s.padding = _parseSpacing(val); break;
        case 'padding-top':
          final pt = _parseLength(val);
          if (pt != null) s.padding = (s.padding ?? EdgeInsets.zero).copyWith(top: pt);
          break;
        case 'padding-bottom':
          final pb = _parseLength(val);
          if (pb != null) s.padding = (s.padding ?? EdgeInsets.zero).copyWith(bottom: pb);
          break;
        case 'padding-left':
          final pl = _parseLength(val);
          if (pl != null) s.padding = (s.padding ?? EdgeInsets.zero).copyWith(left: pl);
          break;
        case 'padding-right':
          final pr = _parseLength(val);
          if (pr != null) s.padding = (s.padding ?? EdgeInsets.zero).copyWith(right: pr);
          break;
        case 'margin':        s.margin  = _parseSpacing(val); break;
        case 'margin-top':
          final mt = _parseLength(val);
          if (mt != null) s.margin = (s.margin ?? EdgeInsets.zero).copyWith(top: mt);
          break;
        case 'margin-bottom':
          final mb = _parseLength(val);
          if (mb != null) s.margin = (s.margin ?? EdgeInsets.zero).copyWith(bottom: mb);
          break;
        case 'margin-left':
          final ml = _parseLength(val);
          if (ml != null) s.margin = (s.margin ?? EdgeInsets.zero).copyWith(left: ml);
          break;
        case 'margin-right':
          final mr = _parseLength(val);
          if (mr != null) s.margin = (s.margin ?? EdgeInsets.zero).copyWith(right: mr);
          break;

        // ── sizing ─────────────────────────────────────────────────────────
        case 'width':      s.width     = _parseLength(val); break;
        case 'height':     s.height    = _parseLength(val); break;
        case 'min-width':  s.minWidth  = _parseLength(val); break;
        case 'max-width':  s.maxWidth  = _parseLength(val); break;
        case 'min-height': s.minHeight = _parseLength(val); break;
        case 'max-height': s.maxHeight = _parseLength(val); break;

        // ── visibility / layout ────────────────────────────────────────────
        case 'display':
          if (val.trim() == 'none') s.displayed = false; break;
        case 'visibility':
          if (val.trim() == 'hidden') s.hidden = true; break;
        case 'opacity':
          s.opacity = double.tryParse(val); break;
        case 'white-space':
          if (val.contains('nowrap')) s.noWrap = true; break;
        case 'vertical-align':
          switch (val.trim()) {
            case 'top':    s.verticalAlign = CrossAxisAlignment.start;  break;
            case 'bottom': s.verticalAlign = CrossAxisAlignment.end;    break;
            default:       s.verticalAlign = CrossAxisAlignment.center; break;
          }
          break;

        // ── box-shadow ─────────────────────────────────────────────────────
        // Parsed but not rendered — stored as a no-op to avoid log noise.
        case 'box-shadow':
        case 'text-shadow':
        case 'outline':
        case 'cursor':
        case 'list-style':
        case 'list-style-type':
        case 'float':
        case 'clear':
        case 'overflow':
        case 'position':
        case 'top': case 'left': case 'right': case 'bottom':
        case 'z-index':
        case 'background-image':
        case 'background-repeat':
        case 'background-position':
        case 'background-size':
        case 'transition':
        case 'animation':
        case 'transform':
        case 'content':
          break; // recognised but not implemented in Flutter layout
      }
    }
    return s;
  }

  /// Effective border: full `border` takes precedence; fall back to
  /// assembling from individual sides.
  BoxBorder? get effectiveBorder {
    if (border != null) return border;
    if (borderTop == null && borderBottom == null &&
        borderLeft == null && borderRight == null) return null;
    return Border(
      top:    borderTop    ?? BorderSide.none,
      bottom: borderBottom ?? BorderSide.none,
      left:   borderLeft   ?? BorderSide.none,
      right:  borderRight  ?? BorderSide.none,
    );
  }

  BorderRadius? get effectiveBorderRadius =>
      borderRadius != null ? BorderRadius.circular(borderRadius!) : null;

  /// Merge [other] into this, with [other] taking precedence for non-null/set values.
  _CssStyle merge(_CssStyle other) {
    final m = _CssStyle();
    m.textColor      = other.textColor      ?? textColor;
    m.bgColor        = other.bgColor        ?? bgColor;
    m.fontSize       = other.fontSize       ?? fontSize;
    m.fontWeight     = other.fontWeight     ?? fontWeight;
    m.fontStyle      = other.fontStyle      ?? fontStyle;
    m.textDecoration = other.textDecoration ?? textDecoration;
    m.textAlign      = other.textAlign      ?? textAlign;
    m.fontFamily     = other.fontFamily     ?? fontFamily;
    m.uppercase      = other.uppercase      || uppercase;
    m.capitalize     = other.capitalize     || capitalize;
    m.smallCaps      = other.smallCaps      || smallCaps;
    m.textIndent     = other.textIndent     ?? textIndent;
    m.lineHeight     = other.lineHeight     ?? lineHeight;
    m.letterSpacing  = other.letterSpacing  ?? letterSpacing;
    m.wordSpacing    = other.wordSpacing    ?? wordSpacing;
    m.border         = other.border         ?? border;
    m.borderTop      = other.borderTop      ?? borderTop;
    m.borderBottom   = other.borderBottom   ?? borderBottom;
    m.borderLeft     = other.borderLeft     ?? borderLeft;
    m.borderRight    = other.borderRight    ?? borderRight;
    m.borderRadius   = other.borderRadius   ?? borderRadius;
    m.padding        = other.padding        ?? padding;
    m.margin         = other.margin         ?? margin;
    m.width          = other.width          ?? width;
    m.height         = other.height         ?? height;
    m.minWidth       = other.minWidth       ?? minWidth;
    m.maxWidth       = other.maxWidth       ?? maxWidth;
    m.minHeight      = other.minHeight      ?? minHeight;
    m.maxHeight      = other.maxHeight      ?? maxHeight;
    m.verticalAlign  = other.verticalAlign != CrossAxisAlignment.center
        ? other.verticalAlign : verticalAlign;
    m.displayed      = other.displayed      && displayed;
    m.hidden         = other.hidden         || hidden;
    m.noWrap         = other.noWrap         || noWrap;
    m.opacity        = other.opacity        ?? opacity;
    return m;
  }

  bool get isEmpty => textColor == null && bgColor == null && fontSize == null &&
      fontWeight == null && textAlign == null && border == null &&
      borderTop == null && borderBottom == null &&
      borderLeft == null && borderRight == null;

  /// Build a Flutter TextStyle from this CSS style.
  /// [fallbackColor] is used when no explicit text colour is set.
  /// [baseFontSize] is the containing element's font size, used to resolve
  /// line-height as a multiplier.
  TextStyle? toTextStyle({Color? fallbackColor, double baseFontSize = 14.0}) {
    if (textColor == null && fontSize == null && fontWeight == null &&
        fontFamily == null && !smallCaps && fontStyle == null &&
        textDecoration == null && lineHeight == null &&
        letterSpacing == null && wordSpacing == null) return null;
    double? height;
    if (lineHeight != null) {
      // Unitless line-height is already a multiplier; px/pt values need dividing.
      height = lineHeight! > 10 ? lineHeight! / baseFontSize : lineHeight;
    }
    return TextStyle(
      color:         textColor ?? fallbackColor,
      fontSize:      fontSize,
      fontWeight:    fontWeight,
      fontStyle:     fontStyle,
      fontFamily:    fontFamily,
      decoration:    textDecoration,
      height:        height,
      letterSpacing: letterSpacing,
      wordSpacing:   wordSpacing,
      fontFeatures:  smallCaps ? [const FontFeature.enable('smcp')] : null,
    );
  }

  /// Wrap [child] with opacity/visibility constraints from this style.
  Widget applyVisibility(Widget child) {
    if (hidden) return Opacity(opacity: 0, child: child);
    if (opacity != null && opacity! < 1.0) return Opacity(opacity: opacity!, child: child);
    return child;
  }

  /// Wrap [child] with box constraints derived from width/height/min/max.
  Widget applyConstraints(Widget child) {
    final hasConstraints = width != null || height != null ||
        minWidth != null || maxWidth != null ||
        minHeight != null || maxHeight != null;
    if (!hasConstraints) return child;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth:  minWidth  ?? 0,
        maxWidth:  maxWidth  ?? double.infinity,
        minHeight: minHeight ?? (height ?? 0),
        maxHeight: maxHeight ?? (height ?? double.infinity),
      ),
      child: width != null ? SizedBox(width: width, child: child) : child,
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
      'darkgrey': Color(0xFFA9A9A9), 'silver': Color(0xFFC0C0C0),
      'navy': Color(0xFF000080), 'maroon': Color(0xFF800000),
      'purple': Color(0xFF800080), 'teal': Color(0xFF008080),
      'olive': Color(0xFF808000), 'lime': Color(0xFF00FF00),
      'aqua': Color(0xFF00FFFF), 'cyan': Color(0xFF00FFFF),
      'fuchsia': Color(0xFFFF00FF), 'magenta': Color(0xFFFF00FF),
      'yellow': Color(0xFFFFFF00), 'orange': Color(0xFFFFA500),
      'coral': Color(0xFFFF7F50), 'salmon': Color(0xFFFA8072),
      'gold': Color(0xFFFFD700), 'khaki': Color(0xFFF0E68C),
      'beige': Color(0xFFF5F5DC), 'ivory': Color(0xFFFFFFF0),
      'lavender': Color(0xFFE6E6FA), 'pink': Color(0xFFFFC0CB),
      'tan': Color(0xFFD2B48C), 'brown': Color(0xFFA52A2A),
      'indigo': Color(0xFF4B0082), 'violet': Color(0xFFEE82EE),
      'crimson': Color(0xFFDC143C), 'darkred': Color(0xFF8B0000),
      'darkblue': Color(0xFF00008B), 'darkgreen': Color(0xFF006400),
      'lightyellow': Color(0xFFFFFFE0), 'lightblue': Color(0xFFADD8E6),
      'lightgreen': Color(0xFF90EE90), 'lightpink': Color(0xFFFFB6C1),
      'whitesmoke': Color(0xFFF5F5F5), 'gainsboro': Color(0xFFDCDCDC),
      'transparent': Color(0x00000000),
    };
    if (named.containsKey(v)) return named[v];
    // rgb(r, g, b)
    final rgbMatch = RegExp(r'^rgb\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)$')
        .firstMatch(v);
    if (rgbMatch != null) {
      final r = int.tryParse(rgbMatch.group(1)!) ?? 0;
      final g = int.tryParse(rgbMatch.group(2)!) ?? 0;
      final b = int.tryParse(rgbMatch.group(3)!) ?? 0;
      return Color.fromARGB(255, r, g, b);
    }
    // rgba(r, g, b, a)
    final rgbaMatch = RegExp(
            r'^rgba\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d.]+)\s*\)$')
        .firstMatch(v);
    if (rgbaMatch != null) {
      final r = int.tryParse(rgbaMatch.group(1)!) ?? 0;
      final g = int.tryParse(rgbaMatch.group(2)!) ?? 0;
      final b = int.tryParse(rgbaMatch.group(3)!) ?? 0;
      final a = (double.tryParse(rgbaMatch.group(4)!) ?? 1.0).clamp(0.0, 1.0);
      return Color.fromARGB((a * 255).round(), r, g, b);
    }
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
      if (hex.length == 8) {
        final a = int.tryParse(hex.substring(0, 2), radix: 16) ?? 255;
        final r = int.tryParse(hex.substring(2, 4), radix: 16) ?? 0;
        final g = int.tryParse(hex.substring(4, 6), radix: 16) ?? 0;
        final b = int.tryParse(hex.substring(6, 8), radix: 16) ?? 0;
        return Color.fromARGB(a, r, g, b);
      }
    }
    return null;
  }

  static double? _parseFontSize(String val) {
    const keywords = {
      'xx-small': 8.0, 'x-small': 10.0, 'small': 12.0,
      'medium': 14.0,  'large': 18.0,    'x-large': 22.0,
      'xx-large': 26.0, 'smaller': 11.0, 'larger': 16.0,
    };
    final v = val.trim().toLowerCase();
    if (keywords.containsKey(v)) return keywords[v];
    return _parseLength(v);
  }

  /// Parse a CSS length value to logical pixels.
  static double? _parseLength(String val) {
    final v = val.trim().toLowerCase();
    if (v == '0') return 0;
    if (v == 'auto') return null;
    final ptMatch = RegExp(r'^([\d.]+)pt$').firstMatch(v);
    if (ptMatch != null) return (double.tryParse(ptMatch.group(1)!) ?? 0) * 1.333;
    final pxMatch = RegExp(r'^([\d.]+)px$').firstMatch(v);
    if (pxMatch != null) return double.tryParse(pxMatch.group(1)!);
    final emMatch = RegExp(r'^([\d.]+)em$').firstMatch(v);
    if (emMatch != null) return (double.tryParse(emMatch.group(1)!) ?? 1) * 14.0;
    final remMatch = RegExp(r'^([\d.]+)rem$').firstMatch(v);
    if (remMatch != null) return (double.tryParse(remMatch.group(1)!) ?? 1) * 14.0;
    // Unitless number (e.g. for line-height)
    return double.tryParse(v);
  }

  /// Parse a CSS spacing shorthand (1–4 values) to EdgeInsets.
  static EdgeInsets? _parseSpacing(String val) {
    final v = val.trim().toLowerCase();
    if (v == '0') return EdgeInsets.zero;
    final parts = v.split(RegExp(r'\s+')).where((p) => p != 'auto').toList();
    if (parts.isEmpty) return EdgeInsets.zero;
    double? p(String s) => _parseLength(s);
    if (parts.length == 1) {
      final n = p(parts[0]); return n != null ? EdgeInsets.all(n) : null;
    }
    if (parts.length == 2) {
      final v1 = p(parts[0]); final h1 = p(parts[1]);
      return (v1 != null && h1 != null)
          ? EdgeInsets.symmetric(vertical: v1, horizontal: h1) : null;
    }
    if (parts.length == 3) {
      final t = p(parts[0]); final h1 = p(parts[1]); final b = p(parts[2]);
      return (t != null && h1 != null && b != null)
          ? EdgeInsets.only(top: t, left: h1, right: h1, bottom: b) : null;
    }
    final t = p(parts[0]); final r = p(parts[1]);
    final b = p(parts[2]); final l = p(parts[3]);
    return (t != null && r != null && b != null && l != null)
        ? EdgeInsets.only(top: t, right: r, bottom: b, left: l) : null;
  }

  static BorderSide _updateSideWidth(BorderSide? existing, double width) {
    if (existing == null || existing == BorderSide.none) return BorderSide(width: width);
    return existing.copyWith(width: width);
  }

  static BorderSide _updateSideColor(BorderSide? existing, Color? color) {
    if (color == null) return existing ?? const BorderSide();
    if (existing == null || existing == BorderSide.none) return BorderSide(color: color);
    return existing.copyWith(color: color);
  }

  static BoxBorder? _parseBorder(String val) {
    final side = _parseBorderSide(val);
    if (side == null) return null;
    return Border.fromBorderSide(side);
  }

  static BorderSide? _parseBorderSide(String val) {
    // e.g. "1px solid black"  "1pt solid #aaa"  "5px solid lightgray"  "none"
    final v = val.trim().toLowerCase();
    if (v == 'none' || v == '0') return BorderSide.none;
    final parts = v.split(RegExp(r'\s+'));
    if (parts.isEmpty) return null;
    final widthStr = parts[0];
    final color    = parts.length >= 3 ? _parseColor(parts[2]) : null;
    double width = 1;
    final wm = RegExp(r'^([\d.]+)(?:px|pt)?$').firstMatch(widthStr);
    if (wm != null) width = double.tryParse(wm.group(1)!) ?? 1;
    return BorderSide(
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

// ─── Inline style record (pushed by <font> and <span>) ───────────────────────

class _InlineStyle {
  final Color?          color;
  final double?         fontSize;
  final FontWeight?     fontWeight;
  final FontStyle?      fontStyle;
  final TextDecoration? textDecoration;
  final double?         letterSpacing;
  const _InlineStyle({this.color, this.fontSize, this.fontWeight,
      this.fontStyle, this.textDecoration, this.letterSpacing});

  static _InlineStyle fromCss(_CssStyle css) => _InlineStyle(
    color:         css.textColor,
    fontSize:      css.fontSize,
    fontWeight:    css.fontWeight,
    fontStyle:     css.fontStyle,
    textDecoration: css.textDecoration,
    letterSpacing: css.letterSpacing,
  );
}

// ─── Builder base ──────────────────────────────────────────────────────────────

abstract class _Builder {
  final _textBuf     = StringBuffer();
  final _children    = <Widget>[];
  final _styles      = <_Style>[];
  // Always paired: every pushInline has a corresponding popInline so stacks
  // stay in sync even when individual fields are null.
  final _inlineStack = <_InlineStyle>[];

  void addText(String t) => _textBuf.write(t);

  void addWidget(Widget w) {
    _flushPending();
    _children.add(w);
  }

  void pushStyle(_Style s) => _styles.add(s);
  void popStyle()  { if (_styles.isNotEmpty) _styles.removeLast(); }

  void pushInline(_InlineStyle s) => _inlineStack.add(s);
  void popInline() { if (_inlineStack.isNotEmpty) _inlineStack.removeLast(); }

  // Resolve inline style properties by scanning the stack top-to-bottom.
  Color?          get _inlineColor     => _inlineStack.lastWhereOrNull((s) => s.color     != null)?.color;
  double?         get _inlineFontSize  => _inlineStack.lastWhereOrNull((s) => s.fontSize  != null)?.fontSize;
  FontWeight?     get _inlineFontWt    => _inlineStack.lastWhereOrNull((s) => s.fontWeight != null)?.fontWeight;
  FontStyle?      get _inlineFontStyle => _inlineStack.lastWhereOrNull((s) => s.fontStyle != null)?.fontStyle;
  TextDecoration? get _inlineDecor     => _inlineStack.lastWhereOrNull((s) => s.textDecoration != null)?.textDecoration;
  double?         get _inlineLetterSp  => _inlineStack.lastWhereOrNull((s) => s.letterSpacing != null)?.letterSpacing;

  void _flushPending() {
    // Collapse horizontal whitespace but preserve \n from <br> tags.
    final t = _textBuf.toString()
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r' *\n *'), '\n')
        .trim();
    _textBuf.clear();
    if (t.isEmpty) return;
    final bold   = _styles.contains(_Style.bold)   || _inlineFontWt    == FontWeight.bold;
    final italic = _styles.contains(_Style.italic)  || _inlineFontStyle == FontStyle.italic;
    _children.add(Text(t, style: TextStyle(
        fontSize:      _inlineFontSize,
        fontWeight:    bold   ? FontWeight.bold   : _inlineFontWt,
        fontStyle:     italic ? FontStyle.italic  : _inlineFontStyle,
        decoration:    _inlineDecor,
        letterSpacing: _inlineLetterSp,
        color:         _inlineColor)));
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
    if (!css.displayed) return null;
    final t = _children.whereType<Text>().map((w) => w.data ?? '').join(' ').trim();
    if (t.isEmpty) return null;

    final bg  = css.bgColor;
    final fg  = css.textColor ?? (bg != null ? Colors.white : null);
    final fs  = css.fontSize ?? (level == 1 ? 16.0 : level == 2 ? 13.0 : 11.0);

    Widget w = Container(
      margin:  css.margin  ?? const EdgeInsets.only(top: 8, bottom: 2),
      padding: css.padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? (level <= 3 ? const Color(0xFF37474F) : null),
        borderRadius: css.effectiveBorderRadius,
      ),
      child: Text(t, style: TextStyle(
          fontSize: fs, fontWeight: FontWeight.bold,
          fontStyle: css.fontStyle,
          decoration: css.textDecoration,
          color: fg ?? Colors.white)),
    );
    return css.applyVisibility(w);
  }
}

class _Para extends _Builder {
  final _CssStyle css;
  _Para(this.css);
  @override Widget? build() {
    _flushPending();
    if (!css.displayed) return null;
    if (_children.isEmpty) return null;
    final single = _children.length == 1 && _children.first is Text
        ? (_children.first as Text).data?.trim() ?? '' : '';
    if (single.isEmpty && _children.length == 1 && _children.first is Text) return null;
    Widget content = _children.length == 1
        ? _children.first
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: _children);
    // text-indent: indent only the first line by wrapping in a Padding
    if (css.textIndent != null && css.textIndent! > 0) {
      content = Padding(
          padding: EdgeInsets.only(left: css.textIndent!), child: content);
    }
    final innerPad = css.padding;
    if (css.bgColor != null || innerPad != null) {
      content = Container(
          color: css.bgColor,
          padding: innerPad ?? const EdgeInsets.all(2),
          child: content);
    }
    content = css.applyVisibility(content);
    content = css.applyConstraints(content);
    final outerPad = css.margin ?? const EdgeInsets.symmetric(vertical: 2);
    return Padding(padding: outerPad, child: content);
  }
}

class _Div extends _Builder {
  final _CssStyle css;
  final bool center;
  _Div(this.css, {this.center = false});
  @override Widget? build() {
    _flushPending();
    if (!css.displayed) return null;
    if (_children.isEmpty) return null;
    Widget col = Column(
        crossAxisAlignment:
            center ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
        children: _children);
    if (css.bgColor != null || css.padding != null) {
      col = Container(
          color: css.bgColor,
          padding: css.padding,
          child: col);
    }
    if (css.margin != null) col = Padding(padding: css.margin!, child: col);
    col = css.applyVisibility(col);
    col = css.applyConstraints(col);
    return center ? Center(child: col) : col;
  }
}

String _toTitleCase(String s) => s.replaceAllMapped(
    RegExp(r'\b\w'), (m) => m.group(0)!.toUpperCase());

class _Blockquote extends _Builder {
  final _CssStyle css;
  _Blockquote(this.css);
  @override Widget? build() {
    _flushPending();
    if (!css.displayed) return null;
    if (_children.isEmpty) return null;
    Widget col = Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: _children);
    if (css.bgColor != null) {
      col = Container(color: css.bgColor, child: col);
    }
    col = css.applyVisibility(col);
    return Container(
      margin: css.margin ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      padding: css.padding ?? const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: css.effectiveBorder ??
            const Border(left: BorderSide(color: Color(0xFFB0BEC5), width: 3)),
      ),
      child: col,
    );
  }
}

// ─── Table ─────────────────────────────────────────────────────────────────────

// Carries a rendered cell widget together with its colspan/rowspan/width hints.
class _CellData {
  final Widget widget;
  final int colspan;
  final int rowspan;
  final double? widthFraction; // from width="XX%"  (0–1)
  final double? widthFixed;    // from width="XX"    (logical px)
  final bool hasContent;       // false for spacer cells (only <br> or empty)
  const _CellData(this.widget, {this.colspan = 1, this.rowspan = 1,
                                 this.widthFraction, this.widthFixed,
                                 this.hasContent = true});
}

// A cell after the HTML placement algorithm has been run.
class _PlacedCell {
  final _CellData cell;
  final int row;
  final int col;
  const _PlacedCell(this.cell, this.row, this.col);
}

class _TableB extends _Builder {
  final _CssStyle css;
  final bool showBorder;
  final double cellSpacing;
  final _rows = <_RowB>[];
  _TableB(this.css, {this.showBorder = true, this.cellSpacing = 0.0});

  @override void addWidget(Widget w) {
    if (w is _RowWidget) _rows.add(w.row);
  }

  static const _bc = Color(0xFFB0BEC5);

  // Use the flex-row path when a content-bearing cell spans multiple columns
  // or rows, OR when cells carry percentage-width hints. Spacer cells
  // (hasContent=false) are ignored for spanning — they never need true
  // spanning behaviour, but percentage widths still matter for layout.
  bool get _hasColspanOrRowspan =>
      _rows.any((r) => r.cells.any((c) =>
          (c.colspan > 1 || c.rowspan > 1) && c.hasContent));

  bool get _hasPercentWidths =>
      _rows.any((r) => r.cells.any((c) => c.widthFraction != null));

  @override Widget? build() {
    if (_rows.isEmpty) return null;
    Widget child = (_hasColspanOrRowspan || _hasPercentWidths)
        ? _buildFlexRows() : _buildFlutterTable();
    // cellspacing: wrap each row in a small gap (approximated as padding on the table)
    if (cellSpacing > 0) {
      child = Padding(
          padding: EdgeInsets.all(cellSpacing / 2),
          child: child);
    }
    // Layout tables (border="0") get no padding or bottom margin.
    return showBorder
        ? Padding(padding: const EdgeInsets.only(bottom: 6), child: child)
        : child;
  }

  // ── Path 1: Flutter Table (no colspan, no rowspan) ─────────────────────
  // IntrinsicColumnWidth sizes every column to its widest content.
  // We intentionally ignore pixel width hints from the template — values
  // like width="25" are browser rendering hints that are too narrow for
  // Flutter's layout model and cause character-by-character wrapping.
  Widget _buildFlutterTable() {
    final maxCols = _rows.fold(0, (m, r) => r.cells.length > m ? r.cells.length : m);
    if (maxCols == 0) return const SizedBox.shrink();

    return Table(
      border: showBorder ? TableBorder.all(color: _bc, width: 0.5) : null,
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: _rows.map((row) {
        var cells = row.cells.map((c) => c.widget).toList();
        while (cells.length < maxCols) {
          cells.add(Container(
              decoration: BoxDecoration(border: Border.all(color: _bc, width: 0.5))));
        }
        return TableRow(children: cells);
      }).toList(),
    );
  }

  // ── Path 2: Column of Rows with Expanded (colspan or rowspan present) ──
  // Runs the HTML cell-placement algorithm then builds each visual row as a
  // Row with Expanded(flex) children. Rowspan cells appear in their starting
  // row; subsequent rows get transparent placeholders so columns align.
  //
  // Uses Expanded (not LayoutBuilder, not SizedBox) so no intrinsic-
  // dimension calls are made — safe inside any parent widget.
  Widget _buildFlexRows() {
    // ── HTML cell-placement ────────────────────────────────────────────────
    final placed = <_PlacedCell>[];
    final occupied = <(int, int)>{};

    for (int ri = 0; ri < _rows.length; ri++) {
      int ci = 0;
      for (final cell in _rows[ri].cells) {
        while (occupied.contains((ri, ci))) ci++;
        placed.add(_PlacedCell(cell, ri, ci));
        for (int r = ri; r < ri + cell.rowspan; r++) {
          for (int c = ci; c < ci + cell.colspan; c++) {
            occupied.add((r, c));
          }
        }
        ci += cell.colspan;
      }
    }
    if (placed.isEmpty) return const SizedBox.shrink();

    final totalCols = placed.fold(0, (m, p) {
      final end = p.col + p.cell.colspan;
      return end > m ? end : m;
    });
    final totalRows = placed.fold(0, (m, p) {
      final end = p.row + p.cell.rowspan;
      return end > m ? end : m;
    });

    // ── Global per-column flex ─────────────────────────────────────────────
    // Every row uses the SAME colFlex array so that column boundaries align
    // horizontally across rows even when colspan/rowspan are present.
    //
    // Percentage mode (any cell has widthFraction): derive all columns from %
    // widths; unset columns get an equal share of 1000 units.
    // Pixel mode: use widthFixed values or fall back to 1 per column.
    final hasPercent = placed.any((p) => p.cell.widthFraction != null);
    final colFlex = List<int>.filled(totalCols, 0);
    if (hasPercent) {
      // Pass 1: single-column cells with explicit % widths AND actual content.
      // Spacer cells (hasContent=false) are skipped — their large % widths
      // (e.g. width="50%" on an empty <br>-only cell) would otherwise crush
      // adjacent content columns (e.g. the INITIATIVE label).
      for (final p in placed) {
        if (p.cell.widthFraction != null && p.cell.colspan == 1 && p.cell.hasContent) {
          final f = (p.cell.widthFraction! * 1000).round().clamp(1, 1000);
          if (colFlex[p.col] == 0) colFlex[p.col] = f;
        }
      }
      // Pass 2: multi-column cells with explicit % widths fill unset columns.
      for (final p in placed) {
        if (p.cell.widthFraction != null && p.cell.colspan > 1 && p.cell.hasContent) {
          final f = (p.cell.widthFraction! * 1000).round().clamp(1, 1000);
          final perCol = (f ~/ p.cell.colspan).clamp(1, 1000);
          for (int c = p.col; c < p.col + p.cell.colspan && c < totalCols; c++) {
            if (colFlex[c] == 0) colFlex[c] = perCol;
          }
        }
      }
      // Pass 3: columns still unset get an equal share.
      final share = (1000 ~/ totalCols).clamp(1, 1000);
      for (int i = 0; i < totalCols; i++) {
        if (colFlex[i] == 0) colFlex[i] = share;
      }
    } else {
      for (final p in placed) {
        if (p.cell.widthFixed != null && p.cell.colspan == 1) {
          final f = p.cell.widthFixed!.round().clamp(1, 10000);
          if (colFlex[p.col] == 0) colFlex[p.col] = f;
        }
      }
      for (int i = 0; i < totalCols; i++) {
        if (colFlex[i] == 0) colFlex[i] = 1;
      }
    }

    // ── Hidden columns: columns where every occupying cell is display:none ──
    // These cells return SizedBox.shrink() spacers with hasContent=false.
    // We skip them entirely from Row layout so they take zero width instead
    // of stealing flex space from visible content (e.g. EPIC bonus columns).
    final hiddenCols = <int>{};
    for (int c = 0; c < totalCols; c++) {
      final occupants = placed.where(
          (p) => p.col <= c && c < p.col + p.cell.colspan);
      if (occupants.isNotEmpty && occupants.every((p) => !p.cell.hasContent)) {
        hiddenCols.add(c);
      }
    }

    // ── Special case: only col-0 has rowspan content cells ─────────────────
    // When a single content cell in col 0 spans multiple rows (e.g. the stats
    // column alongside HP+AC+initiative, or a weapon name alongside bonus rows)
    // the sequential Column layout makes everything below the rowspan start
    // only after the full height of the rowspan cell — wrong placement.
    //
    // Instead, render col-0 alongside a Column of the spanned right-side rows
    // so initiative appears beside the BOTTOM of the stats column, not below.
    final col0Spanners = placed
        .where((p) => p.col == 0 && p.cell.colspan == 1 && p.cell.rowspan > 1 && p.cell.hasContent)
        .toList();
    final otherRowspanners = placed
        .where((p) => p.col > 0 && p.cell.rowspan > 1 && p.cell.hasContent);
    if (col0Spanners.length == 1 && otherRowspanners.isEmpty) {
      return _buildWithLeftColRowspan(
          placed, totalCols, totalRows, colFlex, col0Spanners.first, hiddenCols);
    }

    // ── General: Column of flex rows ──────────────────────────────────────
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(totalRows, (ri) =>
          _buildFlexRow(placed, totalCols, colFlex, ri, hiddenCols: hiddenCols)),
    );
  }

  // Builds one horizontal Row for the given row index.
  // colStart:   first column to include (1 when building right-side-only rows).
  // hiddenCols: columns that are entirely display:none — omitted from the Row
  //             so they take no width.
  Widget _buildFlexRow(List<_PlacedCell> placed, int totalCols,
      List<int> colFlex, int ri,
      {int colStart = 0, Set<int> hiddenCols = const {}}) {
    final cellBorder = showBorder
        ? BoxDecoration(border: Border.all(color: _bc, width: 0.5))
        : const BoxDecoration();

    final rowCells = placed
        .where((p) => p.row == ri && p.col >= colStart)
        .toList()..sort((a, b) => a.col.compareTo(b.col));

    final widgets = <Widget>[];
    int col = colStart;
    // cellspacing gap between cells (each side of each cell gets half the gap)
    final gap = cellSpacing > 0 ? cellSpacing / 2 : 0.0;

    void addCell(Widget w, int flex) {
      Widget child = w;
      if (gap > 0) child = Padding(padding: EdgeInsets.all(gap), child: child);
      widgets.add(Expanded(flex: flex.clamp(1, 100000), child: child));
    }

    for (final p in rowCells) {
      // Gap-fill placeholder columns before this cell
      while (col < p.col) {
        if (!hiddenCols.contains(col)) {
          addCell(Container(decoration: cellBorder), colFlex[col]);
        }
        col++;
      }
      // Skip cells fully inside hidden columns
      final allHidden = Iterable.generate(p.cell.colspan)
          .every((i) => hiddenCols.contains(p.col + i));
      if (!allHidden) {
        var cellFlex = 0;
        for (int c = p.col; c < p.col + p.cell.colspan && c < totalCols; c++) {
          if (!hiddenCols.contains(c)) cellFlex += colFlex[c];
        }
        addCell(Container(decoration: cellBorder, child: p.cell.widget), cellFlex);
      }
      col += p.cell.colspan;
    }
    // Trailing placeholder columns
    while (col < totalCols) {
      if (!hiddenCols.contains(col)) {
        addCell(Container(decoration: cellBorder), colFlex[col]);
      }
      col++;
    }

    if (widgets.isEmpty) return const SizedBox.shrink();
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }

  // Renders col-0 rowspan cell alongside a Column of the right-side rows,
  // then appends any rows that fall after the rowspan as full-width rows.
  Widget _buildWithLeftColRowspan(List<_PlacedCell> placed, int totalCols,
      int totalRows, List<int> colFlex, _PlacedCell spanner,
      Set<int> hiddenCols) {
    final spanStart = spanner.row;
    final spanEnd   = spanner.row + spanner.cell.rowspan;

    // Right-side flex — exclude hidden columns from the total
    var rightFlex = 0;
    for (int i = 1; i < totalCols; i++) {
      if (!hiddenCols.contains(i)) rightFlex += colFlex[i];
    }
    rightFlex = rightFlex.clamp(1, 100000);

    final rightRows = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(spanEnd - spanStart, (i) =>
          _buildFlexRow(placed, totalCols, colFlex, spanStart + i,
              colStart: 1, hiddenCols: hiddenCols)),
    );

    final spanRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: colFlex[0], child: spanner.cell.widget),
        Expanded(flex: rightFlex, child: rightRows),
      ],
    );

    // Rows beyond the rowspan (if any) are full-width
    if (spanEnd >= totalRows) return spanRow;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        spanRow,
        ...List.generate(totalRows - spanEnd, (i) =>
            _buildFlexRow(placed, totalCols, colFlex, spanEnd + i,
                hiddenCols: hiddenCols)),
      ],
    );
  }
}

class _RowWidget extends StatelessWidget {
  final _RowB row;
  const _RowWidget(this.row, {super.key});
  @override Widget build(BuildContext context) => const SizedBox.shrink();
}

class _RowB extends _Builder {
  final cells = <_CellData>[];
  @override void addWidget(Widget w) {
    if (w is _CellWidget) cells.add(w.data);
  }
  @override Widget? build() {
    if (cells.isEmpty) return null;
    return _RowWidget(this);
  }
}

class _CellWidget extends StatelessWidget {
  final _CellData data;
  const _CellWidget(this.data, {super.key});
  @override Widget build(BuildContext context) => const SizedBox.shrink();
}

class _CellB extends _Builder {
  final bool isHeader;
  final _CssStyle css;
  final int colspan;
  final int rowspan;
  final double? widthFraction;
  final double? widthFixed;
  final double cellPad;
  _CellB({required this.isHeader, required this.css,
          this.colspan = 1, this.rowspan = 1,
          this.widthFraction, this.widthFixed,
          this.cellPad = 1.0});

  @override void addWidget(Widget w) { _flushPending(); _children.add(w); }

  @override Widget? build() {
    _flushPending();

    // display:none — return an invisible spacer that preserves table structure.
    if (!css.displayed) {
      return _CellWidget(_CellData(const SizedBox.shrink(),
          colspan: colspan, rowspan: rowspan, hasContent: false));
    }

    final bg  = css.bgColor ?? (isHeader ? const Color(0xFFD0D7DC) : null);
    final fg  = _autoFg(bg, css.textColor);
    final fs  = css.fontSize ?? 10.0;
    final fw  = css.fontWeight ?? (isHeader ? FontWeight.bold : FontWeight.normal);
    final ta  = css.textAlign ?? (isHeader ? TextAlign.center : TextAlign.start);
    final ff  = css.fontFamily;
    final va  = css.verticalAlign;

    // Map text-align to cross-axis alignment for multi-child columns.
    final caa = switch (ta) {
      TextAlign.center => CrossAxisAlignment.center,
      TextAlign.right  => CrossAxisAlignment.end,
      _                => CrossAxisAlignment.start,
    };

    final fsty = css.fontStyle;
    final tdec = css.textDecoration;
    final lsp  = css.letterSpacing;

    final styledChildren = _children.map((child) {
      if (child is Text) {
        var text = child.data ?? '';
        if (css.uppercase)  text = text.toUpperCase();
        if (css.capitalize) text = _toTitleCase(text);
        if (css.smallCaps)  text = text.toUpperCase(); // approximation
        return Text(text,
            textAlign: ta,
            softWrap: !css.noWrap,
            overflow: css.noWrap ? TextOverflow.ellipsis : null,
            style: (child.style ?? const TextStyle()).copyWith(
                // Inline properties (from <font>/<span>) take priority;
                // cell CSS fills the gaps; then null keeps Flutter defaults.
                fontSize:      child.style?.fontSize      ?? fs,
                fontWeight:    child.style?.fontWeight    ?? fw,
                fontStyle:     child.style?.fontStyle     ?? fsty,
                decoration:    child.style?.decoration    ?? tdec,
                letterSpacing: child.style?.letterSpacing ?? lsp,
                color:         child.style?.color         ?? fg,
                fontFamily:    child.style?.fontFamily    ?? ff));
      }
      return child;
    }).toList();

    Widget content = styledChildren.isEmpty
        ? const SizedBox.shrink()
        : styledChildren.length == 1 ? styledChildren.first
        : Column(crossAxisAlignment: caa, children: styledChildren);

    // Vertical-align: only wrap when not the default (top-start).
    // We use mainAxisSize.min so the cell doesn't inflate vertically beyond
    // its content — the Row itself aligns cells via CrossAxisAlignment.start.
    if (va != CrossAxisAlignment.start && styledChildren.isNotEmpty) {
      content = Column(
        crossAxisAlignment: caa,
        mainAxisAlignment: va == CrossAxisAlignment.end
            ? MainAxisAlignment.end
            : MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [content],
      );
    }

    // Padding: CSS padding on the cell element takes priority over cellpadding.
    // cellpadding is the HTML table-level default; CSS can override per-cell.
    final EdgeInsets cellPadding = css.padding ??
        EdgeInsets.symmetric(horizontal: cellPad * 2.0, vertical: cellPad);

    Widget cell = Container(
      padding: cellPadding,
      decoration: BoxDecoration(
          color: bg,
          border: css.effectiveBorder,
          borderRadius: css.effectiveBorderRadius),
      child: content,
    );
    cell = css.applyVisibility(cell);
    return _CellWidget(_CellData(cell, colspan: colspan, rowspan: rowspan,
                                  widthFraction: widthFraction,
                                  widthFixed: widthFixed,
                                  hasContent: styledChildren.isNotEmpty));
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
