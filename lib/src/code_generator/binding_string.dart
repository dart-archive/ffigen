import 'package:meta/meta.dart';

/// A Binding's String representation
class BindingString {
  BindingStringType type;

  BindingString({@required this.type});
}

/// A type of BindingString
enum BindingStringType {
  func,
  struct,
  constant,
  defType,
}
