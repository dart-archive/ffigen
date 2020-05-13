import 'binding_string.dart';

/// To store generated String bindings.
class Writer {
  String header;
  String dylibIdentifier;
  String initFunctionIdentifier;

  static const _p1 = 'ffi';
  static const _p2 = 'ffi2';
  final List<BindingString> _bindings = [];

  Writer({String dylibIdentifier, String initFunctionIdentifier}) {
    dylibIdentifier = this.dylibIdentifier ?? '_dylib';
    initFunctionIdentifier = initFunctionIdentifier ?? 'init';
  }

  @override
  String toString() {
    final s = StringBuffer();

    // Write header (if any)
    if (header != null) {
      s.write(header);
      s.write('\n');
    }

    // write neccesary imports
    s.write("import 'dart:ffi' as $_p1;\n");
    s.write("import 'package:ffi/ffi.dart' as $_p2;\n");
    s.write('\n');

    // Write dylib
    s.write('/// Dynamic library\n');
    s.write('$_p1.DynamicLibrary ${dylibIdentifier};\n');
    s.write('\n');
    s.write('/// Initialises dynamic library\n');
    s.write('void $initFunctionIdentifier($_p1.DynamicLibrary dylib){\n');
    s.write('  ${dylibIdentifier}=library;\n');
    s.write('}\n');
    s.write('\n');

    // Write bindings
    for (var bs in _bindings) {
      s.write('\n');
      s.write(bs);
    }

    s.write('\n');
    return s.toString();
  }

  void addBindingString(BindingString b) {
    _bindings.add(b);
  }
}
