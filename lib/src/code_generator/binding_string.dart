import 'package:meta/meta.dart';

/// A Binding's String representation
class BindingString {
  final BindingStringType type;
  final String string;

  const BindingString({@required this.type, @required this.string});

  @override
  String toString() => string;
}

/// A type of BindingString
enum BindingStringType {
  func,
  struct,
  constant,
  defType,
}
