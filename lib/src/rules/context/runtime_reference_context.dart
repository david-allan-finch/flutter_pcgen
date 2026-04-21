//
// Copyright 2007 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.rules.context.RuntimeReferenceContext
import '../../base/util/case_insensitive_map.dart';
import '../../cdom/base/cdom_object.dart';
import '../../cdom/base/class_identity.dart';
import '../../cdom/base/loadable.dart';
import '../../cdom/reference/cdom_factory.dart';
import '../../cdom/reference/manufacturable_factory.dart';
import '../../cdom/reference/reference_manufacturer.dart';
import '../../cdom/reference/unconstructed_validator.dart';

// stub: BasicClassIdentity not yet translated
class BasicClassIdentity {
  static ClassIdentity<T> getIdentity<T>(Type cl) {
    throw UnimplementedError('BasicClassIdentity.getIdentity stub'); // stub
  }
}

// stub: SimpleReferenceManufacturer not yet translated
class SimpleReferenceManufacturer<T extends Loadable>
    implements ReferenceManufacturer<T> {
  final dynamic _factory;
  SimpleReferenceManufacturer(this._factory);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString()); // stub
}

/// Minimal abstract base that mirrors Java's AbstractReferenceContext API
/// as needed by RuntimeReferenceContext and its subclasses.
///
/// The pre-existing abstract_reference_context.dart is a simpler stub;
/// this class extends the new full API.
abstract class AbstractReferenceContext {
  // Called once after construction to register base class types.
  void initialize() {
    // stub: base implementation registers StringPClassUtil.getBaseClasses()
  }

  // Returns a manufacturer for objects of the given non-categorised type.
  ReferenceManufacturer<T> getManufacturer<T extends Loadable>(Type cl);

  // Returns a manufacturer keyed by ClassIdentity.
  ReferenceManufacturer<T> getManufacturerId<T extends Loadable>(
      ClassIdentity<T> identity);

  // Returns a manufacturer keyed by a ManufacturableFactory.
  ReferenceManufacturer<T> getManufacturerFac<T extends Loadable>(
      ManufacturableFactory<T> factory);

  // Returns a manufacturer for the given persistent-format name and class.
  ReferenceManufacturer<T>? getManufacturerByFormatName<T extends Loadable>(
      String formatName, Type refClass);

  // Returns all manufacturers in this context.
  List<ReferenceManufacturer<dynamic>> getAllManufacturers();

  // Returns true if a manufacturer already exists for the given identity.
  bool hasManufacturer<T extends Loadable>(ClassIdentity<T> cl);

  // Constructs (or returns) a ReferenceManufacturer for the given identity.
  ReferenceManufacturer<T> constructReferenceManufacturer<T extends Loadable>(
      ClassIdentity<T> identity);

  // Validate all references after loading.
  bool validate(UnconstructedValidator validator) {
    bool valid = true;
    for (final rm in getAllManufacturers()) {
      if (!rm.validate(validator)) valid = false;
    }
    return valid;
  }

  // Copy an object under a new name and import it.
  T? performCopy<T extends CDOMObject>(T object, String copyName);

  // Mod an object (returns the same object in the runtime context).
  T performMod<T extends CDOMObject>(T obj);

  // Register an already-constructed object.
  void importObject<T extends Loadable>(T obj) {
    // stub
  }

  // Remove an object by its abbreviation; returns true if removed.
  bool forgetLoadable<T extends Loadable>(T obj) {
    return false; // stub
  }

  // Returns the current source URI.
  String? getSourceURI() => null; // stub
}

class RuntimeReferenceContext extends AbstractReferenceContext {
  final Map<ClassIdentity<dynamic>, ReferenceManufacturer<dynamic>> _map = {};

  // Case-insensitive lookup of ClassIdentity by persistent format string
  final CaseInsensitiveMap<ClassIdentity<dynamic>> _nameMap =
      CaseInsensitiveMap();

  RuntimeReferenceContext();

  @override
  void initialize() {
    super.initialize();
    // stub: StringPClassUtil.getBaseClasses().forEach(importCDOMToFormat)
  }

  @override
  ReferenceManufacturer<T> getManufacturer<T extends Loadable>(Type cl) {
    // stub: Categorized check omitted (type system differs in Dart)
    final identity = BasicClassIdentity.getIdentity<T>(cl);
    return getManufacturerId<T>(identity);
  }

  @override
  ReferenceManufacturer<T> getManufacturerId<T extends Loadable>(
      ClassIdentity<T> identity) {
    var mfg = _map[identity] as ReferenceManufacturer<T>?;
    if (mfg == null) {
      mfg = constructReferenceManufacturer<T>(identity);
      _map[identity] = mfg;
      _nameMap[identity.getPersistentFormat()] = identity;
    }
    return mfg;
  }

  @override
  ReferenceManufacturer<T> constructReferenceManufacturer<T extends Loadable>(
      ClassIdentity<T> identity) {
    if (identity is ManufacturableFactory<T>) {
      return SimpleReferenceManufacturer<T>(identity);
    }
    return SimpleReferenceManufacturer<T>(CDOMFactory<T>(identity));
  }

  @override
  List<ReferenceManufacturer<dynamic>> getAllManufacturers() {
    final list = List<ReferenceManufacturer<dynamic>>.from(_map.values);
    // Sort: non-categorized items first (stub: full Categorized sort omitted)
    return list;
  }

  @override
  ReferenceManufacturer<T> getManufacturerFac<T extends Loadable>(
      ManufacturableFactory<T> factory) {
    final identity = factory.getReferenceIdentity();
    var rm = _map[identity] as ReferenceManufacturer<T>?;
    if (rm == null) {
      rm = SimpleReferenceManufacturer<T>(factory);
      _map[identity] = rm;
      _nameMap[identity.getPersistentFormat()] = identity;
    }
    return rm;
  }

  /// Perform a .COPY operation: clone the object, rename it, and import it.
  @override
  T? performCopy<T extends CDOMObject>(T object, String copyName) {
    // stub: deep clone not available in Dart; requires object.clone() equivalent
    throw UnimplementedError(
        'performCopy requires a clone() method on CDOMObject'); // stub
  }

  @override
  T performMod<T extends CDOMObject>(T obj) => obj;

  @override
  bool hasManufacturer<T extends Loadable>(ClassIdentity<T> cl) =>
      _map.containsKey(cl);

  /// Return a new RuntimeReferenceContext initialised as per AbstractReferenceContext.
  static RuntimeReferenceContext createRuntimeReferenceContext() {
    final context = RuntimeReferenceContext();
    context.initialize();
    return context;
  }

  @override
  ReferenceManufacturer<T>? getManufacturerByFormatName<T extends Loadable>(
      String formatName, Type refClass) {
    final identity = _nameMap[formatName];
    if (identity == null) {
      // Post-hoc lookup: cannot resolve before manufacturer has been created
      return null;
    }
    return _map[identity] as ReferenceManufacturer<T>?;
  }
}
