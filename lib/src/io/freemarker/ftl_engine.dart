// FreeMarker template engine — Dart implementation of the FTL subset used by
// PCGen character sheet templates (.htm.ftl).
//
// Supported directives: #if/#elseif/#else/#if, #list/#items/#sep, #assign,
//   #local, #include, #macro, #call (@macro), #-- comment --, #compress,
//   #noparse, #ftl (stripped).
// Supported expressions: string/number literals, variable access (a.b.c),
//   function calls (pcstring(), pcvar(), …), sequence indexing (s[i]),
//   arithmetic (+,-,*,/,%), comparison (==,!=,<,>,<=,>=), logical (&&,||,!),
//   null-check (??), string builtins (?upper_case, ?lower_case, ?trim,
//   ?has_content, ?string, ?int, ?c, ?length, ?size, ?index_of, ?contains).

import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_pcgen/src/io/freemarker/ftl_context.dart';

// ─── Public API ──────────────────────────────────────────────────────────────

class FtlEngine {
  /// Render [template] using [ctx]. Optionally pass [baseDir] for #include.
  String render(String template, FtlContext ctx, {String? baseDir}) {
    final nodes = _Parser(template).parse();
    final buf = StringBuffer();
    _Evaluator(ctx, baseDir: baseDir).evalList(nodes, buf);
    return buf.toString();
  }

  /// Render the template file at [path].
  String renderFile(String path, FtlContext ctx) {
    final file = File(path);
    final template = file.readAsStringSync();
    return render(template, ctx, baseDir: file.parent.path);
  }
}

// ─── AST nodes ───────────────────────────────────────────────────────────────

abstract class _Node {}

class _TextNode extends _Node {
  final String text;
  _TextNode(this.text);
}

class _ExprNode extends _Node {
  final String src;
  _ExprNode(this.src);
}

class _IfNode extends _Node {
  final List<({String condition, List<_Node> body})> branches;
  final List<_Node>? elseBranch;
  _IfNode(this.branches, this.elseBranch);
}

class _ListNode extends _Node {
  final String sequence;
  final String iterVar;
  final List<_Node> body;
  _ListNode(this.sequence, this.iterVar, this.body);
}

// PCGen's <@loop from=X to=Y ; iterVar , hasNextVar> directive
class _PcLoopNode extends _Node {
  final String fromExpr;
  final String toExpr;
  final String iterVar;
  final String hasNextVar;
  final List<_Node> body;
  _PcLoopNode(this.fromExpr, this.toExpr, this.iterVar, this.hasNextVar, this.body);
}

class _AssignNode extends _Node {
  final String name;
  final String src;    // empty if block-assign
  final List<_Node> body;
  final bool isLocal;
  _AssignNode(this.name, this.src, this.body, {this.isLocal = false});
}

class _IncludeNode extends _Node {
  final String path;
  _IncludeNode(this.path);
}

class _MacroNode extends _Node {
  final String name;
  final List<String> params;
  final List<_Node> body;
  _MacroNode(this.name, this.params, this.body);
}

class _CallMacroNode extends _Node {
  final String name;
  final Map<String, String> args;
  _CallMacroNode(this.name, this.args);
}

class _CommentNode extends _Node {}

// ─── Parser ───────────────────────────────────────────────────────────────────

class _Parser {
  final String _src;
  int _pos = 0;

  _Parser(this._src);

  List<_Node> parse() => _parseUntil(null);

