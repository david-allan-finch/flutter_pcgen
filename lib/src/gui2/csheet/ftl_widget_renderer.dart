// Converts FTL-generated HTML into Flutter widgets.
// Uses the `html` package to parse the DOM, then maps elements to widgets.
// Only handles the HTML patterns PCGen templates actually produce.

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlParser;

class FtlWidgetRenderer {
  static const _headerBg  = Color(0xFF37474F);
  static const _headerFg  = Colors.white;
  static const _labelBg   = Color(0xFFECEFF1);
  static const _borderCol = Color(0xFFB0BEC5);
  static const _accentCol = Color(0xFF1565C0);

  /// Convert an HTML string (full document or fragment) into a scrollable widget.
  static Widget render(String html) {
    final doc  = htmlParser.parse(html);
    final body = doc.body ?? doc.documentElement;
    if (body == null) return const SizedBox.shrink();

    final widgets = _convertChildren(body.nodes);
    if (widgets.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgets,
      ),
    );
  }

  // ─── Node dispatch ──────────────────────────────────────────────────────────

  static List<Widget> _convertChildren(List<dom.Node> nodes) {
    final out = <Widget>[];
    for (final node in nodes) {
      final w = _convertNode(node);
      if (w != null) out.add(w);
    }
    return out;
  }

  static Widget? _convertNode(dom.Node node) {
    if (node is dom.Text) {
      final t = node.text.trim();
      if (t.isEmpty) return null;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Text(t, style: const TextStyle(fontSize: 11)),
      );
    }
    if (node is dom.Element) return _convertElement(node);
    return null;
  }

  static Widget? _convertElement(dom.Element el) {
    final tag = el.localName?.toLowerCase() ?? '';

    switch (tag) {
      case 'html':
      case 'head':
      case 'style':
      case 'script':
      case 'meta':
      case 'title':
      case 'link':
        return null;

      case 'body':
        final children = _convertChildren(el.nodes);
        return children.isEmpty ? null : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );

      // ── Headings ─────────────────────────────────────────────────────────
      case 'h1':
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(_text(el), style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold)),
        );
      case 'h2':
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(_text(el), style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold)),
        );
      case 'h3':
        return _sectionHeader(_text(el));
      case 'h4':
      case 'h5':
      case 'h6':
        return Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: Text(_text(el), style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: _accentCol)),
        );

      // ── Block elements ───────────────────────────────────────────────────
      case 'p':
        final t = _text(el).trim();
        if (t.isEmpty) return null;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(t, style: const TextStyle(fontSize: 11)),
        );

      case 'div':
        final children = _convertChildren(el.nodes);
        if (children.isEmpty) return null;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children),
        );

      case 'hr':
        return const Divider(height: 10, thickness: 1, color: _borderCol);

      case 'br':
        return const SizedBox(height: 4);

      // ── Lists ─────────────────────────────────────────────────────────────
      case 'ul':
      case 'ol':
        return _buildList(el, tag == 'ol');

      case 'li':
        return _buildListItem(el, false, 0);

      // ── Table ─────────────────────────────────────────────────────────────
      case 'table':
        return _buildTable(el);

      case 'thead':
      case 'tbody':
      case 'tfoot':
        final rows = _convertChildren(el.nodes)
            .whereType<Widget>().toList();
        return rows.isEmpty ? null
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);

      case 'tr':
        return _buildRow(el);

      // Inline elements — return null and let parent extract text
      case 'td':
      case 'th':
      case 'span':
      case 'b':
      case 'strong':
      case 'i':
      case 'em':
      case 'a':
      case 'font':
        // Rendered inline by parent; if standalone emit as Text
        final t = _text(el).trim();
        if (t.isEmpty) return null;
        final bold = tag == 'b' || tag == 'strong' || tag == 'th';
        return Text(t, style: TextStyle(
            fontSize: 11,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal));

      case 'center':
        final children = _convertChildren(el.nodes);
        return children.isEmpty ? null : Center(
          child: Column(children: children),
        );

      case 'input':
        return null; // form elements ignored

      case 'img':
        return null; // images ignored

      default:
        // Unknown element — render children
        final children = _convertChildren(el.nodes);
        if (children.isEmpty) return null;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children);
    }
  }

  // ─── Section header (dark band) ──────────────────────────────────────────

  static Widget _sectionHeader(String text) {
    if (text.trim().isEmpty) return const SizedBox(height: 4);
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: _headerBg,
      child: Text(text.trim(), style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.bold, color: _headerFg)),
    );
  }

  // ─── Table ───────────────────────────────────────────────────────────────

  static Widget _buildTable(dom.Element table) {
    // Collect all <tr> rows, including those inside <thead>/<tbody>/<tfoot>
    final rows = table.querySelectorAll('tr');
    if (rows.isEmpty) return const SizedBox.shrink();

    final tableRows = <TableRow>[];
    for (final row in rows) {
      final cells = row.children.where(
          (c) => c.localName == 'td' || c.localName == 'th').toList();
      if (cells.isEmpty) continue;

      tableRows.add(TableRow(
        children: cells.map((cell) {
          final isHeader = cell.localName == 'th';
          final text = _text(cell).trim();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isHeader ? const Color(0xFFD0D7DC) : null,
              border: Border.all(color: _borderCol, width: 0.5),
            ),
            child: Text(text, style: TextStyle(
                fontSize: 10,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
          );
        }).toList(),
      ));
    }

    if (tableRows.isEmpty) return const SizedBox.shrink();

    // Count max columns so Table widget is consistent
    final maxCols = rows
        .map((r) => r.children.where(
            (c) => c.localName == 'td' || c.localName == 'th').length)
        .fold(0, (a, b) => a > b ? a : b);
    if (maxCols == 0) return const SizedBox.shrink();

    // Pad rows with fewer columns
    final paddedRows = tableRows.map((row) {
      if (row.children.length < maxCols) {
        final extra = List.generate(
            maxCols - row.children.length,
            (_) => Container(
                decoration: BoxDecoration(border: Border.all(color: _borderCol, width: 0.5)),
                padding: const EdgeInsets.all(4),
                child: const SizedBox.shrink()));
        return TableRow(children: [...row.children, ...extra]);
      }
      return row;
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Table(
        border: TableBorder.all(color: _borderCol, width: 0.5),
        defaultColumnWidth: const FlexColumnWidth(),
        children: paddedRows,
      ),
    );
  }

  static Widget? _buildRow(dom.Element tr) {
    // Standalone <tr> not inside <table> — render as a label-value row
    final cells = tr.children.where(
        (c) => c.localName == 'td' || c.localName == 'th').toList();
    if (cells.isEmpty) return null;
    final texts = cells.map((c) => _text(c).trim()).toList();
    if (texts.every((t) => t.isEmpty)) return null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(children: texts.map((t) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              border: Border.all(color: _borderCol, width: 0.5)),
          child: Text(t, style: const TextStyle(fontSize: 10)),
        ),
      )).toList()),
    );
  }

  // ─── Lists ───────────────────────────────────────────────────────────────

  static Widget _buildList(dom.Element list, bool ordered) {
    final items = list.children.where((c) => c.localName == 'li').toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.asMap().entries.map((e) =>
            _buildListItem(e.value, ordered, e.key + 1)).toList(),
      ),
    );
  }

  static Widget _buildListItem(dom.Element li, bool ordered, int index) {
    final bullet = ordered ? '$index.' : '•';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 20, child: Text(bullet,
            style: TextStyle(fontSize: 11, color: _accentCol))),
        Expanded(child: Text(_text(li).trim(),
            style: const TextStyle(fontSize: 11))),
      ]),
    );
  }

  // ─── Text extraction ─────────────────────────────────────────────────────

  /// Recursively extract all text content from an element.
  static String _text(dom.Element el) {
    final buf = StringBuffer();
    for (final node in el.nodes) {
      if (node is dom.Text) {
        buf.write(node.text);
      } else if (node is dom.Element) {
        if (node.localName == 'br') {
          buf.write(' ');
        } else {
          buf.write(_text(node));
        }
      }
    }
    return buf.toString();
  }
}
