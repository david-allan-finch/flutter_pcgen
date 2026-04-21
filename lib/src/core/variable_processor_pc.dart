//
// VariableProcessorgetPc().java
// Copyright 2004 (C) Chris Ward <frugal@purplewombat.co.uk>
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
// Translation of pcgen.core.VariableProcessorPC
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/term/evaluator_factory.dart';
import 'package:flutter_pcgen/src/core/variable_processor.dart';

// Variable processor for player-character-scoped variables.
class VariableProcessorPC extends VariableProcessor {
  VariableProcessorPC(PlayerCharacter pc) : super(pc);

  @override
  double? getInternalVariable(dynamic aSpell, String valString, String src) {
    final evaluator = EvaluatorFactory.pc.getTermEvaluator(valString, src);
    if (evaluator == null) return null;
    return evaluator.resolve(pc, aSpell);
  }
}
