// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:wasmjsgen/src/code_generator/utils.dart';

import 'binding.dart';
import 'type.dart';

/// To store generated String bindings.
class Writer {
  final String? header;

  /// Holds bindings, which lookup symbols.
  final List<Binding> lookUpBindings;

  /// Holds bindings which don't lookup symbols.
  final List<Binding> noLookUpBindings;

  /// Manages the `_SymbolAddress` class.
  final symbolAddressWriter = SymbolAddressWriter();

  late String _className;
  final String? classDocComment;

  late String _lookupFuncIdentifier;
  String get lookupFuncIdentifier => _lookupFuncIdentifier;

  late String _symbolAddressClassName;
  late String _symbolAddressVariableName;
  late String _symbolAddressLibraryVarName;

  final bool dartBool;
  final String? allocate;
  final String? deallocate;
  final String? reallocate;

  /// Initial namers set after running constructor. Namers are reset to this
  /// initial state everytime [generate] is called.
  late UniqueNamer _initialTopLevelUniqueNamer, _initialWrapperLevelUniqueNamer;

  /// Used by [Binding]s for generating required code.
  late UniqueNamer _topLevelUniqueNamer, _wrapperLevelUniqueNamer;
  UniqueNamer get topLevelUniqueNamer => _topLevelUniqueNamer;
  UniqueNamer get wrapperLevelUniqueNamer => _wrapperLevelUniqueNamer;

  late String _arrayHelperClassPrefix;

  /// Guaranteed to be a unique prefix.
  String get arrayHelperClassPrefix => _arrayHelperClassPrefix;

  // -----------------
  // Wasm Specific
  // -----------------
  // imports
  late String _dartAsync;
  late String _dartConvert;
  late String _dartTyped;
  late String _wasmInterop;

  late String _wasmInstance;
  late String _opaqueClass;
  late String _jsBigIntToInt;
  late String _jsBigInt;
  late String _toDartString;

  String get jsBigIntToInt => _jsBigIntToInt;
  String get jsBigInt => _jsBigInt;

  String get className => _className;

