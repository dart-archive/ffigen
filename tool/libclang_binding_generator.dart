// Dev tool for generating libclang bindings using the code_generator submodule
// file generated is lib/src/header_parser/clang_bindings/clang_bindings.dart
import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:logging/logging.dart';

const _cxTranslationUnitImp = 'CXTranslationUnitImpl';
const _cxUnsavedFile = 'CXUnsavedFile';
const _cxString = 'CXString';
const _cxCursor = 'CXCursor';
const _cxType = 'CXType';

var _logger = Logger('tool:libclang_binding_generator');
void main() {
  final library = Library(
      bindings: bindings,
      header:
          '/// Call [init(dylib)] to initialise dynamicLibrary before using \n\n/// AUTOMATICALLY GENERATED DO NOT EDIT');

  var f = File('lib/src/header_parser/clang_bindings/clang_bindings.dart');

  library.sort();
  // Generates bindings for libclang wrapper
  library.generateFile(f);

  _logger.info("Generated bindings: ${f.absolute.path}");
}

final bindings = <Binding>[
  ...functionAndTypedefsList,
  ...structList,
];

final functionAndTypedefsList = <Binding>[
  Func(
    dartDoc: 'Dispose index using [clang_disposeIndex]',
    name: 'clang_createIndex',
    parameters: [
      Parameter(
        name: 'excludeDeclarationsFromPCH',
        type: Type(
          type: BroadType.NativeType,
          nativeType: SupportedNativeType.Int32,
        ),
      ),
      Parameter(
        name: 'displayDiagnostics',
        type: Type(
          type: BroadType.NativeType,
          nativeType: SupportedNativeType.Int32,
        ),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(
            type: BroadType.NativeType, nativeType: SupportedNativeType.Void)),
  ),
  Func(
    dartDoc: '',
    name: 'clang_disposeIndex',
    parameters: [
      Parameter(
        name: 'index',
        type: Type(
            type: BroadType.Pointer,
            child: Type(
                type: BroadType.NativeType,
                nativeType: SupportedNativeType.Void)),
      ),
    ],
    returnType: Type(
      type: BroadType.NativeType,
      nativeType: SupportedNativeType.Void,
    ),
  ),
  Func(
    dartDoc: 'Dispose tu using [clang_disposeTranslationUnit]',
    name: 'clang_parseTranslationUnit',
    parameters: [
      Parameter(
        name: 'cxindex',
        type: Type(
            type: BroadType.Pointer,
            child: Type(
                type: BroadType.NativeType,
                nativeType: SupportedNativeType.Void)),
      ),
      Parameter(
        name: 'source_filename',
        type: Type(
            type: BroadType.Pointer,
            child: Type(
                type: BroadType.FfiUtilType, ffiUtilType: FfiUtilType.Utf8)),
      ),
      Parameter(
        name: 'cmd_line_args',
        type: Type(
            type: BroadType.Pointer,
            child: Type(
              type: BroadType.Pointer,
              child: Type(
                  type: BroadType.FfiUtilType, ffiUtilType: FfiUtilType.Utf8),
            )),
      ),
      Parameter(
        name: 'num_cmd_line_args',
        type: Type(
          type: BroadType.NativeType,
          nativeType: SupportedNativeType.Int32,
        ),
      ),
      Parameter(
        name: 'unsaved_files',
        type: Type(
          type: BroadType.Pointer,
          child: Type(type: BroadType.Struct, structName: _cxUnsavedFile),
        ),
      ),
      Parameter(
        name: 'num_unsaved_files',
        type: Type(
          type: BroadType.NativeType,
          nativeType: SupportedNativeType.Uint32,
        ),
      ),
      Parameter(
        name: 'options',
        type: Type(
          type: BroadType.NativeType,
          nativeType: SupportedNativeType.Uint32,
        ),
      ),
    ],
    returnType: Type(
      type: BroadType.Pointer,
      child: Type(type: BroadType.Struct, structName: _cxTranslationUnitImp),
    ),
  ),
  Func(
    dartDoc: '',
    name: 'clang_disposeTranslationUnit',
    parameters: [
      Parameter(
        name: 'cxtranslation_unit',
        type: Type(
          type: BroadType.Pointer,
          child: Type(type: BroadType.Struct, structName: _cxTranslationUnitImp),
        ),
      ),
    ],
    returnType: Type(
      type: BroadType.NativeType,
      nativeType: SupportedNativeType.Void,
    ),
  ),
  Func(
    dartDoc: 'Free [CXcursor] after use',
    name: 'clang_getTranslationUnitCursor_wrap',
    parameters: [
      Parameter(
        name: 'cxtranslation_unit',
        type: Type(
          type: BroadType.Pointer,
          child: Type(type: BroadType.Struct, structName: _cxTranslationUnitImp),
        ),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxCursor)),
  ),
  Func(
    dartDoc: '',
    name: 'clang_getNumDiagnostics',
    parameters: [
      Parameter(
        name: 'cxtranslationunit',
        type: Type(
          type: BroadType.Pointer,
          child: Type(type: BroadType.Struct, structName: _cxTranslationUnitImp),
        ),
      ),
    ],
    returnType: Type(
      type: BroadType.NativeType,
      nativeType: SupportedNativeType.Uint32,
    ),
  ),
  Func(
    dartDoc: 'Dispose diagnostic using [clang_disposeDiagnostic]',
    name: 'clang_getDiagnostic',
    parameters: [
      Parameter(
        name: 'cxTranslationUnit',
        type: Type(
          type: BroadType.Pointer,
          child: Type(type: BroadType.Struct, structName: _cxTranslationUnitImp),
        ),
      ),
      Parameter(
        name: 'position',
        type: Type(
          type: BroadType.NativeType,
          nativeType: SupportedNativeType.Int32,
        ),
      ),
    ],
    returnType: Type(
      type: BroadType.Pointer,
      child: Type(
          type: BroadType.NativeType, nativeType: SupportedNativeType.Void),
    ),
  ),
  Func(
    dartDoc: '',
    name: 'clang_disposeDiagnostic',
    parameters: [
      Parameter(
        name: 'diagnostic',
        type: Type(
          type: BroadType.Pointer,
          child: Type(
              type: BroadType.NativeType, nativeType: SupportedNativeType.Void),
        ),
      ),
    ],
    returnType: Type(
      type: BroadType.NativeType,
      nativeType: SupportedNativeType.Void,
    ),
  ),
  Func(
    dartDoc: 'Dispose [CXString] after use using [clang_disposeString_wrap]',
    name: 'clang_formatDiagnostic_wrap',
    parameters: [
      Parameter(
        name: 'diagnostic',
        type: Type(
          type: BroadType.Pointer,
          child: Type(
              type: BroadType.NativeType, nativeType: SupportedNativeType.Void),
        ),
      ),
      Parameter(
        name: 'diagnosticOptions',
        type: Type(
          type: BroadType.NativeType,
          nativeType: SupportedNativeType.Uint32,
        ),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxString)),
  ),
  Func(
    dartDoc: '',
    name: 'clang_defaultDiagnosticDisplayOptions',
    parameters: [],
    returnType: Type(
      type: BroadType.NativeType,
      nativeType: SupportedNativeType.Uint32,
    ),
  ),
  Func(
    dartDoc:
        'Dispose [CXString] using [clang_disposeString_wrap], it also frees the CString(const char *), do not free CString directly',
    name: 'clang_getCString_wrap',
    parameters: [
      Parameter(
        name: 'cxstringPtr',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxString)),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child:
            Type(type: BroadType.FfiUtilType, ffiUtilType: FfiUtilType.Utf8)),
  ),
  Func(
    dartDoc: 'Free a CXString using this (Do not use free)',
    name: 'clang_disposeString_wrap',
    parameters: [
      Parameter(
        name: 'cxstringPtr',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxString)),
      ),
    ],
    returnType: Type(
      type: BroadType.NativeType,
      nativeType: SupportedNativeType.Void,
    ),
  ),
  Func(
    dartDoc:
        'Free cursor after use, dispose CXString using [clang_disposeString_wrap]',
    name: 'clang_getCursorSpelling_wrap',
    parameters: [
      Parameter(
        name: 'cursor',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxCursor)),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxString)),
  ),
  Func(
    dartDoc: 'Free cursor after use',
    name: 'clang_getCursorKind_wrap',
    parameters: [
      Parameter(
        name: 'cursor',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxCursor)),
      ),
    ],
    returnType: Type(
      type: BroadType.NativeType,
      nativeType: SupportedNativeType.Int32,
    ),
  ),
  Func(
    dartDoc: 'dispose CXString using [clang_disposeString_wrap]',
    name: 'clang_getCursorKindSpelling_wrap',
    parameters: [
      Parameter(
        name: 'kind',
        type: Type(
          type: BroadType.NativeType,
          nativeType: SupportedNativeType.Int32,
        ),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxString)),
  ),
  Func(
    dartDoc: 'Free CXType after use',
    name: 'clang_getCursorType_wrap',
    parameters: [
      Parameter(
        name: 'cursor',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxCursor)),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxType)),
  ),
  Func(
    dartDoc: 'Dispose CXString after use',
    name: 'clang_getTypeKindSpelling_wrap',
    parameters: [
      Parameter(
        name: 'typeKind',
        type: Type(
          type: BroadType.NativeType,
          nativeType: SupportedNativeType.Int32,
        ),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxString)),
  ),
  Func(
    dartDoc:
        'Free cxtype after use, dispose CXString using [clang_disposeString_wrap]',
    name: 'clang_getTypeSpelling_wrap',
    parameters: [
      Parameter(
        name: 'typePtr',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxType)),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxString)),
  ),
  Func(
    dartDoc: 'Free cxtype after use',
    name: 'clang_getResultType_wrap',
    parameters: [
      Parameter(
        name: 'functionType',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxType)),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxType)),
  ),
  Func(
    dartDoc: 'Free cxtype after use',
    name: 'clang_getPointeeType_wrap',
    parameters: [
      Parameter(
        name: 'pointerType',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxType)),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxType)),
  ),
  Func(
    dartDoc: 'Free cxtype after use',
    name: 'clang_getCanonicalType_wrap',
    parameters: [
      Parameter(
        name: 'typerefType',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxType)),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxType)),
  ),
  Func(
    dartDoc: 'Free cxtype after use',
    name: 'clang_Type_getNamedType_wrap',
    parameters: [
      Parameter(
        name: 'elaboratedType',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxType)),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxType)),
  ),
  Func(
    dartDoc: 'Free cxcursor after use',
    name: 'clang_getTypeDeclaration_wrap',
    parameters: [
      Parameter(
        name: 'cxtype',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxType)),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxCursor)),
  ),
  Func(
    dartDoc: 'Free cxtype after use',
    name: 'clang_getTypedefDeclUnderlyingType_wrap',
    parameters: [
      Parameter(
        name: 'typerefType',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxCursor)),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxType)),
  ),
  TypedefC(
    dartDoc:
        'C signature for `visitorFunction` parameter in [clang_visitChildren_wrap]',
    name: 'visitorFunctionSignature',
    parameters: [
      Parameter(
        name: 'cursor',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxCursor)),
      ),
      Parameter(
        name: 'parent',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxCursor)),
      ),
      Parameter(
        name: 'clientData',
        type: Type(
          type: BroadType.Pointer,
          child: Type(
              type: BroadType.NativeType, nativeType: SupportedNativeType.Void),
        ),
      ),
    ],
    returnType: Type(
      type: BroadType.NativeType,
      nativeType: SupportedNativeType.Int32,
    ),
  ),
  Func(
    dartDoc: 'Free cursor after use',
    name: 'clang_visitChildren_wrap',
    parameters: [
      Parameter(
        name: 'cursor',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxCursor)),
      ),
      Parameter(
        name: 'pointerToVisitorFunc',
        type: Type(
            type: BroadType.NativeFunction,
            nativeFuncName: 'visitorFunctionSignature'),
      ),
      Parameter(
        name: 'clientData',
        type: Type(
            type: BroadType.Pointer,
            child: Type(
                type: BroadType.NativeType,
                nativeType: SupportedNativeType.Void)),
      ),
    ],
    returnType: Type(
      type: BroadType.NativeType,
      nativeType: SupportedNativeType.Int32,
    ),
  ),
  Func(
    dartDoc:
        'Get Arguments of a function/method, returns -1 for other cursors\n\nFree cursor after use',
    name: 'clang_Cursor_getNumArguments_wrap',
    parameters: [
      Parameter(
        name: 'cursor',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxCursor)),
      ),
    ],
    returnType: Type(
      type: BroadType.NativeType,
      nativeType: SupportedNativeType.Int32,
    ),
  ),
  Func(
    dartDoc: 'Free cursor after use,',
    name: 'clang_Cursor_getArgument_wrap',
    parameters: [
      Parameter(
        name: 'cursor',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxCursor)),
      ),
      Parameter(
        name: 'i',
        type: Type(
          type: BroadType.NativeType,
          nativeType: SupportedNativeType.Uint32,
        ),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxCursor)),
  ),
  Func(
      dartDoc: '',
      name: 'clang_getEnumConstantDeclValue_wrap',
      parameters: [
        Parameter(
          name: 'cursor',
          type: Type(
              type: BroadType.Pointer,
              child: Type(type: BroadType.Struct, structName: _cxCursor)),
        ),
      ],
      returnType: Type(
          type: BroadType.NativeType, nativeType: SupportedNativeType.Int64)),
  Func(
    dartDoc: '',
    name: 'clang_Cursor_getBriefCommentText_wrap',
    parameters: [
      Parameter(
        name: 'cursor',
        type: Type(
            type: BroadType.Pointer,
            child: Type(type: BroadType.Struct, structName: _cxCursor)),
      ),
    ],
    returnType: Type(
        type: BroadType.Pointer,
        child: Type(type: BroadType.Struct, structName: _cxString)),
  ),
];

final structList = <Binding>[
  Struc(
    dartDoc: '',
    name: _cxUnsavedFile,
    members: [],
  ),
  Struc(
    dartDoc: '',
    name: _cxString,
    members: [],
  ),
  Struc(
    dartDoc: '',
    name: _cxCursor,
    members: [],
  ),
  Struc(
    dartDoc: '',
    name: _cxType,
    members: [
      Member(
          type: Type(
            type: BroadType.NativeType,
            nativeType: SupportedNativeType.Int32,
          ),
          name: 'kind'),
    ],
  ),
  Struc(
    dartDoc: '',
    name: _cxTranslationUnitImp,
    members: [],
  ),
];