  List<_Node> _parseUntil(String? stopDirective) {
    final nodes = <_Node>[];
    while (_pos < _src.length) {
      final ch = _src[_pos];

      if (ch == '<') {
        // Check for FTL directive or comment
        if (_startsWith('<#--')) {
          _skipComment();
          nodes.add(_CommentNode());
          continue;
        }
        if (_startsWith('<#ftl') || _startsWith('<#compress') || _startsWith('<#noparse')) {
          _skipDirectiveTag();
          continue;
        }
        if (_startsWith('<#if ') || _startsWith('<#if\t')) {
          nodes.add(_parseIf());
          continue;
        }
        if (_startsWith('<#list ') || _startsWith('<#list\t')) {
          nodes.add(_parseList());
          continue;
        }
        if (_startsWith('<#assign ') || _startsWith('<#assign\t')) {
          nodes.add(_parseAssign(false));
          continue;
        }
        if (_startsWith('<#local ') || _startsWith('<#local\t')) {
          nodes.add(_parseAssign(true));
          continue;
        }
        if (_startsWith('<#include ') || _startsWith('<#include\t')) {
          nodes.add(_parseInclude());
          continue;
        }
        if (_startsWith('<#macro ') || _startsWith('<#macro\t')) {
          nodes.add(_parseMacro());
          continue;
        }
        if (_startsWith('<#return') || _startsWith('<#break') || _startsWith('<#stop')) {
          _skipDirectiveTag();
          continue;
        }
        // Check for end-directive (e.g. </#if>)
        if (_startsWith('</#')) {
          final tag = _peekEndTag();
          if (stopDirective != null && tag == stopDirective) {
            _skipEndTag();
            return nodes;
          }
          // Unknown end tag — skip it
          _skipEndTag();
          continue;
        }
        // End of custom directive: </@name>  (PCGen uses </@loop>, not </#loop>)
        if (_startsWith('</@')) {
          final end = _src.indexOf('>', _pos);
          final name = end >= 0 ? _src.substring(_pos + 3, end).trim() : '';
          if (stopDirective != null && name == stopDirective) {
            _pos = end < 0 ? _src.length : end + 1;
            return nodes;
          }
          // Not our closing tag — skip it (already consumed by inner _parseUntil)
          _pos = end < 0 ? _src.length : end + 1;
          continue;
        }
        // Check for macro call: <@name .../>  or  <@name ...> ... </@name>
        if (_startsWith('<@')) {
          nodes.add(_parseMacroCall());
          continue;
        }
        // Plain HTML tag or unrecognised '<' — emit it as literal text and advance.
        // Without this, _pos never moves and we loop forever.
        nodes.add(_TextNode('<'));
        _pos++;
        continue;
      }

      if (ch == r'$' && _pos + 1 < _src.length && _src[_pos + 1] == '{') {
        nodes.add(_parseInterpolation());
        continue;
      }

      // Plain text — accumulate until next special character
      final start = _pos;
      while (_pos < _src.length) {
        final c = _src[_pos];
        if (c == '<' || (c == r'$' && _pos + 1 < _src.length && _src[_pos + 1] == '{')) break;
        _pos++;
      }
      if (_pos > start) nodes.add(_TextNode(_src.substring(start, _pos)));
    }
    return nodes;
  }

  bool _startsWith(String s) {
    if (_pos + s.length > _src.length) return false;
    return _src.startsWith(s, _pos);
  }

  String _peekEndTag() {
    // pos is at </#
    final end = _src.indexOf('>', _pos);
    if (end < 0) return '';
    return _src.substring(_pos + 3, end).trim();
  }

  void _skipEndTag() {
    final end = _src.indexOf('>', _pos);
    _pos = end < 0 ? _src.length : end + 1;
  }

  void _skipDirectiveTag() {
    final end = _src.indexOf('>', _pos);
    _pos = end < 0 ? _src.length : end + 1;
  }

  void _skipComment() {
    final end = _src.indexOf('-->', _pos + 4);
    _pos = end < 0 ? _src.length : end + 3;
  }

