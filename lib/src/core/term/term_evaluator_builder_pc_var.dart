// Copyright 2008 Andrew Wilson <nuance@users.sourceforge.net>.
//
// Translation of pcgen.core.term.TermEvaluatorBuilderPCVar

import 'fixed_term_evaluator.dart';
import 'pc_accheck_term_evaluator.dart';
import 'pc_armour_accheck_term_evaluator.dart';
import 'pc_bab_term_evaluator.dart';
import 'pc_base_cr_term_evaluator.dart';
import 'pc_base_hd_term_evaluator.dart';
import 'pc_base_spell_stat_term_evaluator.dart';
import 'pc_bl_term_evaluator.dart';
import 'pc_bonus_lang_term_evaluator.dart';
import 'pc_carried_weight_term_evaluator.dart';
import 'pc_caster_level_class_term_evaluator.dart';
import 'pc_caster_level_race_term_evaluator.dart';
import 'pc_caster_level_total_term_evaluator.dart';
import 'pc_cast_times_at_will_term_evaluator.dart';
import 'pc_cl_before_level_term_evaluator.dart';
import 'pc_cl_term_evaluator.dart';
import 'pc_count_abilities_nature_all_term_evaluator.dart';
import 'pc_count_abilities_nature_auto_term_evaluator.dart';
import 'pc_count_abilities_nature_normal_term_evaluator.dart';
import 'pc_count_abilities_nature_virtual_term_evaluator.dart';
import 'pc_count_abilities_type_nature_all_term_evaluator.dart';
import 'pc_count_abilities_type_nature_auto_term_evaluator.dart';
import 'pc_count_abilities_type_nature_virtual_term_evaluator.dart';
import 'pc_count_ability_name_term_evaluator.dart';
import 'pc_count_attacks_term_evaluator.dart';
import 'pc_count_checks_term_evaluator.dart';
import 'pc_count_classes_term_evaluator.dart';
import 'pc_count_containers_term_evaluator.dart';
import 'pc_count_domains_term_evaluator.dart';
import 'pc_count_eq_type_term_evaluator.dart';
import 'pc_count_equipment_term_evaluator.dart';
import 'pc_count_follower_type_term_evaluator.dart';
import 'pc_count_follower_type_transitive_term_evaluator.dart';
import 'pc_count_followers_term_evaluator.dart';
import 'pc_count_languages_term_evaluator.dart';
import 'pc_count_misc_companions_term_evaluator.dart';
import 'pc_count_misc_funds_term_evaluator.dart';
import 'pc_count_misc_magic_term_evaluator.dart';
import 'pc_count_move_term_evaluator.dart';
import 'pc_count_notes_term_evaluator.dart';
import 'pc_count_race_sub_types_term_evaluator.dart';
import 'pc_count_sab_term_evaluator.dart';
import 'pc_count_skill_type_term_evaluator.dart';
import 'pc_count_skills_term_evaluator.dart';
import 'pc_count_spellbook_term_evaluator.dart';
import 'pc_count_spell_classes_term_evaluator.dart';
import 'pc_count_spell_race_term_evaluator.dart';
import 'pc_count_spell_times_term_evaluator.dart';
import 'pc_count_spells_inbook_term_evaluator.dart';
import 'pc_count_spells_known_term_evaluator.dart';
import 'pc_count_spells_levels_in_book_term_evaluator.dart';
import 'pc_count_stats_term_evaluator.dart';
import 'pc_count_temp_bonus_names_term_evaluator.dart';
import 'pc_count_templates_term_evaluator.dart';
import 'pc_count_visible_templates_term_evaluator.dart';
import 'pc_count_vision_term_evaluator.dart';
import 'pc_encumberance_term_evaluator.dart';
import 'pc_eq_type_term_evaluator.dart';
import 'pc_fav_class_level_term_evaluator.dart';
import 'pc_hands_term_evaluator.dart';
import 'pc_has_class_term_evaluator.dart';
import 'pc_has_deity_term_evaluator.dart';
import 'pc_has_feat_term_evaluator.dart';
import 'pc_hd_term_evaluator.dart';
import 'pc_height_term_evaluator.dart';
import 'pc_hp_term_evaluator.dart';
import 'pc_legs_term_evaluator.dart';
import 'pc_max_castable_any_term_evaluator.dart';
import 'pc_max_castable_class_term_evaluator.dart';
import 'pc_max_castable_domain_term_evaluator.dart';
import 'pc_max_castable_spell_type_term_evaluator.dart';
import 'pc_max_level_term_evaluator.dart';
import 'pc_mod_equip_term_evaluator.dart';
import 'pc_move_base_term_evaluator.dart';
import 'pc_movement_term_evaluator.dart';
import 'pc_prof_accheck_term_evaluator.dart';
import 'pc_race_size_term_evaluator.dart';
import 'pc_racial_hd_size_term_evaluator.dart';
import 'pc_score_term_evaluator.dart';
import 'pc_shield_accheck_term_evaluator.dart';
import 'pc_size_int_eq_term_evaluator.dart';
import 'pc_size_int_term_evaluator.dart';
import 'pc_size_mod_evaluator_term_evaluator.dart';
import 'pc_size_term_evaluator.dart';
import 'pc_skill_rank_term_evaluator.dart';
import 'pc_skill_total_term_evaluator.dart';
import 'pc_spell_base_stat_score_evaluator_term_evaluator.dart';
import 'pc_spell_base_stat_term_evaluator.dart';
import 'pc_spell_level_term_evaluator.dart';
import 'pc_tl_term_evaluator.dart';
import 'pc_total_weight_term_evaluator.dart';
import 'pc_var_defined_term_evaluator.dart';
import 'pc_verbatim_text_term_evaluator.dart';
import 'pc_weight_term_evaluator.dart';
import 'term_evaluator.dart';
import 'term_evaluator_builder.dart';
import 'term_evaulator_exception.dart';

