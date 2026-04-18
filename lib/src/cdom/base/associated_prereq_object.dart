import 'associated_object.dart';
import 'prereq_object.dart';
import 'qualifying_object.dart';

// Combines AssociatedObject, PrereqObject, and QualifyingObject interfaces.
abstract interface class AssociatedPrereqObject
    implements AssociatedObject, PrereqObject, QualifyingObject {}