  _ExprNode _parseInterpolation() {
    _pos += 2; // skip ${
    final depth = <String>[];
    final start = _pos;
    while (_pos < _src.length) {
      final c = _src[_pos];
      if ((c == '(' || c == '[' || c == '{') && (_pos == start || _src[_pos-1] != r'\')) {
        depth.add(c);
      } else if (c == ')' || c == ']' || c == '}') {
        if (depth.isEmpty) break;
        depth.removeLast();
      }
      _pos++;
    }
    final expr = _src.substring(start, _pos);
    if (_pos < _src.length) _pos++; // skip }
    return _ExprNode(expr);
  }

  // Parse <#if cond>...</#if> with optional <#elseif> and <#else>
  _IfNode _parseIf() {
    _pos += 4; // skip <#if
    final cond = _readUntil('>');
    final branches = <({String condition, List<_Node> body})>[];
    List<_Node>? elseBranch;

    var body = <_Node>[];
    while (_pos < _src.length) {
      final chunk = _parseUntilBranch({'elseif', 'else', 'if'});
      body.addAll(chunk.nodes);
      if (chunk.tag == 'if') {
        branches.add((condition: cond.trim(), body: body));
        break;
      } else if (chunk.tag == 'elseif') {
        branches.add((condition: cond.trim(), body: body));
        body = <_Node>[];
        // read elseif condition
        // already consumed by parseUntilBranch
      } else if (chunk.tag == 'else') {
        branches.add((condition: cond.trim(), body: body));
        final elseBody = <_Node>[];
        final rest = _parseUntilBranch({'if'});
        elseBody.addAll(rest.nodes);
        elseBranch = elseBody;
        break;
      } else {
        // end of source
        branches.add((condition: cond.trim(), body: body));
        break;
      }
    }
    return _IfNode(branches, elseBranch);
  }

  ({List<_Node> nodes, String tag, String? condExpr}) _parseUntilBranch(Set<String> stopTags) {
    final nodes = <_Node>[];
    while (_pos < _src.length) {
      final ch = _src[_pos];
      if (ch == '<') {
        if (_startsWith('<#--')) { _skipComment(); continue; }
        if (_startsWith('</#if>')) {
          if (stopTags.contains('if')) { _pos += 6; return (nodes: nodes, tag: 'if', condExpr: null); }
        }
        if (_startsWith('<#elseif ') || _startsWith('<#elseif\t')) {
          if (stopTags.contains('elseif')) {
            _pos += 8; // <#elseif
            final cond = _readUntil('>');
            return (nodes: nodes, tag: 'elseif', condExpr: cond.trim());
          }
        }
        if (_startsWith('<#else>') || _startsWith('<#else ')) {
          if (stopTags.contains('else')) {
            _skipDirectiveTag();
            return (nodes: nodes, tag: 'else', condExpr: null);
          }
        }
        // Nested directives — parse them recursively
        if (_startsWith('<#if ') || _startsWith('<#if\t')) { nodes.add(_parseIf()); continue; }
        if (_startsWith('<#list ') || _startsWith('<#list\t')) { nodes.add(_parseList()); continue; }
        if (_startsWith('<#assign ') || _startsWith('<#assign\t')) { nodes.add(_parseAssign(false)); continue; }
        if (_startsWith('<#local ') || _startsWith('<#local\t')) { nodes.add(_parseAssign(true)); continue; }
        if (_startsWith('<#include ') || _startsWith('<#include\t')) { nodes.add(_parseInclude()); continue; }
        if (_startsWith('<#macro ') || _startsWith('<#macro\t')) { nodes.add(_parseMacro()); continue; }
        if (_startsWith('<#')) { _skipDirectiveTag(); continue; }
        if (_startsWith('</@') || _startsWith('</#')) { _skipEndTag(); continue; }
        if (_startsWith('<@')) { nodes.add(_parseMacroCall()); continue; }
        // Plain HTML tag — emit literal '<' and advance to avoid infinite loop.
        nodes.add(_TextNode('<'));
        _pos++;
        continue;
      }
      if (ch == r'$' && _pos + 1 < _src.length && _src[_pos + 1] == '{') {
        nodes.add(_parseInterpolation()); continue;
      }
      final start = _pos;
      while (_pos < _src.length) {
        final c = _src[_pos];
        if (c == '<' || (c == r'$' && _pos + 1 < _src.length && _src[_pos + 1] == '{')) break;
        _pos++;
      }
      if (_pos > start) nodes.add(_TextNode(_src.substring(start, _pos)));
    }
    return (nodes: nodes, tag: '', condExpr: null);
  }

  _ListNode _parseList() {
    _pos += 6; // skip <#list
    final header = _readUntil('>').trim();
    // Format: "sequence as item"  or  "0..N as i"
    final asIdx = header.lastIndexOf(' as ');
    final seqExpr = asIdx >= 0 ? header.substring(0, asIdx).trim() : header;
    final iterVar = asIdx >= 0 ? header.substring(asIdx + 4).trim() : 'item';
    final body = _parseUntil('list');
    return _ListNode(seqExpr, iterVar, body);
  }

  _AssignNode _parseAssign(bool isLocal) {
    _pos += isLocal ? 7 : 8; // <#local or <#assign
    final header = _readUntil('>').trim();
    // Could be: name=expr  or just: name (block assign via <#assign name>...</#assign>)
    final eq = header.indexOf('=');
    if (eq >= 0) {
      final name = header.substring(0, eq).trim();
      final expr = header.substring(eq + 1).trim();
      return _AssignNode(name, expr, [], isLocal: isLocal);
    } else {
      final name = header;
      final body = _parseUntil('assign');
      return _AssignNode(name, '', body, isLocal: isLocal);
    }
  }

  _IncludeNode _parseInclude() {
    _pos += 9; // <#include
    final raw = _readUntil('>').trim();
    final path = raw.replaceAll('"', '').replaceAll("'", '').trim();
    return _IncludeNode(path);
  }

  _MacroNode _parseMacro() {
    _pos += 7; // <#macro
    final header = _readUntil('>').trim();
    final parts = header.split(RegExp(r'\s+'));
    final name = parts.isNotEmpty ? parts[0] : 'macro';
    final params = parts.length > 1 ? parts.sublist(1) : <String>[];
    final body = _parseUntil('macro');
    return _MacroNode(name, params, body);
  }

  _Node _parseMacroCall() {
    _pos += 2; // skip <@
    final end = _src.indexOf('>', _pos);
    if (end < 0) { _pos = _src.length; return _CallMacroNode('', {}); }
    final raw = _src.substring(_pos, end).trim();
    _pos = end + 1;
    final clean = raw.endsWith('/') ? raw.substring(0, raw.length - 1).trim() : raw;
    final spIdx = clean.indexOf(' ');
    final name = spIdx < 0 ? clean : clean.substring(0, spIdx);
    final argStr = spIdx < 0 ? '' : clean.substring(spIdx + 1).trim();

    // PCGen's <@loop from=X to=Y ; iterVar , hasNextVar> directive
    if (name == 'loop') {
      return _parsePcLoop(argStr);
    }

    final args = _parseArgs(argStr);
    return _CallMacroNode(name, args);
  }

  _PcLoopNode _parsePcLoop(String argStr) {
    // Format: from=EXPR to=EXPR ; iterVar , hasNextVar
    // Also seen: from=0 to=pcvar('COUNT[STATS]-1') ; stat , stat_has_next
    String fromExpr = '0';
    String toExpr = '0';
    String iterVar = 'item';
    String hasNextVar = 'item_has_next';

    // Split on ';' to separate key=value args from iter var declarations
    final semiIdx = argStr.indexOf(';');
    final keyPart = semiIdx >= 0 ? argStr.substring(0, semiIdx).trim() : argStr;
    final varPart = semiIdx >= 0 ? argStr.substring(semiIdx + 1).trim() : '';

    // Parse from=X to=Y (values may contain balanced parens/quotes)
    final fromMatch = RegExp(r'from\s*=\s*(.+?)(?=\s+to\s*=)', dotAll: true).firstMatch(keyPart);
    final toMatch   = RegExp(r'to\s*=\s*(.+)$').firstMatch(keyPart);
    if (fromMatch != null) fromExpr = fromMatch.group(1)!.trim();
    if (toMatch   != null) toExpr   = toMatch.group(1)!.trim();

    // Parse iterVar , hasNextVar
    if (varPart.isNotEmpty) {
      final vars = varPart.split(',');
      if (vars.isNotEmpty) iterVar = vars[0].trim();
      if (vars.length > 1) hasNextVar = vars[1].trim();
    }

    final body = _parseUntil('loop');
    return _PcLoopNode(fromExpr, toExpr, iterVar, hasNextVar, body);
  }

  Map<String, String> _parseArgs(String src) {
    final result = <String, String>{};
    // Simple: key="value" pairs or positional string "value"
    final re = RegExp(r'(\w+)\s*=\s*"([^"]*)"');
    for (final m in re.allMatches(src)) {
      result[m.group(1)!] = m.group(2)!;
    }
    // Positional string (first quoted)
    if (result.isEmpty) {
      final m = RegExp(r'"([^"]*)"').firstMatch(src);
      if (m != null) result[''] = m.group(1)!;
    }
    return result;
  }

  String _readUntil(String stop) {
    final start = _pos;
    while (_pos < _src.length && _src[_pos] != stop) {
      _pos++;
    }
    final s = _src.substring(start, _pos);
    if (_pos < _src.length) _pos++; // skip stop char
    return s;
  }
}

// ─── Evaluator ────────────────────────────────────────────────────────────────

class _Evaluator {
  final FtlContext _ctx;
  final String? _baseDir;
  final Map<String, _MacroNode> _macros = {};

