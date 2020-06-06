import 'package:meta/meta.dart';

/// A Binding's String representation
class BindingString {
  // meta data, not used for generation
  final BindingStringType type;
  final String string;

  const BindingString({@required this.type, @required this.string});

  @override
  String toString() => string;
}

/// A type of BindingString
enum BindingStringType {
  func,
  struc,
  constant,
  global,
  enumClass,
  typeDef,
}
