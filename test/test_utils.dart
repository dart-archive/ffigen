import 'package:ffigen/src/code_generator.dart';

/// Extracts a binding's string from a library.

extension LibraryTestExt on Library {
  /// Get a [Binding]'s generated string with a given name.
  String getBinding(String name) {
    final b = bindings.firstWhere((element) => element.name == name,
        orElse: () => null);
    if (b == null) {
      throw Exception("Binding '$name' not found.");
    } else {
      return b.toBindingString(writer).string;
    }
  }
}