/// Enum of TermEvaluatorBuilders for PC-context term variables.
enum TermEvaluatorBuilderPCVar implements TermEvaluatorBuilder {
  completePcAccheck('AC{1,2}HECK', ['ACCHECK', 'ACHECK'], true),
  completePcArmoraccheck('ARMORAC{1,2}HECK', ['ARMORACCHECK', 'ARMORACHECK'], true),
  completePcBab('BAB', ['BAB'], true),
  completePcBasecr('BASECR', ['BASECR'], true),
  completePcBasehd('BASEHD', ['BASEHD'], true),
  completePcBasespellstat('BASESPELLSTAT', ['BASESPELLSTAT'], true),
  completePcCasterlevel(r'(?:CASTERLEVEL\.TOTAL|CASTERLEVEL)', ['CASTERLEVEL', 'CASTERLEVEL.TOTAL'], true),
  completePcCountAttacks(r'COUNT\[ATTACKS\]', ['COUNT[ATTACKS]'], true),
  completePcCountChecks(r'COUNT\[CHECKS\]', ['COUNT[CHECKS]'], true),
  completePcCountClasses(r'COUNT\[CLASSES\]', ['COUNT[CLASSES]'], true),
  completePcCountContainers(r'COUNT\[CONTAINERS\]', ['COUNT[CONTAINERS]'], true),
  completePcCountDomains(r'COUNT\[DOMAINS\]', ['COUNT[DOMAINS]'], true),
  completePcCountFeatsnatureall(r'COUNT\[FEATSALL(?:\.ALL|\.HIDDEN|\.VISIBLE)?\]',
      ['COUNT[FEATSALL]', 'COUNT[FEATSALL.ALL]', 'COUNT[FEATSALL.HIDDEN]', 'COUNT[FEATSALL.VISIBLE]'], true),
  completePcCountFeatsnatureauto(r'COUNT\[FEATSAUTO(?:\.ALL|\.HIDDEN|\.VISIBLE)?\]',
      ['COUNT[FEATSAUTO]', 'COUNT[FEATSAUTO.ALL]', 'COUNT[FEATSAUTO.HIDDEN]', 'COUNT[FEATSAUTO.VISIBLE]'], true),
  completePcCountFeatsnaturenormal(r'COUNT\[FEATS(?:\.ALL|\.HIDDEN|\.VISIBLE)?\]',
      ['COUNT[FEATS]', 'COUNT[FEATS.ALL]', 'COUNT[FEATS.HIDDEN]', 'COUNT[FEATS.VISIBLE]'], true),
  completePcCountFeatsnaturevirtual(r'COUNT\[VFEATS(?:\.ALL|\.HIDDEN|\.VISIBLE)?\]',
      ['COUNT[VFEATS]', 'COUNT[VFEATS.ALL]', 'COUNT[VFEATS.HIDDEN]', 'COUNT[VFEATS.VISIBLE]'], true),
  completePcCountFollowers(r'COUNT\[FOLLOWERS\]', ['COUNT[FOLLOWERS]'], true),
  completePcCountLanguages(r'COUNT\[LANGUAGES\]', ['COUNT[LANGUAGES]'], true),
  completePcCountMiscCompanions(r'COUNT\[MISC\.COMPANIONS\]', ['COUNT[MISC.COMPANIONS]'], true),
  completePcCountMiscFunds(r'COUNT\[MISC\.FUNDS\]', ['COUNT[MISC.FUNDS]'], true),
  completePcCountMiscMagic(r'COUNT\[MISC\.MAGIC\]', ['COUNT[MISC.MAGIC]'], true),
  completePcCountMove(r'COUNT\[MOVE\]', ['COUNT[MOVE]'], true),
  completePcCountNotes(r'COUNT\[NOTES\]', ['COUNT[NOTES]'], true),
  completePcCountRacesubtypes(r'COUNT\[RACESUBTYPES\]', ['COUNT[RACESUBTYPES]'], true),
  completePcCountSa(r'COUNT\[SA\]', ['COUNT[SA]'], true),
  completePcCountSkills(r'COUNT\[SKILLS(?:\.SELECTED|\.RANKS|\.NONDEFAULT|\.USABLE|\.ALL)?\]',
      ['COUNT[SKILLS]', 'COUNT[SKILLS.SELECTED]', 'COUNT[SKILLS.RANKS]', 'COUNT[SKILLS.NONDEFAULT]',
       'COUNT[SKILLS.USABLE]', 'COUNT[SKILLS.ALL]'], true),
  completePcCountSpellclasses(r'COUNT\[SPELLCLASSES\]', ['COUNT[SPELLCLASSES]'], true),
  completePcCountSpellrace(r'COUNT\[SPELLRACE\]', ['COUNT[SPELLRACE]'], true),
  completePcCountStats(r'COUNT\[STATS\]', ['COUNT[STATS]'], true),
  completePcCountTempbonusnames(r'COUNT\[TEMPBONUSNAMES\]', ['COUNT[TEMPBONUSNAMES]'], true),
  completePcCountTemplates(r'COUNT\[TEMPLATES\]', ['COUNT[TEMPLATES]'], true),
  completePcCountVisibletemplates(r'COUNT\[VISIBLETEMPLATES\]', ['COUNT[VISIBLETEMPLATES]'], true),
  completePcCountVision(r'COUNT\[VISION\]', ['COUNT[VISION]'], true),
  completePcEncumberance('ENCUMBERANCE', ['ENCUMBERANCE'], true),
  completePcHd('HD', ['HD'], true),
  completePcHp('HP', ['HP'], true),
  completePcMaxcastable('MAXCASTABLE', ['MAXCASTABLE'], true),
  completePcMovebase('MOVEBASE', ['MOVEBASE'], true),
  completePcPcHeight(r'PC\.HEIGHT', ['PC.HEIGHT'], false),
  completePcPcWeight(r'PC\.WEIGHT', ['PC.WEIGHT'], false),
  completePcProfaccheck('PROFACCHECK', ['PROFACCHECK'], true),
  completePcRacesize('RACESIZE', ['RACESIZE'], true),
  completePcRacialhdsize('RACIALHDSIZE', ['RACIALHDSIZE'], true),
  completePcScore('SCORE', ['SCORE'], true),
  completePcShieldaccheck(r'SHIELDAC{1,2}HECK', ['SHIELDACCHECK', 'SHIELDACHECK'], true),
  completePcSizemod(r'SIZEMOD|SIZE', ['SIZEMOD', 'SIZE'], true),
  completePcSpellbasestat(r'SPELLBASESTATSCORE|SPELLBASESTAT', ['SPELLBASESTAT', 'SPELLBASESTATSCORE'], true),
  completePcSpelllevel('SPELLLEVEL', ['SPELLLEVEL'], true),
  completePcTl('TL', ['TL'], true),
  completePcFavclasslevel('FAVCLASSLEVEL', ['FAVCLASSLEVEL'], true),
  pcCastAtwill('ATWILL', ['ATWILL'], true),
  startPcBl(r'BL[.=]?', ['BL.', 'BL=', 'BL'], false),
  startPcClBeforelevel(r'CL;BEFORELEVEL[.=]', ['CL;BEFORELEVEL.', 'CL;BEFORELEVEL='], false),
  startPcClasslevel(r'CLASSLEVEL[.=]', ['CLASSLEVEL.', 'CLASSLEVEL='], false),
  startPcClass(r'CLASS[.=]', ['CLASS.', 'CLASS='], false),
  startPcCl(r'CL[.=]?', ['CL.', 'CL=', 'CL'], false),
  startPcCountEqtype(r'COUNT\[EQTYPE\.?', ['COUNT[EQTYPE', 'COUNT[EQTYPE.'], false),
  startPcCountEquipment(r'COUNT\[EQUIPMENT\.?', ['COUNT[EQUIPMENT.', 'COUNT[EQUIPMENT'], false),
  startPcCountFeattype(r'COUNT\[(?:FEATAUTOTYPE|FEATNAME|FEATTYPE|VFEATTYPE)[.=]',
      ['COUNT[FEATAUTOTYPE.', 'COUNT[FEATAUTOTYPE=', 'COUNT[FEATNAME.', 'COUNT[FEATNAME=',
       'COUNT[FEATTYPE.', 'COUNT[FEATTYPE=', 'COUNT[VFEATTYPE.', 'COUNT[VFEATTYPE='], false),
  startPcCountFollowertype(r'COUNT\[FOLLOWERTYPE\.', ['COUNT[FOLLOWERTYPE.'], false),
  startPcCountSkilltype(r'COUNT\[SKILLTYPE[.=]', ['COUNT[SKILLTYPE.', 'COUNT[SKILLTYPE='], false),
  startPcCountSpellbooks(r'COUNT\[SPELLBOOKS', ['COUNT[SPELLBOOKS'], false),
  startPcCountSpellsinbook(r'COUNT\[SPELLSINBOOK', ['COUNT[SPELLSINBOOK'], false),
  startPcCountSpellsknown(r'COUNT\[SPELLSKNOWN', ['COUNT[SPELLSKNOWN'], false),
  startPcCountSpellslevelsinbook(r'COUNT\[SPELLSLEVELSINBOOK', ['COUNT[SPELLSLEVELSINBOOK'], false),
  startPcCountSpelltimes(r'COUNT\[SPELLTIMES', ['COUNT[SPELLTIMES'], false),
  startPcEqtype('EQTYPE', ['EQTYPE'], false),
  startPcHasdeity('HASDEITY:', ['HASDEITY:'], false),
  startPcHasfeat('HASFEAT:', ['HASFEAT:'], false),
  startPcMaxlevel('MAXLEVEL', ['MAXLEVEL'], true),
  startPcModequip('MODEQUIP', ['MODEQUIP'], false),
  startPcMove(r'MOVE\[', ['MOVE['], false),
  startPcPcSize(r'PC\.SIZE(?:\.INT)?', ['PC.SIZE.INT', 'PC.SIZE'], false),
  startPcSkillrank(r'SKILLRANK[.=]', ['SKILLRANK.', 'SKILLRANK='], false),
  startPcSkilltotal(r'SKILLTOTAL[.=]', ['SKILLTOTAL.', 'SKILLTOTAL='], false),
  startPcVardefined('VARDEFINED:', ['VARDEFINED:'], false),
  startPcWeight(r'WEIGHT\.', ['WEIGHT.'], false),
  completePcBonuslang('BONUSLANG', ['BONUSLANG'], true),
  completePcHands('HANDS', ['HANDS'], true),
  completePcLegs('LEGS', ['LEGS'], true);

