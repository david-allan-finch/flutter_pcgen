// Translation of pcgen.gui2.facade.CompanionStub

import '../../core/race.dart';
import '../../facade/core/companion_stub_facade.dart';
import '../../facade/util/default_reference_facade.dart';
import '../../facade/util/reference_facade.dart';

/// Contains a definition of a possible companion (i.e. animal companion,
/// familiar, follower etc) for a character.
class CompanionStub implements CompanionStubFacade {
  final DefaultReferenceFacade<Race> _race;
  final String _companionType;

  CompanionStub(Race race, String companionType)
      : _race = DefaultReferenceFacade(race),
        _companionType = companionType;

  @override
  ReferenceFacade<Race> getRaceRef() => _race;

  @override
  String getCompanionType() => _companionType;

  @override
  String toString() => _race.toString();
}
