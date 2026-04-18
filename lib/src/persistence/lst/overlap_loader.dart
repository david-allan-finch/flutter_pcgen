// Copyright 2010 Tom Parker <thpr@users.sourceforge.net>
//
// Translation of pcgen.persistence.lst.OverlapLoader

import 'simple_loader.dart';

/// A SimpleLoader that uses constructNowIfNecessary instead of constructCDOMObject,
/// allowing a second definition of the same object to overlap/extend the first.
class OverlapLoader<T> extends SimpleLoader<T> {
  OverlapLoader(super.loadClass);

  @override
  T? getLoadable(dynamic context, String firstToken, Uri sourceUri) {
    final name = processFirstToken(context, firstToken);
    if (name == null) return null;
    return context
        .getReferenceContext()
        .constructNowIfNecessary(getLoadClass(), name) as T?;
  }
}