  _Evaluator(this._ctx, {String? baseDir}) : _baseDir = baseDir;

  void evalList(List<_Node> nodes, StringBuffer out) {
    for (final node in nodes) {
      _eval(node, out);
    }
  }

  void _eval(_Node node, StringBuffer out) {
    if (node is _TextNode) { out.write(node.text); return; }
    if (node is _CommentNode) return;

    if (node is _ExprNode) {
      try {
        final val = _evalExpr(node.src, _ctx.vars);
        out.write(_toStr(val));
      } catch (_) { /* silently skip bad expressions */ }
      return;
    }

    if (node is _IfNode) {
      for (final branch in node.branches) {
        try {
          final cond = _evalExpr(branch.condition, _ctx.vars);
          if (_isTruthy(cond)) {
            evalList(branch.body, out);
            return;
          }
        } catch (_) {}
      }
      if (node.elseBranch != null) evalList(node.elseBranch!, out);
      return;
    }

    if (node is _ListNode) {
      try {
        final seq = _evalExpr(node.sequence, _ctx.vars);
        final items = _toList(seq);
        final savedVars = Map<String, dynamic>.from(_ctx.vars);
        for (var i = 0; i < items.length; i++) {
          _ctx.vars[node.iterVar] = items[i];
          _ctx.vars['${node.iterVar}_index'] = i;
          _ctx.vars['${node.iterVar}_has_next'] = i < items.length - 1;
          evalList(node.body, out);
        }
        _ctx.vars
          ..remove(node.iterVar)
          ..remove('${node.iterVar}_index')
          ..remove('${node.iterVar}_has_next');
        // Restore overwritten outer vars
        for (final k in savedVars.keys) {
          if (!_ctx.vars.containsKey(k)) _ctx.vars[k] = savedVars[k];
        }
      } catch (_) {}
      return;
    }

    if (node is _PcLoopNode) {
      try {
        final fromRaw = _evalExpr(node.fromExpr, _ctx.vars);
        final toRaw   = _evalExpr(node.toExpr,   _ctx.vars);
        final from = fromRaw is num ? fromRaw.toInt() : int.tryParse(_toStr(fromRaw)) ?? 0;
        final to   = toRaw   is num ? toRaw.toInt()   : int.tryParse(_toStr(toRaw))   ?? -1;
        debugPrint('FTL_DBG <@loop iterVar="${node.iterVar}" from=$from to=$to toExpr="${node.toExpr}">');
        final savedVars = Map<String, dynamic>.from(_ctx.vars);
        for (var i = from; i <= to; i++) {
          _ctx.vars[node.iterVar]    = i;
          _ctx.vars[node.hasNextVar] = i < to;
          evalList(node.body, out);
        }
        _ctx.vars
          ..remove(node.iterVar)
          ..remove(node.hasNextVar);
        for (final k in savedVars.keys) {
          if (!_ctx.vars.containsKey(k)) _ctx.vars[k] = savedVars[k];
        }
      } catch (e) {
        debugPrint('FTL_DBG <@loop> ERROR: $e');
      }
      return;
    }

    if (node is _AssignNode) {
      if (node.src.isNotEmpty) {
        try {
          _ctx.vars[node.name] = _evalExpr(node.src, _ctx.vars);
        } catch (_) {}
      } else {
        final buf = StringBuffer();
        evalList(node.body, buf);
        _ctx.vars[node.name] = buf.toString();
      }
      return;
    }

    if (node is _IncludeNode) {
      if (_baseDir != null) {
        try {
          final path = '$_baseDir/${node.path}';
          final content = File(path).readAsStringSync();
          final sub = _Parser(content).parse();
          final subEval = _Evaluator(_ctx, baseDir: _baseDir);
          subEval._macros.addAll(_macros);
          subEval.evalList(sub, out);
          _macros.addAll(subEval._macros);
        } catch (_) {}
      }
      return;
    }

    if (node is _MacroNode) {
      _macros[node.name] = node;
      return;
    }

    if (node is _CallMacroNode) {
      final macro = _macros[node.name];
      if (macro == null) return;
      final savedVars = Map<String, dynamic>.from(_ctx.vars);
      for (var i = 0; i < macro.params.length; i++) {
        final p = macro.params[i];
        final val = node.args[p] ?? node.args[i.toString()] ?? node.args[''];
        if (val != null) _ctx.vars[p] = val;
      }
      evalList(macro.body, out);
      _ctx.vars
        ..clear()
        ..addAll(savedVars);
      return;
    }
  }

