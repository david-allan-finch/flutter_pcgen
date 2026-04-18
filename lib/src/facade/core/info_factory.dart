// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.InfoFactory

abstract interface class InfoFactory {
  String getLevelAdjustment(dynamic template);
  String getModifier(dynamic template);
  String getPreReqHTML(dynamic obj);
  double getCost(dynamic equipment);
  double getWeight(dynamic equipment);
  String getStatAdjustments(dynamic race);
  String getVision(dynamic race);
  String getFavoredClass(dynamic race);
  String getMovement(dynamic race);
  int getNumMonsterClassLevels(dynamic race);
  String getHTMLInfo(dynamic obj, [dynamic parentClass]);
}
