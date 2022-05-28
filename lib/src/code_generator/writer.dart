// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/imports.dart';
import 'package:ffigen/src/code_generator/utils.dart';

import 'binding.dart';

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
  String get className => _className;

  final String? classDocComment;

  String? _ffiLibraryPrefix;
  String get ffiLibraryPrefix {
    if (_ffiLibraryPrefix != null) {
      return _ffiLibraryPrefix!;
    }

    final import = _usedImports.firstWhere(
        (element) => element.name == ffiImport.name,
        orElse: () => ffiImport);
    _usedImports.add(import);
    return _ffiLibraryPrefix = import.prefix;
  }

  String? _ffiPkgLibraryPrefix;
  String get ffiPkgLibraryPrefix {
    if (_ffiPkgLibraryPrefix != null) {
      return _ffiPkgLibraryPrefix!;
    }

    final import = _usedImports.firstWhere(
        (element) => element.name == ffiPkgImport.name,
        orElse: () => ffiPkgImport);
    _usedImports.add(import);
    return _ffiPkgLibraryPrefix = import.prefix;
  }

  final Set<LibraryImport> _usedImports = {};

  late String _lookupFuncIdentifier;
  String get lookupFuncIdentifier => _lookupFuncIdentifier;

  late String _symbolAddressClassName;
  late String _symbolAddressVariableName;
  late String _symbolAddressLibraryVarName;

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

  /// [_usedUpNames] should contain names of all the declarations which are
  /// already used. This is used to avoid name collisions.
  Writer({
    required this.lookUpBindings,
    required this.noLookUpBindings,
    required String className,
    Set<LibraryImport>? additionalImports,
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

    /// Library imports prefix should be unique unique among all names.
    if (additionalImports != null) {
      for (final lib in additionalImports) {
        lib.prefix = _resolveNameConflict(
          name: lib.prefix,
          makeUnique: allLevelsUniqueNamer,
          markUsed: [
            _initialWrapperLevelUniqueNamer,
            _initialTopLevelUniqueNamer
          ],
        );
      }
    }

    /// [_lookupFuncIdentifier] should be unique in top level.
    _lookupFuncIdentifier = _resolveNameConflict(
      name: '_lookup',
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

  void markImportUsed(LibraryImport import) {
    _usedImports.add(import);
  }

  /// Writes all bindings to a String.
  String generate() {
    final s = StringBuffer();

    // We write the source first to determine which imports are actually
    // referenced. Headers and [s] are then combined into the final result.
    final result = StringBuffer();

    // Reset unique namers to initial state.
    _resetUniqueNamersNamers();

    // Write file header (if any).
    if (header != null) {
      result.writeln(header);
    }

    // Write auto generated declaration.
    result.write(makeDoc(
        'AUTO GENERATED FILE, DO NOT EDIT.\n\nGenerated by `package:ffigen`.'));

    /// Write [lookUpBindings].
    if (lookUpBindings.isNotEmpty) {
      // Write doc comment for wrapper class.
      if (classDocComment != null) {
        s.write(makeDartDoc(classDocComment!));
      }
      // Write wrapper classs.
      s.write('class $_className{\n');
      // Write dylib.
      s.write('/// Holds the symbol lookup function.\n');
      s.write(
          'final $ffiLibraryPrefix.Pointer<T> Function<T extends $ffiLibraryPrefix.NativeType>(String symbolName) $lookupFuncIdentifier;\n');
      s.write('\n');
      //Write doc comment for wrapper class constructor.
      s.write(makeDartDoc('The symbols are looked up in [dynamicLibrary].'));
      // Write wrapper class constructor.
      s.write(
          '$_className($ffiLibraryPrefix.DynamicLibrary dynamicLibrary): $lookupFuncIdentifier = dynamicLibrary.lookup;\n\n');
      //Write doc comment for wrapper class named constructor.
      s.write(makeDartDoc('The symbols are looked up with [lookup].'));
      // Write wrapper class named constructor.
      s.write(
          '$_className.fromLookup($ffiLibraryPrefix.Pointer<T> Function<T extends $ffiLibraryPrefix.NativeType>(String symbolName) lookup): $lookupFuncIdentifier = lookup;\n\n');
      for (final b in lookUpBindings) {
        s.write(b.toBindingString(this).string);
      }
      if (symbolAddressWriter.shouldGenerate) {
        s.write(symbolAddressWriter.writeObject(this));
      }

      s.write('}\n\n');
    }

    if (symbolAddressWriter.shouldGenerate) {
      s.write(symbolAddressWriter.writeClass(this));
    }

    /// Write [noLookUpBindings].
    for (final b in noLookUpBindings) {
      s.write(b.toBindingString(this).string);
    }

    // Write neccesary imports.
    for (final lib in _usedImports) {
      result
        ..write("import '${lib.importPath}' as ${lib.prefix};")
        ..write('\n');
    }
    result.write(s);

    return result.toString();
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