  // ─── Expression evaluator ─────────────────────────────────────────────────

  dynamic _evalExpr(String src, Map<String, dynamic> vars) {
    src = src.trim();
    if (src.isEmpty) return '';

    // Null-check operator at top level: expr??
    if (src.endsWith('??')) {
      try {
        final v = _evalExpr(src.substring(0, src.length - 2), vars);
        return v != null;
      } catch (_) { return false; }
    }

    // Logical OR/AND (simple left-to-right, no precedence)
    final orIdx = _findTopLevel(src, '||');
    if (orIdx >= 0) {
      return _isTruthy(_evalExpr(src.substring(0, orIdx), vars)) ||
             _isTruthy(_evalExpr(src.substring(orIdx + 2), vars));
    }
    final andIdx = _findTopLevel(src, '&&');
    if (andIdx >= 0) {
      return _isTruthy(_evalExpr(src.substring(0, andIdx), vars)) &&
             _isTruthy(_evalExpr(src.substring(andIdx + 2), vars));
    }

    // Comparison operators
    for (final op in ['==', '!=', '>=', '<=', '>', '<']) {
      final idx = _findTopLevel(src, op);
      if (idx >= 0) {
        final left = _evalExpr(src.substring(0, idx), vars);
        final right = _evalExpr(src.substring(idx + op.length), vars);
        return _compare(left, right, op);
      }
    }

    // Logical NOT
    if (src.startsWith('!')) {
      return !_isTruthy(_evalExpr(src.substring(1), vars));
    }

    // Ternary: cond?then:else  (FreeMarker uses ?then:else differently; skip)

    // Arithmetic (low precedence)
    final addIdx = _findTopLevel(src, '+', skipStrings: true);
    if (addIdx >= 0 && addIdx > 0) {
      final left = _evalExpr(src.substring(0, addIdx), vars);
      final right = _evalExpr(src.substring(addIdx + 1), vars);
      if (left is num && right is num) return left.toDouble() + right.toDouble();
      return '${_toStr(left)}${_toStr(right)}';
    }
    final subIdx = _findTopLevel(src, '-', skipStrings: true);
    if (subIdx > 0) {
      final left = _evalExpr(src.substring(0, subIdx), vars);
      final right = _evalExpr(src.substring(subIdx + 1), vars);
      if (left is num && right is num) return left.toDouble() - right.toDouble();
    }
    final mulIdx = _findTopLevel(src, '*', skipStrings: true);
    if (mulIdx >= 0) {
      final left = _evalExpr(src.substring(0, mulIdx), vars);
      final right = _evalExpr(src.substring(mulIdx + 1), vars);
      if (left is num && right is num) return left.toDouble() * right.toDouble();
    }
    final divIdx = _findTopLevel(src, '/', skipStrings: true);
    if (divIdx >= 0) {
      final left = _evalExpr(src.substring(0, divIdx), vars);
      final right = _evalExpr(src.substring(divIdx + 1), vars);
      if (left is num && right is num && right != 0) return left.toDouble() / right.toDouble();
    }
    final modIdx = _findTopLevel(src, '%', skipStrings: true);
    if (modIdx >= 0) {
      final left = _evalExpr(src.substring(0, modIdx), vars);
      final right = _evalExpr(src.substring(modIdx + 1), vars);
      if (left is num && right is num && right != 0) return left.toDouble() % right.toDouble();
    }

    // String built-ins: expr?builtin
    final qIdx = src.lastIndexOf('?');
    if (qIdx > 0 && qIdx < src.length - 1 && src[qIdx + 1] != '?') {
      final baseExpr = src.substring(0, qIdx);
      final builtin = src.substring(qIdx + 1);
      return _applyBuiltin(_evalExpr(baseExpr, vars), builtin, vars);
    }

    // Sequence index: expr[idx]
    if (src.endsWith(']')) {
      final brack = src.lastIndexOf('[');
      if (brack > 0) {
        final base = _evalExpr(src.substring(0, brack), vars);
        final idx = _evalExpr(src.substring(brack + 1, src.length - 1), vars);
        if (base is List && idx is num) {
          final i = idx.toInt();
          return (i >= 0 && i < base.length) ? base[i] : null;
        }
        if (base is Map) return base[_toStr(idx)];
        return null;
      }
    }

    // Dot access: a.b.c
    if (src.contains('.') && !src.startsWith('"') && !src.startsWith("'")) {
      final dotIdx = src.indexOf('.');
      // Check it's not inside function call args
      final parenIdx = src.indexOf('(');
      if (parenIdx < 0 || dotIdx < parenIdx) {
        final obj = _evalExpr(src.substring(0, dotIdx), vars);
        final rest = src.substring(dotIdx + 1);
        if (obj is Map) {
          final key = rest.contains('.') ? rest.split('.').first : rest;
          final child = obj[key];
          if (rest.contains('.')) {
            return _evalExpr(rest, {rest.split('.').first: child, ...vars});
          }
          return child;
        }
        // range: 0..N
        if (obj is num && rest.startsWith('.')) {
          final end = _evalExpr(rest.substring(1), vars);
          if (end is num) return List.generate(end.toInt() - obj.toInt() + 1, (i) => obj.toInt() + i);
        }
        return null;
      }
    }

    // Function calls: fname(args)
    if (src.endsWith(')')) {
      final parenIdx = src.indexOf('(');
      if (parenIdx > 0) {
        final fname = src.substring(0, parenIdx).trim();
        final argStr = src.substring(parenIdx + 1, src.length - 1).trim();
        return _callFunction(fname, argStr, vars);
      }
    }

    // Parenthesised expression
    if (src.startsWith('(') && src.endsWith(')')) {
      return _evalExpr(src.substring(1, src.length - 1), vars);
    }

    // String literal — expand any ${var} interpolations inside it
    if ((src.startsWith('"') && src.endsWith('"')) ||
        (src.startsWith("'") && src.endsWith("'"))) {
      final inner = src.substring(1, src.length - 1);
      return _expandStringInterpolation(inner, vars);
    }

    // Numeric literal
    final n = num.tryParse(src);
    if (n != null) return n;

    // Boolean literals
    if (src == 'true') return true;
    if (src == 'false') return false;

    // Variable lookup
    return vars[src];
  }

