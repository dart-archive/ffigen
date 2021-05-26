// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser/includer.dart';
import 'package:ffigen/src/header_parser/type_extractor/extractor.dart';
import 'package:logging/logging.dart';

import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.typedefdecl_parser');

/// Holds temporary information regarding a typedef referenced [Binding]
/// while parsing.
///
/// Notes:
/// - Pointer to Typedefs structs are skipped if the struct is seen.
/// - If there are multiple typedefs for a declaration (struct/enum), the last
/// seen name is used.
/// - Typerefs are completely ignored.
///
/// Libclang marks them as following -
/// ```C
/// typedef struct A{
///   int a
/// } B, *pB; // Typedef(s).
///
/// typedef A D; // Typeref.
/// ```
class _ParsedTypealias {
  Typealias? typealias;
  String? typedefName;
  bool typedefToPointer = false;
  _ParsedTypealias();
}

final _stack = Stack<_ParsedTypealias>();

/// Parses a typedef declaration.
///
/// Returns `null` if the typedef could not be generated or has been excluded
/// by the config.
Typealias? parseTypedefDeclaration(
  clang_types.CXCursor cursor, {
  bool pointerReference = false,
}) {
  _stack.push(_ParsedTypealias());
  final typedefName = cursor.spelling();
  final typedefUsr = cursor.usr();
  if (shouldIncludeTypealias(typedefUsr, typedefName)) {
    final ct = clang.clang_getTypedefDeclUnderlyingType(cursor);
    final s = getCodeGenType(ct, pointerReference: pointerReference);

    if (bindingsIndex.isSeenUnsupportedTypealias(typedefUsr)) {
      // Do not process unsupported typealiases again.
    } else if (s.broadType == BroadType.Unimplemented) {
      _logger
          .fine("Skipped Typedef '$typedefName': Unimplemented type referred.");
      bindingsIndex.addUnsupportedTypealiasToSeen(typedefUsr);
    } else if (s.broadType == BroadType.Compound &&
        s.compound!.originalName == typedefName) {
      // Ignore typedef if it refers to a compound with the same original name.
      bindingsIndex.addUnsupportedTypealiasToSeen(typedefUsr);
      _logger.fine(
          "Skipped Typedef '$typedefName': Name matches with referred struct/union.");
    } else if (s.broadType == BroadType.Enum) {
      // Ignore typedefs to Enum.
      bindingsIndex.addUnsupportedTypealiasToSeen(typedefUsr);
      _logger.fine("Skipped Typedef '$typedefName': typedef to enum.");
    } else if (s.broadType == BroadType.Handle) {
      // Ignore typedefs to Handle.
      _logger.fine("Skipped Typedef '$typedefName': typedef to Dart Handle.");
      bindingsIndex.addUnsupportedTypealiasToSeen(typedefUsr);
    } else if (s.broadType == BroadType.ConstantArray ||
        s.broadType == BroadType.IncompleteArray) {
      // Ignore typedefs to Constant Array.
      _logger.fine("Skipped Typedef '$typedefName': typedef to array.");
      bindingsIndex.addUnsupportedTypealiasToSeen(typedefUsr);
    } else if (s.broadType == BroadType.Boolean) {
      // Ignore typedefs to Boolean.
      _logger.fine("Skipped Typedef '$typedefName': typedef to bool.");
      bindingsIndex.addUnsupportedTypealiasToSeen(typedefUsr);
    } else {
      // Create typealias.
      _stack.top.typealias = Typealias(
        usr: typedefUsr,
        originalName: typedefName,
        name: config.typedefs.renameUsingConfig(typedefName),
        type: s,
        dartDoc: getCursorDocComment(cursor),
      );
      bindingsIndex.addTypealiasToSeen(typedefUsr, _stack.top.typealias!);
    }
  }

  if (bindingsIndex.isSeenTypealias(typedefUsr)) {
    _stack.top.typealias = bindingsIndex.getSeenTypealias(typedefUsr);
  }

  return _stack.pop().typealias;
}