  /// [_usedUpNames] should contain names of all the declarations which are
  /// already used. This is used to avoid name collisions.
  Writer({
    required this.lookUpBindings,
    required this.noLookUpBindings,
    required String className,
    required this.dartBool,
    this.allocate,
    this.deallocate,
    this.reallocate,
    this.classDocComment,
    this.header,
  }) {
    final globalLevelNameSet = noLookUpBindings.map((e) => e.name).toSet();
    final wrapperLevelNameSet = lookUpBindings.map((e) => e.name).toSet();
    final allNameSet = <String>{}
      ..addAll(globalLevelNameSet)
      ..addAll(wrapperLevelNameSet);

    _initialTopLevelUniqueNamer = UniqueNamer(globalLevelNameSet);
    _initialWrapperLevelUniqueNamer = UniqueNamer(wrapperLevelNameSet);
    final allLevelsUniqueNamer = UniqueNamer(allNameSet);

    /// Wrapper class name must be unique among all names.
    _className = _resolveNameConflict(
      name: className,
      makeUnique: allLevelsUniqueNamer,
      markUsed: [_initialWrapperLevelUniqueNamer, _initialTopLevelUniqueNamer],
    );

    /// [_lookupFuncIdentifier] should be unique in top level.
    _lookupFuncIdentifier = _resolveNameConflict(
      name: 'lookup',
      makeUnique: _initialTopLevelUniqueNamer,
      markUsed: [_initialTopLevelUniqueNamer],
    );

    /// Resolve name conflicts of identifiers used for SymbolAddresses.
    _symbolAddressClassName = _resolveNameConflict(
      name: '_SymbolAddresses',
      makeUnique: allLevelsUniqueNamer,
      markUsed: [_initialWrapperLevelUniqueNamer, _initialTopLevelUniqueNamer],
    );
    _symbolAddressVariableName = _resolveNameConflict(
      name: 'addresses',
      makeUnique: _initialWrapperLevelUniqueNamer,
      markUsed: [_initialWrapperLevelUniqueNamer],
    );
    _symbolAddressLibraryVarName = _resolveNameConflict(
      name: '_library',
      makeUnique: _initialWrapperLevelUniqueNamer,
      markUsed: [_initialWrapperLevelUniqueNamer],
    );

    // -----------------
    // Wasm Specific
    // -----------------
    // imports
    _dartAsync = _resolveNameConflict(
      name: 'dart_async',
      makeUnique: _initialTopLevelUniqueNamer,
      markUsed: [_initialTopLevelUniqueNamer],
    );
    _dartConvert = _resolveNameConflict(
      name: 'dart_convert',
      makeUnique: _initialTopLevelUniqueNamer,
      markUsed: [_initialTopLevelUniqueNamer],
    );
    _dartTyped = _resolveNameConflict(
      name: 'dart_typed',
      makeUnique: _initialTopLevelUniqueNamer,
      markUsed: [_initialTopLevelUniqueNamer],
    );
    _wasmInterop = _resolveNameConflict(
      name: 'wasm_interop',
      makeUnique: _initialTopLevelUniqueNamer,
      markUsed: [_initialTopLevelUniqueNamer],
    );

    _wasmInstance = _resolveNameConflict(
      name: '_wasmInstance',
      makeUnique: _initialTopLevelUniqueNamer,
      markUsed: [_initialTopLevelUniqueNamer],
    );
    _opaqueClass = _resolveNameConflict(
      name: 'Opaque',
      makeUnique: _initialTopLevelUniqueNamer,
      markUsed: [_initialTopLevelUniqueNamer],
    );
    _jsBigInt = _resolveNameConflict(
      name: 'JsBigInt',
      makeUnique: _initialTopLevelUniqueNamer,
      markUsed: [_initialTopLevelUniqueNamer],
    );
    _jsBigIntToInt = _resolveNameConflict(
      name: 'jsBigIntToInt',
      makeUnique: _initialTopLevelUniqueNamer,
      markUsed: [_initialTopLevelUniqueNamer],
    );
    _toDartString = _resolveNameConflict(
      name: 'toDartString',
      makeUnique: _initialTopLevelUniqueNamer,
      markUsed: [_initialTopLevelUniqueNamer],
    );

    /// Finding a unique prefix for Array Helper Classes and store into
    /// [_arrayHelperClassPrefix].
    final base = 'ArrayHelper';
    _arrayHelperClassPrefix = base;
    var suffixInt = 0;
    for (var i = 0; i < allNameSet.length; i++) {
      if (allNameSet.elementAt(i).startsWith(_arrayHelperClassPrefix)) {
        // Not a unique prefix, start over with a new suffix.
        i = -1;
        suffixInt++;
        _arrayHelperClassPrefix = '$base$suffixInt';
      }
    }

    _resetUniqueNamersNamers();
  }

  /// Resolved name conflict using [makeUnique] and marks the result as used in
  /// all [markUsed].
  String _resolveNameConflict({
    required String name,
    required UniqueNamer makeUnique,
    List<UniqueNamer> markUsed = const [],
  }) {
    final s = makeUnique.makeUnique(name);
    for (final un in markUsed) {
      un.markUsed(s);
    }
    return s;
  }

  /// Resets the namers to initial state. Namers are reset before generating.
  void _resetUniqueNamersNamers() {
    _topLevelUniqueNamer = _initialTopLevelUniqueNamer.clone();
    _wrapperLevelUniqueNamer = _initialWrapperLevelUniqueNamer.clone();
  }