  dynamic _callFunction(String name, String argStr, Map<String, dynamic> vars) {
    // Split args on top-level commas
    final rawArgs = _splitArgs(argStr);
    final evaled = rawArgs.map((a) => _evalExpr(a.trim(), vars)).toList();

    switch (name.toLowerCase()) {
      case 'pcstring': return _ctx.pcstring(_toStr(evaled.isEmpty ? '' : evaled.first));
      case 'pcvar':    return _ctx.pcvar(_toStr(evaled.isEmpty ? '' : evaled.first));
      case 'pcboolean':return _ctx.pcboolean(_toStr(evaled.isEmpty ? '' : evaled.first));
      case 'pclabel': return _ctx.pcstring(_toStr(evaled.isEmpty ? '' : evaled.first));
      case 'pchasvar': return _ctx.pcboolean('HASVAR.${evaled.isEmpty ? '' : evaled.first}');
      case 'math.abs':case 'abs': return (evaled.first as num?)?.abs() ?? 0;
      case 'math.floor':case 'floor': return (evaled.first as num?)?.toInt() ?? 0;
      case 'math.ceil': return ((evaled.first as num?) ?? 0).ceil();
      case 'math.round': return ((evaled.first as num?) ?? 0).round();
      case 'math.max': return evaled.length >= 2 ? ([evaled[0] as num, evaled[1] as num]..sort()).last : evaled.first;
      case 'math.min': return evaled.length >= 2 ? ([evaled[0] as num, evaled[1] as num]..sort()).first : evaled.first;
      default: return vars[name]; // treat as variable
    }
  }

