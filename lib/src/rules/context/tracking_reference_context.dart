import '../../base/util/double_key_map_to_list.dart';
import '../../cdom/base/cdom_reference.dart';
import '../../cdom/base/loadable.dart';
import '../../cdom/reference/manufacturable_factory.dart';
import '../../cdom/reference/reference_manufacturer.dart';
import '../../cdom/reference/unconstructed_event.dart';
import '../../cdom/reference/unconstructed_listener.dart';
import 'runtime_reference_context.dart';
import 'tracking_manufacturer.dart';

class TrackingReferenceContext extends RuntimeReferenceContext
    implements UnconstructedListener {
  // Weak-keyed map in Java; Dart has no built-in WeakHashMap, use regular map.
  // Key: CDOMReference, secondary key: URI (String), value list: token class names
  final DoubleKeyMapToList<CDOMReference<dynamic>, String, String> _track =
      DoubleKeyMapToList();

  final Set<ReferenceManufacturer<dynamic>> _listening = {};

  String? _sourceURI;

  TrackingReferenceContext._();

  @override
  ReferenceManufacturer<T> getManufacturer<T extends Loadable>(Type cl) {
    final mfg = super.getManufacturer<T>(cl);
    if (mfg is TrackingManufacturer<T>) {
      return mfg;
    }
    if (!_listening.contains(mfg)) {
      mfg.addUnconstructedListener(this);
      _listening.add(mfg);
    }
    return TrackingManufacturer<T>(this, mfg);
  }

  @override
  ReferenceManufacturer<T> getManufacturerFac<T extends Loadable>(
      ManufacturableFactory<T> factory) {
    final mfg = super.getManufacturerFac<T>(factory);
    if (mfg is TrackingManufacturer<T>) {
      return mfg;
    }
    if (!_listening.contains(mfg)) {
      mfg.addUnconstructedListener(this);
      _listening.add(mfg);
    }
    return TrackingManufacturer<T>(this, mfg);
  }

  @override
  void unconstructedReferenceFound(UnconstructedEvent e) {
    final ref = e.getReference();
    final uris = _track.getSecondaryKeySet(ref);
    // getSecondaryKeySet returns an empty set when absent; treat empty as absent
    if (uris.isEmpty) {
      // Shouldn't happen, but this is reporting, not critical, so be safe
      return;
    }
    for (final uri in uris) {
      final tokens = _track.getListFor(ref, uri);
      final tokenNames = <String>{};
      if (tokens != null) {
        for (final tok in tokens) {
          tokenNames.add(tok);
        }
      }
      // stub: Logging.errorPrint equivalent
      print('  Was used in $uri in tokens: $tokenNames');
    }
  }

  /// Walks the current call stack looking for a frame whose class name
  /// starts with "plugin.lsttokens".  In Dart there is no portable stack
  /// introspection, so we always return null and callers use "?" as the
  /// source label.
  String? _getSource() {
    // stub: Java uses Thread.currentThread().getStackTrace(); not available in Dart
    return null;
  }

  void trackReference(CDOMReference<dynamic> ref) {
    final src = _getSource() ?? '?';
    _track.addToListFor(ref, _sourceURI ?? '', src);
  }

  /// Expose source URI so trackReference can use it.
  void setTrackingSourceURI(String? uri) {
    _sourceURI = uri;
  }

  /// Return a new TrackingReferenceContext initialised as per AbstractReferenceContext.
  static TrackingReferenceContext createTrackingReferenceContext() {
    final context = TrackingReferenceContext._();
    context.initialize();
    return context;
  }
}