  const TermEvaluatorBuilderPCVar(this._pattern, this._keys, this._entireTerm);

  final String _pattern;
  final List<String> _keys;
  final bool _entireTerm;

  static final RegExp _subtokenPat =
      RegExp(r'(FEATAUTOTYPE|FEATNAME|FEATTYPE|VFEATTYPE)');
  static final RegExp _numPat = RegExp(r'\d+');

  @override
  String getTermConstructorPattern() => _pattern;

  @override
  List<String> getTermConstructorKeys() => _keys;

  @override
  bool isEntireTerm() => _entireTerm;

  @override
  TermEvaluator? getTermEvaluator(
      String expressionString, String src, String matchedSection) {
    switch (this) {
      case completePcAccheck:
        return PCACcheckTermEvaluator(expressionString);
      case completePcArmoraccheck:
        return PCArmourACcheckTermEvaluator(expressionString);
      case completePcBab:
        return PCBABTermEvaluator(expressionString);
      case completePcBasecr:
        return PCBaseCRTermEvaluator(expressionString);
      case completePcBasehd:
        return PCBaseHDTermEvaluator(expressionString);
      case completePcBasespellstat:
        final source = src.startsWith('CLASS:') ? src.substring(6) : '';
        return PCBaseSpellStatTermEvaluator(expressionString, source);
      case completePcCasterlevel:
        if (matchedSection == 'CASTERLEVEL') {
          if (src.startsWith('RACE:')) {
            return PCCasterLevelRaceTermEvaluator(expressionString, src.substring(5));
          } else if (src.startsWith('CLASS:')) {
            return PCCasterLevelClassTermEvaluator(expressionString, src.substring(6));
          }
        }
        return PCCasterLevelTotalTermEvaluator(expressionString);
      case completePcCountAttacks:
        return PCCountAttacksTermEvaluator(expressionString);
      case completePcCountChecks:
        return PCCountChecksTermEvaluator(expressionString);
      case completePcCountClasses:
        return PCCountClassesTermEvaluator(expressionString);
      case completePcCountContainers:
        return PCCountContainersTermEvaluator(expressionString);
      case completePcCountDomains:
        return PCCountDomainsTermEvaluator(expressionString);
      case completePcCountFeatsnatureall:
        return PCCountAbilitiesNatureAllTermEvaluator(
            expressionString, null,
            !expressionString.endsWith('HIDDEN]'),
            expressionString.endsWith('HIDDEN]') || expressionString.endsWith('.ALL]'));
      case completePcCountFeatsnatureauto:
        return PCCountAbilitiesNatureAutoTermEvaluator(
            expressionString, null,
            !expressionString.endsWith('HIDDEN]'),
            expressionString.endsWith('HIDDEN]') || expressionString.endsWith('ALL]'));
      case completePcCountFeatsnaturenormal:
        return PCCountAbilitiesNatureNormalTermEvaluator(
            expressionString, null,
            !expressionString.endsWith('HIDDEN]'),
            expressionString.endsWith('HIDDEN]') || expressionString.endsWith('ALL]'));
      case completePcCountFeatsnaturevirtual:
        return PCCountAbilitiesNatureVirtualTermEvaluator(
            expressionString, null,
            !expressionString.endsWith('HIDDEN]'),
            expressionString.endsWith('HIDDEN]') || expressionString.endsWith('ALL]'));
      case completePcCountFollowers:
        return PCCountFollowersTermEvaluator(expressionString);
      case completePcCountLanguages:
        return PCCountLanguagesTermEvaluator(expressionString);
      case completePcCountMiscCompanions:
        return PCCountMiscCompanionsTermEvaluator(expressionString);
      case completePcCountMiscFunds:
        return PCCountMiscFundsTermEvaluator(expressionString);
      case completePcCountMiscMagic:
        return PCCountMiscMagicTermEvaluator(expressionString);
      case completePcCountMove:
        return PCCountMoveTermEvaluator(expressionString);
      case completePcCountNotes:
        return PCCountNotesTermEvaluator(expressionString);
      case completePcCountRacesubtypes:
        return PCCountRaceSubTypesTermEvaluator(expressionString);
      case completePcCountSa:
        return PCCountSABTermEvaluator(expressionString);
      case completePcCountSkills:
        String? filterToken;
        final dot = expressionString.indexOf('.');
        if (dot > 0) {
          final end = expressionString.indexOf(']', dot);
          filterToken = expressionString.substring(dot + 1, end);
        }
        return PCCountSkillsTermEvaluator(expressionString, filterToken);
      case completePcCountSpellclasses:
        return PCCountSpellClassesTermEvaluator(expressionString);
      case completePcCountSpellrace:
        return PCCountSpellRaceTermEvaluator(expressionString);
      case completePcCountStats:
        return PCCountStatsTermEvaluator(expressionString);
      case completePcCountTempbonusnames:
        return PCCountTempBonusNamesTermEvaluator(expressionString);
      case completePcCountTemplates:
        return PCCountTemplatesTermEvaluator(expressionString);
      case completePcCountVisibletemplates:
        return PCCountVisibleTemplatesTermEvaluator(expressionString);
      case completePcCountVision:
        return PCCountVisionTermEvaluator(expressionString);
      case completePcEncumberance:
        return PCEncumberanceTermEvaluator(expressionString);
      case completePcHd:
        return PCHDTermEvaluator(expressionString);
      case completePcHp:
        return PCHPTermEvaluator(expressionString);
      case completePcMaxcastable:
        if (src.startsWith('CLASS:')) {
          return PCMaxCastableClassTermEvaluator(expressionString, src.substring(6));
        } else if (src.startsWith('DOMAIN:')) {
          return PCMaxCastableDomainTermEvaluator(expressionString, src.substring(7));
        } else if (src.startsWith('SPELLTYPE:')) {
          return PCMaxCastableSpellTypeTermEvaluator(expressionString, src.substring(10));
        } else if (src == 'ANY') {
          return PCMaxCastableAnyTermEvaluator(expressionString);
        }
        throw TermEvaulatorException('MAXCASTABLE is not usable in $src');
      case completePcMovebase:
        return PCMoveBaseTermEvaluator(expressionString);
      case completePcPcHeight:
        return PCHeightTermEvaluator(expressionString);
      case completePcPcWeight:
        return PCWeightTermEvaluator(expressionString);
      case completePcProfaccheck:
        final eqSrc = src.startsWith('EQ:') ? src.substring(3) : '';
        return PCProfACCheckTermEvaluator(expressionString, eqSrc);
      case completePcRacesize:
        return PCRaceSizeTermEvaluator(expressionString);
      case completePcRacialhdsize:
        return PCRacialHDSizeTermEvaluator(expressionString);
      case completePcScore:
        final n = int.tryParse(src);
        if (n != null) return FixedTermEvaluator(expressionString, n);
        final statSrc = src.startsWith('STAT:') ? src.substring(5) : '';
        return PCScoreTermEvaluator(expressionString, statSrc);
      case completePcShieldaccheck:
        return PCShieldACcheckTermEvaluator(expressionString);
      case completePcSizemod:
        return matchedSection == 'SIZEMOD'
            ? PCSizeModEvaluatorTermEvaluator(expressionString)
            : PCSizeTermEvaluator(expressionString);
      case completePcSpellbasestat:
        final clsSrc = src.startsWith('CLASS:') ? src.substring(6) : '';
        return expressionString.endsWith('SCORE')
            ? PCSpellBaseStatScoreEvaluatorTermEvaluator(expressionString, clsSrc)
            : PCSpellBaseStatTermEvaluator(expressionString, clsSrc);
      case completePcSpelllevel:
        return PCSpellLevelTermEvaluator(expressionString);
      case completePcTl:
        return PCTLTermEvaluator(expressionString);
      case completePcFavclasslevel:
        return PCFavClassLevelTermEvaluator(expressionString);
      case pcCastAtwill:
        return PCCastTimesAtWillTermEvaluator(expressionString);
      case startPcBl:
        final classString = matchedSection.length == expressionString.length
            ? (src.startsWith('CLASS:') ? src.substring(6) : '')
            : expressionString.substring(matchedSection.length);
        return PCBLTermEvaluator(expressionString, classString);
      case startPcClBeforelevel:
        if (!src.startsWith('CLASS:')) {
          throw TermEvaulatorException('$matchedSection may only be used in a Class');
        }
        final lvl = int.tryParse(expressionString.substring(15));
        if (lvl == null) {
          throw TermEvaulatorException(
              'Badly formed formula $expressionString in $src should have an integer following $matchedSection');
        }
        return PCCLBeforeLevelTermEvaluator(expressionString, src.substring(6), lvl);
      case startPcClasslevel:
        final exp = expressionString.replaceAll('{', '(').replaceAll('}', ')');
        return PCCLTermEvaluator(expressionString, exp.substring(11));
      case startPcClass:
        return PCHasClassTermEvaluator(expressionString, expressionString.substring(6));
      case startPcCl:
        if (expressionString.length == 2) {
          if (!src.startsWith('CLASS:')) {
            throw TermEvaulatorException('$matchedSection may only be used in a Class');
          }
          return PCCLTermEvaluator(expressionString,
              src.startsWith('CLASS:') ? src.substring(6) : '');
        }
        return PCCLTermEvaluator(expressionString, expressionString.substring(3));
      case startPcCountEqtype:
        return _buildCountEqType(expressionString, src, matchedSection);
      case startPcCountEquipment:
        return _buildCountEquipment(expressionString, src, matchedSection);
      case startPcCountFeattype:
        return _buildCountFeatType(expressionString, src, matchedSection);
      case startPcCountFollowertype:
        return _buildCountFollowerType(expressionString, src);
      case startPcCountSkilltype:
        final type = _extractBracketContents(expressionString, 16);
        return PCSkillTypeTermEvaluator(expressionString, type);
      case startPcCountSpellbooks:
        _extractBracketContents(expressionString, 16);
        return PCCountSpellbookTermEvaluator(expressionString);
      case startPcCountSpellsinbook:
        return PCCountSpellsInbookTermEvaluator(
            expressionString, _extractBracketContents(expressionString, 19));
      case startPcCountSpellsknown:
        return _buildCountSpellsKnown(expressionString, src, matchedSection);
      case startPcCountSpellslevelsinbook:
        return _buildCountSpellsLevelsInBook(expressionString, src, matchedSection);
      case startPcCountSpelltimes:
        return _buildCountSpellTimes(expressionString, src, matchedSection);
      case startPcEqtype:
        return PCEqTypeTermEvaluator(expressionString);
      case startPcHasdeity:
        return PCHasDeityTermEvaluator(expressionString, expressionString.substring(9));
      case startPcHasfeat:
        return PCHasFeatTermEvaluator(expressionString, expressionString.substring(8));
      case startPcMaxlevel:
        final mlSrc = (src.startsWith('CLASS:') || src.startsWith('CLASS|'))
            ? src.substring(6) : '';
        return PCMaxLevelTermEvaluator(expressionString, mlSrc);
      case startPcModequip:
        return PCModEquipTermEvaluator(expressionString, expressionString.substring(8));
      case startPcMove:
        return PCMovementTermEvaluator(
            expressionString, _extractBracketContents(expressionString, 5));
      case startPcPcSize:
        if (matchedSection.length == 11) {
          return src.startsWith('EQ:')
              ? PCSizeIntEQTermEvaluator(expressionString, src.substring(3))
              : PCSizeIntTermEvaluator(expressionString);
        }
        return PCSizeTermEvaluator(expressionString);
      case startPcSkillrank:
        return PCSkillRankTermEvaluator(expressionString,
            expressionString.substring(10).replaceAll('{', '(').replaceAll('}', ')'));
      case startPcSkilltotal:
        return PCSkillTotalTermEvaluator(expressionString,
            expressionString.substring(11).replaceAll('{', '(').replaceAll('}', ')'));
      case startPcVardefined:
        return PCVarDefinedTermEvaluator(expressionString, expressionString.substring(11));
      case startPcWeight:
        return _buildWeight(expressionString);
      case completePcBonuslang:
        return PCBonusLangTermEvaluator(expressionString);
      case completePcHands:
        return PCHandsTermEvaluator(expressionString);
      case completePcLegs:
        return PCLegsTermEvaluator(expressionString);
    }
  }

