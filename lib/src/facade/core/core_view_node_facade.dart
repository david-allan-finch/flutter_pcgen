// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.CoreViewNodeFacade

abstract interface class CoreViewNodeFacade {
  List<CoreViewNodeFacade> getGrantedByNodes();
  String getNodeType();
  String getKey();
  String getSource();
  String getRequirements();
}
