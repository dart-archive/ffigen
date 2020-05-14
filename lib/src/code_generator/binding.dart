import 'package:meta/meta.dart';

import 'writer.dart';
import 'binding_string.dart';

/// A binding class, parent class of all possible types
abstract class Binding {
  /// Name of element
  final String name;

  /// DartDoc for this (Optional)
  final String dartDoc;

  const Binding({@required this.name, this.dartDoc});

  /// Converts an abstract Binding to its string representation
  BindingString toBindingString(Writer w);
}