  // ---- helpers ----

  static String _extractBracketContents(String expr, int prefixLen) {
    final open = expr.indexOf('[');
    final close = expr.lastIndexOf(']');
    if (open < 0 || close < 0 || close <= open) return '';
    return expr.substring(open + prefixLen - (prefixLen - (open + 1)), close);
  }

  static TermEvaluator _buildCountEqType(
      String expr, String src, String matched) {
    final inner = _extractBracketContents(expr, matched.length);
    final fullTypes = inner.split('.');
    const mergeNone = 1, mergeLoc = 2, mergeAll = 0;
    final merge = fullTypes[0] == 'MERGENONE'
        ? mergeNone
        : fullTypes[0] == 'MERGELOC'
            ? mergeLoc
            : mergeAll;
    final first = merge == mergeAll ? 0 : 1;
    final types = fullTypes.length > first
        ? fullTypes.sublist(first)
        : [''];
    return PCCountEqTypeTermEvaluator(expr, types, merge);
  }

  static TermEvaluator _buildCountEquipment(
      String expr, String src, String matched) {
    final inner = _extractBracketContents(expr, matched.length);
    final fullTypes = inner.split('.');
    const mergeNone = 1, mergeLoc = 2, mergeAll = 0;
    final merge = fullTypes[0] == 'MERGENONE'
        ? mergeNone
        : fullTypes[0] == 'MERGELOC'
            ? mergeLoc
            : mergeAll;
    final first = merge == mergeAll ? 0 : 1;
    final types =
        fullTypes.length > first ? fullTypes.sublist(first) : [''];
    return PCCountEquipmentTermEvaluator(expr, types, merge);
  }

