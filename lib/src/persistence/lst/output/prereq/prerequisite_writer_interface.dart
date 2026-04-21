// Copyright 2004 Frugal <frugal@purplewombat.co.uk>
//
// Translation of pcgen.persistence.lst.output.prereq.PrerequisiteWriterInterface

import 'package:flutter_pcgen/src/core/prereq/prerequisite.dart';
import 'package:flutter_pcgen/src/core/prereq/prerequisite_operator.dart';

/// Interface for classes that serialize a Prerequisite back to LST string format.
abstract interface class PrerequisiteWriterInterface {
  String kindHandled();
  List<PrerequisiteOperator> operatorsHandled();
  void write(StringSink writer, Prerequisite prereq);
}