  dynamic _applyBuiltin(dynamic val, String builtin, Map<String, dynamic> vars) {
    final s = _toStr(val);
    switch (builtin) {
      case 'upper_case': return s.toUpperCase();
      case 'lower_case': return s.toLowerCase();
      case 'trim': return s.trim();
      case 'length': return s.length;
      case 'size': return val is List ? val.length : (val is Map ? val.length : 0);
      case 'has_content': return s.isNotEmpty;
      case 'string': return s;
      case 'int': return (val is num) ? val.toInt() : (num.tryParse(s)?.toInt() ?? 0);
      case 'c': return s; // computer output (no formatting)
      case 'cap_first': return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
      default:
        // built-in with args: ?contains("x"), ?starts_with("x"), etc.
        if (builtin.startsWith('contains(')) {
          final arg = _unquote(builtin.substring(9, builtin.length - 1));
          return s.contains(arg);
        }
        if (builtin.startsWith('starts_with(')) {
          final arg = _unquote(builtin.substring(12, builtin.length - 1));
          return s.startsWith(arg);
        }
        if (builtin.startsWith('ends_with(')) {
          final arg = _unquote(builtin.substring(10, builtin.length - 1));
          return s.endsWith(arg);
        }
        if (builtin.startsWith('index_of(')) {
          final arg = _unquote(builtin.substring(9, builtin.length - 1));
          return s.indexOf(arg);
        }
        if (builtin.startsWith('replace(')) {
          final parts = builtin.substring(8, builtin.length - 1).split(',');
          if (parts.length >= 2) return s.replaceAll(_unquote(parts[0].trim()), _unquote(parts[1].trim()));
        }
        if (builtin.startsWith('substring(')) {
          final parts = builtin.substring(10, builtin.length - 1).split(',');
          final from = int.tryParse(parts[0].trim()) ?? 0;
          final to = parts.length > 1 ? (int.tryParse(parts[1].trim()) ?? s.length) : s.length;
          return s.substring(from, to.clamp(0, s.length));
        }
        return val;
    }
  }