  static TermEvaluator _buildCountFeatType(
      String expr, String src, String matched) {
    final subtokenMatch = _subtokenPat.firstMatch(expr);
    if (subtokenMatch == null) {
      throw TermEvaulatorException('Impossible error parsing "$expr" in $src');
    }
    final start = expr.startsWith('COUNT[FEATA')
        ? 19
        : expr.startsWith('COUNT[V')
            ? 16
            : 15;
    final inner = _extractBracketContents(expr, start);
    var types = inner.split('.');
    final visible = !expr.endsWith('HIDDEN]');
    final hidden = expr.endsWith('HIDDEN]') || expr.endsWith('ALL]');
    final last = types.last;
    if (last == 'ALL' || last == 'HIDDEN' || last == 'VISIBLE') {
      types = types.length > 1 ? types.sublist(0, types.length - 1) : [''];
    }
    final subtoken = subtokenMatch.group(0)!;
    if (subtoken == 'FEATAUTOTYPE') {
      return PCCountAbilitiesTypeNatureAutoTermEvaluator(expr, null, types, visible, hidden);
    } else if (subtoken == 'FEATNAME') {
      return PCCountAbilityNameTermEvaluator(expr, null, types[0], visible, hidden);
    } else if (subtoken == 'FEATTYPE') {
      return PCCountAbilitiesTypeNatureAllTermEvaluator(expr, null, types, visible, hidden);
    } else {
      return PCCountAbilitiesTypeNatureVirtualTermEvaluator(expr, null, types, visible, hidden);
    }
  }

