// Copyright (c) Tom Parker, 2007.
//
// Translation of pcgen.cdom.reference.SimpleReferenceManufacturer

import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/reference/abstract_reference_manufacturer.dart';

/// A ReferenceManufacturer for non-categorized CDOMObjects.
class SimpleReferenceManufacturer<T extends Loadable>
    extends AbstractReferenceManufacturer<T> {
  SimpleReferenceManufacturer(super.factory);

  @override
  String toString() =>
      'SimpleReferenceManufacturer: ${getReferenceDescription()}';
}
