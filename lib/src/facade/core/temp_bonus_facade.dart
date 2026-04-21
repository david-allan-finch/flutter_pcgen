// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.TempBonusFacade

import 'package:flutter_pcgen/src/facade/core/info_facade.dart';

abstract interface class TempBonusFacade implements InfoFacade {
  String getOriginType();
  bool isActive();
}
