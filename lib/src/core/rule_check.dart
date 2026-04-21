//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.RuleCheck
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';

// Represents a game-rule option (e.g. "Allow HP to be 1 on first level").
// RULECHECK entries in game mode files are loaded into these objects.
final class RuleCheck implements Loadable {
  String? _ruleName;
  String? _ruleKey;
  String _ruleDescription = '';
  String _parm = '';
  String _var = '';
  CDOMSingleRef<RuleCheck>? _excludeKey;
  bool _isEnabledByDefault = false;
  String? _sourceUri;

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String source) => _sourceUri = source;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  void setDefault(bool set) => _isEnabledByDefault = set;
  bool getDefault() => _isEnabledByDefault;

  void setDesc(String description) => _ruleDescription = description;
  String getDesc() => _ruleDescription;

  void setExclude(CDOMSingleRef<RuleCheck> ref) => _excludeKey = ref;
  bool isExclude() => _excludeKey != null;
  CDOMSingleRef<RuleCheck>? getExclude() => _excludeKey;

  @override
  String getKeyName() => _ruleKey ?? '';

  @override
  void setName(String name) {
    _ruleName = name;
    _ruleKey ??= name;
  }

  @override
  String getDisplayName() => _ruleName ?? '';

  String getName() => _ruleName ?? '';

  void setParameter(String aString) {
    _parm = aString;
    if (_var.isEmpty) _var = aString;
  }

  String getParameter() => _parm;

  void setVariable(String aString) => _var = aString;
  String getVariable() => _var;

  void setKeyName(String key) => _ruleKey = key;
}
