import '../../cdom/base/cdom_single_ref.dart';
import '../deity.dart';
import '../domain.dart';
import '../kit.dart';
import '../player_character.dart';
import 'base_kit.dart';

class KitDeity extends BaseKit {
  CDOMSingleRef<Deity>? _theDeityRef;
  String? _choiceCountFormula; // formula string
  List<CDOMSingleRef<Domain>>? _theDomains;

  // Instance state
  Deity? _theDeity;
  List<Domain>? _domainsToAdd;

  void setDeity(CDOMSingleRef<Deity> ref) { _theDeityRef = ref; }
  CDOMSingleRef<Deity>? getDeityRef() => _theDeityRef;

  void setCount(String formula) { _choiceCountFormula = formula; }
  String? getCount() => _choiceCountFormula;

  void addDomain(CDOMSingleRef<Domain> ref) {
    _theDomains ??= [];
    _theDomains!.add(ref);
  }

  List<CDOMSingleRef<Domain>>? getDomains() =>
      _theDomains == null ? null : List.unmodifiable(_theDomains!);

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    _domainsToAdd = null;
    _theDeity = _theDeityRef?.get();
    if (_theDeity == null) return false;

    if (!aPC.canSelectDeity(_theDeity!)) {
      warnings.add('DEITY: Cannot select deity "${_theDeity!.getDisplayName()}"');
      return false;
    }
    aPC.setDeity(_theDeity!);

    if (_theDomains == null || _theDomains!.isEmpty) return true;
    if (aPC.getMaxCharacterDomains() <= 0) {
      warnings.add('DEITY: Not allowed to choose a domain');
      return true;
    }

    int numberOfChoices = _choiceCountFormula == null
        ? _theDomains!.length
        : aPC.getVariableValue(_choiceCountFormula!, '').toInt();
    if (numberOfChoices > _theDomains!.length) numberOfChoices = _theDomains!.length;
    if (numberOfChoices == 0) return true;

    // Use all domains if count equals total; otherwise take first N
    final xs = numberOfChoices == _theDomains!.length
        ? _theDomains!
        : _theDomains!.sublist(0, numberOfChoices);

    for (final ref in xs) {
      final domain = ref.get();
      if (!domain.qualifies(aPC, domain)) {
        warnings.add('DEITY: Not qualified for domain "${domain.getDisplayName()}"');
        continue;
      }
      if (aPC.getDomainCount() >= aPC.getMaxCharacterDomains()) {
        warnings.add('DEITY: No more allowed domains');
        return false;
      }
      if (!aPC.hasDefaultDomainSource()) {
        warnings.add('DEITY: Cannot add domain "${domain.getDisplayName()}" — no domain source.');
        return false;
      }
      _domainsToAdd ??= [];
      _domainsToAdd!.add(domain);
      aPC.addDomain(domain);
      aPC.applyDomain(domain);
    }
    aPC.calcActiveBonuses();
    return true;
  }

  @override
  void apply(PlayerCharacter aPC) {
    if (_theDeity == null) return;
    aPC.setDeity(_theDeity!);
    for (final domain in _domainsToAdd ?? []) {
      aPC.addDomain(domain);
      aPC.applyDomain(domain);
    }
    aPC.calcActiveBonuses();
    _theDeity = null;
    _domainsToAdd = null;
  }

  @override
  String getObjectName() => 'Deity';

  @override
  String toString() {
    final buf = StringBuffer(_theDeityRef?.getLSTformat(false) ?? '');
    if (_theDomains != null && _theDomains!.isNotEmpty) {
      buf.write(' (');
      if (_choiceCountFormula != null) buf.write('$_choiceCountFormula of ');
      buf.write(_theDomains!.map((r) => r.toString()).join(', '));
      buf.write(')');
    }
    return buf.toString();
  }
}