  String _unquote(String s) => s.trim().replaceAll('"', '').replaceAll("'", '');

  /// Expand ${varName} and ${expr} inside a string literal value.
  /// e.g. 'STAT.${stat}.NAME' with stat=2 → 'STAT.2.NAME'
  String _expandStringInterpolation(String s, Map<String, dynamic> vars) {
    if (!s.contains(r'${')) return s;
    final buf = StringBuffer();
    int i = 0;
    while (i < s.length) {
      if (s[i] == r'$' && i + 1 < s.length && s[i + 1] == '{') {
        final end = s.indexOf('}', i + 2);
        if (end < 0) { buf.write(s.substring(i)); break; }
        final expr = s.substring(i + 2, end);
        try {
          buf.write(_toStr(_evalExpr(expr, vars)));
        } catch (_) {
          buf.write('\${$expr}');
        }
        i = end + 1;
      } else {
        buf.write(s[i]);
        i++;
      }
    }
    return buf.toString();
  }

  bool _compare(dynamic left, dynamic right, String op) {
    final ls = _toStr(left);
    final rs = _toStr(right);
    final ln = num.tryParse(ls);
    final rn = num.tryParse(rs);
    switch (op) {
      case '==': return ln != null && rn != null ? ln == rn : ls == rs;
      case '!=': return ln != null && rn != null ? ln != rn : ls != rs;
      case '>':  return ln != null && rn != null ? ln > rn : ls.compareTo(rs) > 0;
      case '<':  return ln != null && rn != null ? ln < rn : ls.compareTo(rs) < 0;
      case '>=': return ln != null && rn != null ? ln >= rn : ls.compareTo(rs) >= 0;
      case '<=': return ln != null && rn != null ? ln <= rn : ls.compareTo(rs) <= 0;
    }
    return false;
  }

  bool _isTruthy(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.isNotEmpty;
    if (v is List) return v.isNotEmpty;
    return true;
  }

  List<dynamic> _toList(dynamic v) {
    if (v is List) return v;
    if (v is String) {
      // If it's a numeric range string or count, build list
      final n = int.tryParse(v);
      if (n != null) return List.generate(n, (i) => i);
      return [v];
    }
    if (v is num) return List.generate(v.toInt(), (i) => i);
    return [];
  }

  String _toStr(dynamic v) {
    if (v == null) return '';
    if (v is bool) return v ? '1' : '0';
    if (v is double) {
      if (v == v.truncateToDouble()) return v.toInt().toString();
      return v.toString();
    }
    return v.toString();
  }

  // Find top-level operator (not inside parens/brackets/quotes)
  int _findTopLevel(String src, String op, {bool skipStrings = false}) {
    int depth = 0;
    bool inStr = false;
    String strChar = '';
    for (var i = 0; i <= src.length - op.length; i++) {
      final c = src[i];
      if (inStr) {
        if (c == strChar && (i == 0 || src[i-1] != r'\')) inStr = false;
        continue;
      }
      if (skipStrings && (c == '"' || c == "'")) {
        inStr = true; strChar = c; continue;
      }
      if (c == '(' || c == '[' || c == '{') { depth++; continue; }
      if (c == ')' || c == ']' || c == '}') { depth--; continue; }
      if (depth == 0 && src.startsWith(op, i)) return i;
    }
    return -1;
  }

  List<String> _splitArgs(String src) {
    final args = <String>[];
    int depth = 0;
    bool inStr = false;
    String strChar = '';
    int start = 0;
    for (var i = 0; i < src.length; i++) {
      final c = src[i];
      if (inStr) {
        if (c == strChar) inStr = false;
        continue;
      }
      if (c == '"' || c == "'") { inStr = true; strChar = c; continue; }
      if (c == '(' || c == '[') { depth++; continue; }
      if (c == ')' || c == ']') { depth--; continue; }
      if (depth == 0 && c == ',') {
        args.add(src.substring(start, i));
        start = i + 1;
      }
    }
    if (start < src.length) args.add(src.substring(start));
    return args.where((s) => s.trim().isNotEmpty).toList();
  }
}
