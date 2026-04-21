//
// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.rules.context.TrackingManufacturer
import 'package:flutter_pcgen/src/base/util/format_manager.dart';
import 'package:flutter_pcgen/src/base/util/indirect.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/base/class_identity.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_group_ref.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';
import 'package:flutter_pcgen/src/cdom/reference/manufacturable_factory.dart';
import 'package:flutter_pcgen/src/cdom/reference/reference_manufacturer.dart';
import 'package:flutter_pcgen/src/cdom/reference/unconstructed_listener.dart';
import 'package:flutter_pcgen/src/cdom/reference/unconstructed_validator.dart';
import 'tracking_reference_context.dart';

class TrackingManufacturer<T extends Loadable>
    implements ReferenceManufacturer<T> {
  final ReferenceManufacturer<T> _rm;
  final TrackingReferenceContext _context;

  TrackingManufacturer(TrackingReferenceContext trc, ReferenceManufacturer<T> mfg)
      : _context = trc,
        _rm = mfg;

  @override
  void addObject(T o, String key) => _rm.addObject(o, key);

  @override
  void addUnconstructedListener(UnconstructedListener listener) =>
      _rm.addUnconstructedListener(listener);

  @override
  void buildDeferredObjects() => _rm.buildDeferredObjects();

  @override
  void constructIfNecessary(String value) => _rm.constructIfNecessary(value);

  @override
  T constructNowIfNecessary(String name) => _rm.constructNowIfNecessary(name);

  @override
  T constructObject(String key) => _rm.constructObject(key);

  @override
  bool containsObjectKeyed(String key) => _rm.containsObjectKeyed(key);

  @override
  bool forgetObject(T o) => _rm.forgetObject(o);

  @override
  T? getActiveObject(String key) => _rm.getActiveObject(key);

  @override
  List<T> getAllObjects() => _rm.getAllObjects();

  // stub: CDOMGroupRef/getAllReference not in current ReferenceManufacturer interface
  CDOMGroupRef<T> getAllReference() {
    final ref = (_rm as dynamic).getAllReference() as CDOMGroupRef<T>; // stub
    _context.trackReference(ref);
    return ref;
  }

  @override
  int getConstructedObjectCount() => _rm.getConstructedObjectCount();

  @override
  T? getObject(String key) => _rm.getObject(key);

  // stub: CDOMSingleRef/getReference not in current ReferenceManufacturer interface
  CDOMSingleRef<T> getReference(String key) {
    final ref = (_rm as dynamic).getReference(key) as CDOMSingleRef<T>; // stub
    _context.trackReference(ref);
    return ref;
  }

  // stub: getReferenceClass not in current ReferenceManufacturer interface
  Type getReferenceClass() => (_rm as dynamic).getReferenceClass() as Type; // stub

  // stub: getTypeReference not in current ReferenceManufacturer interface
  CDOMGroupRef<T> getTypeReference(List<String> types) {
    final ref = (_rm as dynamic).getTypeReference(types) as CDOMGroupRef<T>; // stub
    _context.trackReference(ref);
    return ref;
  }

  @override
  List<UnconstructedListener> getUnconstructedListeners() =>
      _rm.getUnconstructedListeners();

  @override
  void removeUnconstructedListener(UnconstructedListener listener) =>
      _rm.removeUnconstructedListener(listener);

  @override
  void renameObject(String key, T o) => _rm.renameObject(key, o);

  @override
  bool resolveReferences(UnconstructedValidator validator) =>
      _rm.resolveReferences(validator);

  @override
  bool validate(UnconstructedValidator validator) => _rm.validate(validator);

  // stub: getReferenceDescription not in current ReferenceManufacturer interface
  String getReferenceDescription() =>
      (_rm as dynamic).getReferenceDescription() as String; // stub

  @override
  T buildObject(String name) => _rm.buildObject(name);

  @override
  void fireUnconstructedEvent(CDOMReference<dynamic> reference) =>
      _rm.fireUnconstructedEvent(reference);

  @override
  List<CDOMSingleRef<T>> getReferenced() => _rm.getReferenced();

  // stub: getFactory not in current ReferenceManufacturer interface
  ManufacturableFactory<T> getFactory() =>
      (_rm as dynamic).getFactory() as ManufacturableFactory<T>; // stub

  // stub: getAllReferences not in current ReferenceManufacturer interface
  List<CDOMReference<T>> getAllReferences() =>
      (_rm as dynamic).getAllReferences() as List<CDOMReference<T>>; // stub

  // stub: injectConstructed not in current ReferenceManufacturer interface
  // Note: Java source has a bug here (passes mfg.injectConstructed(mfg));
  // faithfully reproduced.
  void injectConstructed(ReferenceManufacturer<T> mfg) {
    (mfg as dynamic).injectConstructed(mfg); // stub
  }

  // stub: addDerivativeObject not in current ReferenceManufacturer interface
  void addDerivativeObject(T obj) =>
      (_rm as dynamic).addDerivativeObject(obj); // stub

  // stub: getDerivativeObjects not in current ReferenceManufacturer interface
  List<T> getDerivativeObjects() =>
      (_rm as dynamic).getDerivativeObjects() as List<T>; // stub

  @override
  T convert(String arg) => _rm.convert(arg);

  @override
  Indirect<T> convertIndirect(String arg) => _rm.convertIndirect(arg);

  @override
  String getIdentifierType() => _rm.getIdentifierType();

  @override
  Type getManagedClass() => _rm.getManagedClass();

  @override
  String unconvert(T arg) => _rm.unconvert(arg);

  @override
  FormatManager<dynamic>? getComponentManager() => null;

  // stub: isDirect not in current ReferenceManufacturer interface
  bool isDirect() => (_rm as dynamic).isDirect() as bool; // stub

  // stub: getReferenceIdentity not in current ReferenceManufacturer interface
  ClassIdentity<T> getReferenceIdentity() =>
      (_rm as dynamic).getReferenceIdentity() as ClassIdentity<T>; // stub

  // stub: getPersistentFormat not in current ReferenceManufacturer interface
  String getPersistentFormat() =>
      (_rm as dynamic).getPersistentFormat() as String; // stub

  @override
  int get hashCode => 37 + _rm.hashCode;

  @override
  bool operator ==(Object other) =>
      other is TrackingManufacturer && _rm == other._rm;
}