  static TermEvaluator _buildCountFollowerType(String expr, String src) {
    final inner = _extractBracketContents(expr, 19);
    final parts = inner.split('.').take(3).toList();
    if (parts.length == 1) {
      return PCCountFollowerTypeTermEvaluator(expr, parts[0]);
    } else if (parts.length == 2) {
      throw TermEvaulatorException('Badly formed formula $expr in $src');
    } else {
      final numMatch = _numPat.firstMatch(parts[1]);
      if (numMatch == null) {
        throw TermEvaulatorException('Badly formed formula $expr in $src');
      }
      return PCCountFollowerTypeTransitiveTermEvaluator(
          expr, parts[0], int.parse(numMatch.group(0)!), 'COUNT[${parts[2]}]');
    }
  }

  static TermEvaluator _buildCountSpellsKnown(
      String expr, String src, String matched) {
    final spellsString = _extractBracketContents(expr, 17);
    var nums = [-1];
    if (spellsString.length > 1 && spellsString.startsWith('.')) {
      final s = spellsString.substring(1);
      nums = s.split('.').map((p) => int.tryParse(p) ?? -1).toList();
    }
    return PCCountSpellsKnownTermEvaluator(expr, nums);
  }

  static TermEvaluator _buildCountSpellsLevelsInBook(
      String expr, String src, String matched) {
    final intString = _extractBracketContents(expr, 24);
    if (intString.length > 1 && intString.startsWith('.')) {
      final nums = intString.substring(1).split('.').map((p) => int.tryParse(p) ?? -1).toList();
      return PCCountSpellsLevelsInBookTermEvaluator(expr, nums);
    }
    throw TermEvaulatorException(
        'Badly formed formula $expr following $matched should be 2 integers separated by dots');
  }

  static TermEvaluator _buildCountSpellTimes(
      String expr, String src, String matched) {
    final intString = _extractBracketContents(expr, 16);
    if (intString.length > 1 && intString.startsWith('.')) {
      final nums = intString.substring(1).split('.').map((p) => int.tryParse(p) ?? -1).toList();
      return PCCountSpellTimesTermEvaluator(expr, nums);
    }
    throw TermEvaulatorException(
        'Badly formed formula $expr following $matched should be 4 integers separated by dots');
  }

  static TermEvaluator _buildWeight(String expr) {
    final valString = expr.substring(7);
    switch (valString) {
      case 'CARRIED':
      case 'EQUIPPED':
        return PCCarriedWeightTermEvaluator(expr);
      case 'PC':
        return PCWeightTermEvaluator(expr);
      case 'TOTAL':
        return PCTotalWeightTermEvaluator(expr);
    }
    throw TermEvaulatorException('invalid string following WEIGHT. in $expr');
  }
}
