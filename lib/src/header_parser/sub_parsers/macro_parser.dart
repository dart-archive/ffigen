// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:ffigen/src/header_parser/includer.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../utils.dart';

var _logger = Logger('ffigen.header_parser.macro_parser');

/// Adds a macro definition to be parsed later.
void saveMacroDefinition(Pointer<clang_types.CXCursor> cursor) {
  final originalMacroName = cursor.spelling();
  if (shouldIncludeMacro(originalMacroName) &&
      !bindingsIndex.isSeenMacro(originalMacroName) &&
      clang.clang_Cursor_isMacroBuiltin_wrap(cursor) == 0 &&
      clang.clang_Cursor_isMacroFunctionLike_wrap(cursor) == 0) {
    // Parse macro only if it's not builtin or function-like.
    _logger.fine(
        "++++ Saved Macro '$originalMacroName' for later : ${cursor.completeStringRepr()}");
    final prefixedName = config.macroDecl.renameUsingConfig(originalMacroName);
    bindingsIndex.addMacroToSeen(originalMacroName, prefixedName);
    _saveMacro(prefixedName, originalMacroName);
  }
}

/// Saves a macro to be parsed later.
///
/// Macros are parsed later in [parseSavedMacros()].
void _saveMacro(String name, String originalName) {
  savedMacros[name] = originalName;
}

List<Constant> _bindings;

/// Macros cannot be parsed directly, so we create a new `.hpp` file in which
/// they are assigned to a variable after which their value can be determined
/// by evaluating the value of the variable.
List<Constant> parseSavedMacros() {
  _bindings = [];

  if (savedMacros.keys.isEmpty) {
    return _bindings;
  }

  // Create a file for parsing macros;
  final file = createFileForMacros();

  final index = clang.clang_createIndex(0, 0);
  Pointer<Pointer<Utf8>> clangCmdArgs = nullptr;
  var cmdLen = 0;
  if (config.compilerOpts != null) {
    clangCmdArgs = createDynamicStringArray(config.compilerOpts);
    cmdLen = config.compilerOpts.length;
  }
  final tu = clang.clang_parseTranslationUnit(
    index,
    Utf8.toUtf8(file.path).cast(),
    clangCmdArgs.cast(),
    cmdLen,
    nullptr,
    0,
    clang_types.CXTranslationUnit_Flags.CXTranslationUnit_KeepGoing,
  );

  if (tu == nullptr) {
    _logger.severe('Unable to parse Macros.');
  } else {
    final rootCursor = clang.clang_getTranslationUnitCursor_wrap(tu);

    final resultCode = clang.clang_visitChildren_wrap(
      rootCursor,
      Pointer.fromFunction(_macroVariablevisitor,
          clang_types.CXChildVisitResult.CXChildVisit_Break),
      uid,
    );

    visitChildrenResultChecker(resultCode);
    rootCursor.dispose();
  }

  clang.clang_disposeTranslationUnit(tu);
  clang.clang_disposeIndex(index);
  // Delete the temp file created for macros.
  file.deleteSync();

  return _bindings;
}

