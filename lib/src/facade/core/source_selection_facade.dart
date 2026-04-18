// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.SourceSelectionFacade

import 'loadable_facade.dart';

abstract interface class SourceSelectionFacade implements LoadableFacade {
  List<dynamic> getCampaigns();
  void setCampaigns(List<dynamic> campaigns);
  void setGameMode(dynamic gameMode);
  dynamic getGameModeRef();
  @override
  String toString();
}
