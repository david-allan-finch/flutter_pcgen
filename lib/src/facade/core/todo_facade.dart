// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.TodoFacade

abstract interface class TodoFacade implements Comparable<TodoFacade> {
  static const String switchTabs = 'SwitchTabs';
  String getMessageKey();
  dynamic getTab();
  String getFieldName();
  String getSubTabName();
}