/// Child visitor invoked on translationUnitCursor for parsing macroVariables.
int _macroVariablevisitor(Pointer<clang_types.CXCursor> cursor,
    Pointer<clang_types.CXCursor> parent, Pointer<Void> clientData) {
  Constant constant;
  try {
    if (isFromGeneratedFile(cursor) &&
        _macroVarNames.contains(cursor.spelling()) &&
        cursor.kind() == clang_types.CXCursorKind.CXCursor_VarDecl) {
      final e = clang.clang_Cursor_Evaluate_wrap(cursor);
      final k = clang.clang_EvalResult_getKind(e);
      _logger.fine('macroVariablevisitor: ${cursor.completeStringRepr()}');

      /// Get macro name, the variable name starts with '<macro-name>_'.
      final macroName = MacroVariableString.decode(cursor.spelling());
      switch (k) {
        case clang_types.CXEvalResultKind.CXEval_Int:
          constant = Constant(
            originalName: savedMacros[macroName],
            name: macroName,
            rawType: 'int',
            rawValue: clang.clang_EvalResult_getAsLongLong(e).toString(),
          );
          break;
        case clang_types.CXEvalResultKind.CXEval_Float:
          constant = Constant(
            originalName: savedMacros[macroName],
            name: macroName,
            rawType: 'double',
            rawValue: clang.clang_EvalResult_getAsDouble(e).toString(),
          );
          break;
        case clang_types.CXEvalResultKind.CXEval_StrLiteral:
          var value = Utf8.fromUtf8(clang.clang_EvalResult_getAsStr(e).cast());
          // Escape $ character.
          value = value.replaceAll(r'$', r'\$');
          // Escape ' character, because our strings are enclosed with '.
          value = value.replaceAll("'", r"\'");
          constant = Constant(
            originalName: savedMacros[macroName],
            name: macroName,
            rawType: 'String',
            rawValue: "'${value}'",
          );
          break;
      }
      clang.clang_EvalResult_dispose(e);

      if (constant != null) {
        _bindings.add(constant);
      }
    }
    cursor.dispose();
    parent.dispose();
  } catch (e, s) {
    _logger.severe(e);
    _logger.severe(s);
    rethrow;
  }
  return clang_types.CXChildVisitResult.CXChildVisit_Continue;
}

/// Returns true if cursor is from generated file.
bool isFromGeneratedFile(Pointer<clang_types.CXCursor> cursor) {
  final s = cursor.sourceFileName();
  if (s == null || s.isEmpty) {
    return false;
  } else {
    return p.basename(s) == _generatedFileBaseName;
  }
}

/// Base name of generated file.
String _generatedFileBaseName;

/// Generated macro variable names.
///
/// Used to determine if macro should be included in bindings or not.
Set<String> _macroVarNames;

/// Creates a temporary file for parsing macros in current directory.
File createFileForMacros() {
  final fileNameBase = 'temp_for_macros';
  final fileExt = 'hpp';

  // Find a filename which doesn't already exist.
  var file = File('$fileNameBase.$fileExt');
  var i = 0;
  while (file.existsSync()) {
    i++;
    file = File('${fileNameBase.split('.')[0]}_$i.$fileExt');
  }

  // Create file.
  file.createSync();
  // Save generted name.
  _generatedFileBaseName = p.basename(file.path);

  // Write file contents.
  final sb = StringBuffer();
  for (final h in config.headers.entryPoints) {
    sb.writeln('#include "$h"');
  }

  _macroVarNames = {};
  for (final prefixedMacroName in savedMacros.keys) {
    // Write macro.
    final macroVarName = MacroVariableString.encode(prefixedMacroName);
    sb.writeln('auto ${macroVarName} = ${savedMacros[prefixedMacroName]};');
    // Add to _macroVarNames.
    _macroVarNames.add(macroVarName);
  }
  final macroFileContent = sb.toString();
  // Log this generated file for debugging purpose.
  // We use the finest log because this file may be very big.
  _logger.finest('=====FILE FOR MACROS====');
  _logger.finest(macroFileContent);
  _logger.finest('========================');

  file.writeAsStringSync(macroFileContent);
  return file;
}

/// Deals with encoding/decoding name of the variable generated for a Macro.
class MacroVariableString {
  static String encode(String s) {
    return '_${s.length}_${s}_generated_macro_variable';
  }

  static String decode(String s) {
    // Remove underscore.
    s = s.substring(1);
    final intReg = RegExp('[0-9]+');
    final lengthEnd = intReg.matchAsPrefix(s).end;
    final len = int.parse(s.substring(0, lengthEnd));

    // Name starts after an unerscore.
    final nameStart = lengthEnd + 1;
    return s.substring(nameStart, nameStart + len);
  }
}