  /// Writes all bindings to a String.
  String generate() {
    final s = StringBuffer();

    // Reset unique namers to initial state.
    _resetUniqueNamersNamers();

    // Supress code style warnings for generated code
    s.writeln(
        '// ignore_for_file: non_constant_identifier_names, unused_import, camel_case_types\n');

    // Write file header (if any).
    if (header != null) {
      s.write(header);
      s.write('\n');
    }

    // Write auto generated declaration.
    s.writeln(makeDoc(
        'AUTO GENERATED FILE, DO NOT EDIT.\n\nGenerated by `package:wasmjsgen`.'));

    // Imports
    s.write("import 'dart:async' as $_dartAsync;\n");
    s.write("import 'dart:convert' as $_dartConvert;\n");
    s.write("import 'dart:typed_data' as $_dartTyped;\n");
    s.write(
        "import 'package:wasm_interop/wasm_interop.dart' as $_wasmInterop;\n");

    if (classDocComment != null) {
      s.write(makeDartDoc(classDocComment!));
    }

    // Write Library wrapper class
    s.write('class $className{\n');
    s.write('/// The symbol lookup function.\n');

    // Write lookup function
    s.write('T $lookupFuncIdentifier<T>(String name) {\n');
    s.write('  return $_wasmInstance.functions[name] as T;\n');
    s.write('}\n');

    // Memory Getters
    s.writeln('$_wasmInterop.Memory get memory {');
    s.writeln("  return _wasmInstance.memories['memory']!;");
    s.writeln('}');
    s.writeln('$_dartTyped.Uint8List get memView {');
    s.writeln(
        "  return $_wasmInstance.memories['memory']!.buffer.asUint8List();");
    s.writeln('}');

    s.writeln('int get memBytes => memory.lengthInBytes;');
    s.writeln('int get memPages => memory.lengthInPages;');
    s.writeln('int get memPageSize => (memBytes / memPages).floor();');
    s.writeln('int get memElemByteSize => memView.elementSizeInBytes;');

    // Instance field and constructor
    s.writeln('\nfinal $_wasmInterop.Instance $_wasmInstance;');
    s.writeln('$className(this._wasmInstance);\n');

    // Function declarations
    if (lookUpBindings.isNotEmpty) {
      for (final b in lookUpBindings) {
        s.writeln('\n  // --- ${b.name} ---');
        s.write(b.toBindingString(this).string);
      }
    }

    // toString override
    s.writeln('  @override');
    s.writeln('  String toString() {');
    s.writeln(
        "    final functions = _wasmInstance.functions.keys.map((x) => '\\n     \$x');");
    s.writeln('    final elemSize = memElemByteSize;');
    s.writeln('    int bytesUsed = 0;');
    s.writeln('    for (int i = 0; i < memView.length; i += elemSize) {');
    s.writeln('      if (memView[i] != 0) bytesUsed++;');
    s.writeln('    }');
    s.writeln("    return '''Wasm NativeLibrary {");
    s.writeln('  Memory {');
    s.writeln('    Page Size:        \$memPageSize');
    s.writeln('    Elem Byte Size:   \$elemSize');
    s.writeln('    Pages:            \$memPages');
    s.writeln('    Bytes Total:      \$memBytes');
    s.writeln('    Bytes Used:       \$bytesUsed');
    s.writeln('  }');
    s.writeln('  functions: \$functions');
    s.writeln('  functionCount: \${functions.length}');
    s.writeln('}');
    s.writeln("''';");
    s.writeln('  }');

    // Static Initializers
    s.write('\n');
    s.write('static $className? _instance;\n');
    s.write('static $className get instance {\n');
    s.write('  assert(_instance != null,\n');
    s.write('      "need to $className.init() before accessing instance");\n');
    s.write('  return _instance!;\n');
    s.write('}\n');
    s.write('\n');
    s.write(
        'static Future<$className> init($_dartTyped.Uint8List moduleData) async {\n');
    s.write(
        '  final $_wasmInterop.Instance instance = await $_wasmInterop.Instance.fromBytesAsync(moduleData);\n');
    s.write('  _instance = $className(instance);\n');
    s.write('  return $className.instance;\n');
    s.write('}\n');

    s.write('}\n\n');

    /// Write [noLookUpBindings].
    for (final b in noLookUpBindings) {
      s.write(b.toBindingString(this).string);
    }

    writePointerAndOpaque(s);
    writeBuiltInNatives(s);
    writeJsBigIntConverter(s);
    writeStringConverter(s);

    writeMemoryAlloc(s);
    writeMemoryDealloc(s);
    writeMemoryRealloc(s);

    if (symbolAddressWriter.shouldGenerate) {
      s.write(symbolAddressWriter.writeClass(this));
    }

    return s.toString();
  }

