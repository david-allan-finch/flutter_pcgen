// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.LoadableFacade

enum LoadingState { unloaded, loading, loaded, error }

abstract interface class LoadableFacade {
  bool isModifiable();
  LoadingState getLoadingState();
  String getLoadingErrorMessage();
}
