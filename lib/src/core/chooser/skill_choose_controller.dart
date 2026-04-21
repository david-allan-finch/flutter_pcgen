// Copyright (c) Andrew Maitland, 2016.
//
// Translation of pcgen.core.chooser.SkillChooseController

import 'package:flutter_pcgen/src/core/chooser/choose_controller.dart';

/// Controls pool size for skill-rank-based choosers (e.g. CHOOSE:SKILLSNAMED).
class SkillChooseController extends ChooseController<dynamic> {
  final dynamic skill;
  final dynamic pc;

  SkillChooseController(this.skill, this.pc);

  @override
  int getPool() {
    final totalRank = (pc.getTotalRank(skill) as num).toInt();
    final associations = pc.getAssociationList(skill) as List;
    return totalRank - associations.length;
  }

  @override
  bool isMultYes() => true;

  @override
  int getTotalChoices() => 0x7FFFFFFF;
}
