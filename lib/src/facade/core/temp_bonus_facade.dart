// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.TempBonusFacade

import 'info_facade.dart';

abstract interface class TempBonusFacade implements InfoFacade {
  String getOriginType();
  bool isActive();
}
