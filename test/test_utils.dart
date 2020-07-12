import 'package:ffigen/src/code_generator.dart';

/// Extracts a binding's string from a library.

extension LibraryTestExt on Library {
  /// Get a [Binding]'s generated string with a given name.
  String getBindingAsString(String name) {
    final b = bindings.firstWhere((element) => element.name == name,
        orElse: () => null);
    if (b == null) {
      throw NotFoundException("Binding '$name' not found.");
    } else {
      return b.toBindingString(writer).string;
    }
  }

  /// Get a [Binding] with a given name.
  Binding getBinding(String name) {
    final b = bindings.firstWhere((element) => element.name == name,
        orElse: () => null);
    if (b == null) {
      throw NotFoundException("Binding '$name' not found.");
    } else {
      return b;
    }
  }
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() {
    return message;
  }
}
