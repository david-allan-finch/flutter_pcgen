// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.SourceSelectionFacade

import 'package:flutter_pcgen/src/facade/util/reference_facade.dart';
import 'loadable_facade.dart';

abstract interface class SourceSelectionFacade implements LoadableFacade {
  List<dynamic> getCampaigns();
  void setCampaigns(List<dynamic> campaigns);
  void setGameMode(dynamic gameMode);
  // Returns an observable reference to the current game mode.
  ReferenceFacade<dynamic> getGameMode();
  ReferenceFacade<dynamic> getGameModeRef();
  @override
  String toString();
}
