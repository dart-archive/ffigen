// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffigen/src/strings.dart' as strings;
import 'package:path/path.dart' as p;
import 'package:ffi/ffi.dart';
import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/data.dart';
import 'package:ffigen/src/header_parser/includer.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.macro_parser');

/// Adds a macro definition to be parsed later.
void saveMacroDefinition(Pointer<clang_types.CXCursor> cursor) {
  final macroUsr = cursor.usr();
  final originalMacroName = cursor.spelling();
  if (clang.clang_Cursor_isMacroBuiltin_wrap(cursor) == 0 &&
      clang.clang_Cursor_isMacroFunctionLike_wrap(cursor) == 0 &&
      shouldIncludeMacro(macroUsr, originalMacroName)) {
    // Parse macro only if it's not builtin or function-like.
    _logger.fine(
        "++++ Saved Macro '$originalMacroName' for later : ${cursor.completeStringRepr()}");
    final prefixedName = config.macroDecl.renameUsingConfig(originalMacroName);
    bindingsIndex.addMacroToSeen(macroUsr, prefixedName);
    _saveMacro(prefixedName, macroUsr, originalMacroName);
  }
}

/// Saves a macro to be parsed later.
///
/// Macros are parsed later in [parseSavedMacros()].
void _saveMacro(String name, String usr, String originalName) {
  savedMacros[name] = Macro(usr, originalName);
}

List<Constant>? _bindings;

/// Macros cannot be parsed directly, so we create a new `.hpp` file in which
/// they are assigned to a variable after which their value can be determined
/// by evaluating the value of the variable.
List<Constant>? parseSavedMacros() {
  _bindings = [];

  if (savedMacros.keys.isEmpty) {
    return _bindings;
  }

  // Create a file for parsing macros;
  final file = createFileForMacros();

  final index = clang.clang_createIndex(0, 0);
  Pointer<Pointer<Utf8>> clangCmdArgs = nullptr;
  var cmdLen = 0;
  clangCmdArgs = createDynamicStringArray(config.compilerOpts);
  cmdLen = config.compilerOpts.length;
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
  Constant? constant;
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
            usr: savedMacros[macroName]!.usr,
            originalName: savedMacros[macroName]!.originalName,
            name: macroName,
            rawType: 'int',
            rawValue: clang.clang_EvalResult_getAsLongLong(e).toString(),
          );
          break;
        case clang_types.CXEvalResultKind.CXEval_Float:
          constant = Constant(
            usr: savedMacros[macroName]!.usr,
            originalName: savedMacros[macroName]!.originalName,
            name: macroName,
            rawType: 'double',
            rawValue:
                _writeDoubleAsString(clang.clang_EvalResult_getAsDouble(e)),
          );
          break;
        case clang_types.CXEvalResultKind.CXEval_StrLiteral:
          final rawValue = _getWrittenRepresentation(
            macroName,
            clang.clang_EvalResult_getAsStr(e),
          );
          constant = Constant(
            usr: savedMacros[macroName]!.usr,
            originalName: savedMacros[macroName]!.originalName,
            name: macroName,
            rawType: 'String',
            rawValue: "'${rawValue}'",
          );
          break;
      }
      clang.clang_EvalResult_dispose(e);

      if (constant != null) {
        _bindings!.add(constant);
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
  return p.basename(s) == _generatedFileBaseName;
}

/// Base name of generated file.
String? _generatedFileBaseName;

/// Generated macro variable names.
///
/// Used to determine if macro should be included in bindings or not.
late Set<String> _macroVarNames;

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
    sb.writeln(
        'auto ${macroVarName} = ${savedMacros[prefixedMacroName]!.originalName};');
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
    final lengthEnd = intReg.matchAsPrefix(s)!.end;
    final len = int.parse(s.substring(0, lengthEnd));

    // Name starts after an unerscore.
    final nameStart = lengthEnd + 1;
    return s.substring(nameStart, nameStart + len);
  }
}

/// Gets a written representation string of a C string.
///
/// E.g- For a string "Hello\nWorld", The new line character is converted to \n.
/// Note: The string is considered to be Utf8, but is treated as Extended ASCII,
/// if the conversion fails.
String _getWrittenRepresentation(String macroName, Pointer<Int8> strPtr) {
  final sb = StringBuffer();
  try {
    // Consider string to be Utf8 encoded by default.
    sb.clear();
    // This throws a Format Exception if string isn't Utf8 so that we handle it
    // in the catch block.
    final result = Utf8.fromUtf8(strPtr.cast());
    for (final s in result.runes) {
      sb.write(_getWritableChar(s));
    }
  } catch (e) {
    // Handle string if it isn't Utf8. String is considered to be
    // Extended ASCII in this case.
    _logger.warning(
        "Couldn't decode Macro string '$macroName' as Utf8, using ASCII instead.");
    sb.clear();
    final length = Utf8.strlen(strPtr.cast());
    final charList = Uint8List.view(
        strPtr.cast<Uint8>().asTypedList(length).buffer, 0, length);

    for (final char in charList) {
      sb.write(_getWritableChar(char, utf8: false));
    }
  }

  return sb.toString();
}

/// Creates a writable char from [char] code.
///
/// E.g- `\` is converted to `\\`.
String _getWritableChar(int char, {bool utf8 = true}) {
  /// Handle control characters.
  if (char >= 0 && char < 32 || char == 127) {
    /// Handle these - `\b \t \n \v \f \r` as special cases.
    switch (char) {
      case 8: // \b
        return r'\b';
      case 9: // \t
        return r'\t';
      case 10: // \n
        return r'\n';
      case 11: // \v
        return r'\v';
      case 12: // \f
        return r'\f';
      case 13: // \r
        return r'\r';
      default:
        final h = char.toRadixString(16).toUpperCase().padLeft(2, '0');
        return '\\x${h}';
    }
  }

  /// Handle characters - `$ ' \` these need to be escaped when writing to file.
  switch (char) {
    case 36: // $
      return r'\$';
    case 39: // '
      return r"\'";
    case 92: // \
      return r'\\';
  }

  /// In case encoding is not Utf8, we know all characters will fall in [0..255]
  /// Print range [128..255] as `\xHH`.
  if (!utf8) {
    final h = char.toRadixString(16).toUpperCase().padLeft(2, '0');
    return '\\x${h}';
  }

  /// In all other cases, simply convert to string.
  return String.fromCharCode(char);
}

/// Converts a double to a string, handling cases like Infinity and NaN.
String _writeDoubleAsString(double d) {
  if (d.isFinite) {
    return d.toString();
  } else {
    // The only Non-Finite numbers are Infinity, NegativeInfinity and NaN.
    if (d.isInfinite) {
      return d.isNegative
          ? strings.doubleNegativeInfinity
          : strings.doubleInfinity;
    }
    return strings.doubleNaN;
  }
}