  void writePointerAndOpaque(StringBuffer s) {
    s.writeln('// Base for Native Types and Opaque Structs');
    s.writeln('class $_opaqueClass {');
    s.writeln('  final int _address;');
    s.writeln('  int get address => _address;');
    s.writeln('  $_opaqueClass(this._address);');
    s.writeln('}\n');

    s.writeln('// FFI Pointer Replacement');
    s.writeln('class Pointer<T extends $_opaqueClass> {');
    s.writeln('  final T _opaque;');
    s.writeln('  Pointer._(this._opaque);');
    s.writeln('  late final int? size;');
    s.writeln('  factory Pointer.fromAddress(T opaque) {');
    s.writeln('    return Pointer._(opaque);');
    s.writeln('  }');
    s.writeln('  int get address => _opaque.address;');
    s.writeln('  bool get isSized => size != null;');
    s.writeln('}');
  }

  void writeBuiltInNatives(StringBuffer s) {
    s.writeln('// Dart FFI Native Types');

    final uniquePrims = Type.primitives.values.map((x) => x.c).toSet();
    for (final prim in uniquePrims) {
      s.writeln('class $prim extends $_opaqueClass {');
      s.writeln('  $prim(int address): super(address);');
      s.writeln('}');
    }
  }

  void writeJsBigIntConverter(StringBuffer s) {
    // Alternative built into wasm_interop which converts to BigInt (more correct, but also more complex to use)
    // https://github.com/lexaknyazev/wasm.dart/blob/85529abdd32c0d30444db91dc884e34085473615/wasm_interop/lib/wasm_interop.dart#L455
    s.writeln('// --- JsBigInt and conversion ---');
    s.writeln('typedef $_jsBigInt = String;\n');
    s.writeln('// Only reliable way I found to convert JS BigInt to int.');
    s.writeln('// It is used to convert uint64_t and int64_t.');
    s.writeln(
        '// Dart int is 64bit (signed). A u64 will not fit if it is larger than max i64.');
    s.writeln('// However in most scenarios we will not hit this max value.');
    s.writeln('//   Max u64 is 18,446,744,073,709,551,615');
    s.writeln('//   Max i64 is  9,223,372,036,854,775,807');
    s.writeln(
        '// Thus we take a shortcut to avoid having to deal with Dart BigInt.');
    s.writeln('int $_jsBigIntToInt($_jsBigInt n) {');
    s.writeln('  return int.parse(n);');
    s.writeln('}');
  }

  void writeStringConverter(StringBuffer s) {
    s.writeln('// --- Pointer<Int8> to Dart String conversion ---');
    s.writeln(
        'const $_dartConvert.Utf8Codec utf8Codec = $_dartConvert.Utf8Codec();');

    s.writeln('String $_toDartString(Pointer<Int8> ptr) {');
    s.writeln(
        '  return _decodeUtf8ListString($className.instance.memView, ptr.address);');
    s.writeln('}\n');
    s.writeln(
        'String _decodeUtf8ListString($_dartTyped.Uint8List codeUnits, int address) {');
    s.writeln('  final end = _end(codeUnits, address);');
    s.writeln('  return utf8Codec.decode(codeUnits.sublist(address, end));');
    s.writeln('}\n');
    s.writeln('int _end($_dartTyped.Uint8List codeUnits, int start) {');
    s.writeln('  int end = start;');
    s.writeln('  while (codeUnits[end] != 0) {');
    s.writeln('    end++;');
    s.writeln('  }');
    s.writeln('  return end;');
    s.writeln('}');
  }

  void writeMemoryAlloc(StringBuffer s) {
    if (allocate == null) return;

    // Note: type c_char = i8;
    // https://doc.rust-lang.org/std/os/raw/type.c_char.html
    // While std:alloc::alloc returns u8
    // https://doc.rust-lang.org/stable/std/alloc/fn.alloc.html

    s.writeln('// Allocate');
    s.writeln('typedef MallocUint8 = Pointer<Uint8> Function(int);');

    s.writeln('Pointer<Uint8> toUint8Pointer(String s, MallocUint8 malloc) {');
    s.writeln('  final encoded = utf8Codec.encode(s);');
    s.writeln('');

    s.writeln('  final size = encoded.length + 1;');
    s.writeln('  final Pointer<Uint8> ptr = malloc(size);');
    s.writeln('  ptr.size = size;');
    s.writeln('  final list = dart_typed.Uint8List.fromList(encoded);');
    s.writeln('');
    s.writeln('  final start = ptr.address;');
    s.writeln('  final end = ptr.address + list.length;');
    s.writeln('  NativeLibrary.instance.memView.setRange(start, end, list);');
    s.writeln('  NativeLibrary.instance.memView.fillRange(end, end + 1, 0);');
    s.writeln('');
    s.writeln('  return ptr;');
    s.writeln('}');
    s.writeln('');

    s.writeln('extension ToNativeInt8Extension on String {');
    s.writeln('  Pointer<Int8> toNativeInt8() {');
    s.writeln(
        '    final ptr = toUint8Pointer(this, NativeLibrary.instance.$allocate);');
    s.writeln('    return Pointer.fromAddress(Int8(ptr.address));');
    s.writeln('  }');
    s.writeln('}');
  }

  void writeMemoryDealloc(StringBuffer s) {
    if (deallocate == null) return;
    s.writeln('// Deallocate');
    s.writeln(
        'typedef DeallocUint8 = void Function(Pointer<Uint8> ptr, int size);');
    s.writeln('void _deallocUint8(Pointer<Uint8> ptr, DeallocUint8 dealloc) {');

    s.writeln("assert(ptr.isSized, 'Can only deallocate sized pointers');");
    s.writeln('  dealloc(ptr, ptr.size!);');
    s.writeln('}');
    s.writeln('');

    s.writeln('extension DeallocPointerUInt8Extension on Pointer<Uint8> {');
    s.writeln('  void dealloc(Pointer<Uint8> ptr) {');
    s.writeln('    _deallocUint8(this, NativeLibrary.instance.$deallocate);');
    s.writeln('  }');
    s.writeln('}');
  }

  void writeMemoryRealloc(StringBuffer s) {
    if (reallocate == null) return;
    s.writeln('// Reallocate');
    s.writeln('typedef ReallocUint8 = Pointer<Uint8> Function(');
    s.writeln('  Pointer<Uint8> ptr,');
    s.writeln('  int oldSize,');
    s.writeln('  int newSize,');
    s.writeln(');');

    s.writeln(
        'void _reallocUint8(Pointer<Uint8> ptr, int newSize, ReallocUint8 realloc) {');
    s.writeln("  assert(ptr.isSized, 'Can only reallocate sized pointers');");
    s.writeln('  realloc(ptr, ptr.size!, newSize);');
    s.writeln('}');

    s.writeln('extension ReallocPointerUInt8Extension on Pointer<Uint8> {');
    s.writeln('  void realloc(Pointer<Uint8> ptr, int newSize) {');
    s.writeln(
        '    _reallocUint8(this, newSize, NativeLibrary.instance.$reallocate);');
    s.writeln('  }');
    s.writeln('}');
  }
}

/// Manages the generated `_SymbolAddress` class.
class SymbolAddressWriter {
  final List<_SymbolAddressUnit> _addresses = [];

  /// Used to check if we need to generate `_SymbolAddress` class.
  bool get shouldGenerate => _addresses.isNotEmpty;

  void addSymbol({
    required String type,
    required String name,
    required String ptrName,
  }) {
    _addresses.add(_SymbolAddressUnit(type, name, ptrName));
  }

  String writeObject(Writer w) {
    return 'late final ${w._symbolAddressVariableName} = ${w._symbolAddressClassName}(this);';
  }

  String writeClass(Writer w) {
    final sb = StringBuffer();
    sb.write('class ${w._symbolAddressClassName} {\n');
    // Write Library object.
    sb.write('final ${w._className} ${w._symbolAddressLibraryVarName};\n');
    // Write Constructor.
    sb.write(
        '${w._symbolAddressClassName}(this.${w._symbolAddressLibraryVarName});\n');
    for (final address in _addresses) {
      sb.write(
          '${address.type} get ${address.name} => ${w._symbolAddressLibraryVarName}.${address.ptrName};\n');
    }
    sb.write('}\n');
    return sb.toString();
  }
}

/// Holds the data for a single symbol address.
class _SymbolAddressUnit {
  final String type, name, ptrName;

  _SymbolAddressUnit(this.type, this.name, this.ptrName);
}
