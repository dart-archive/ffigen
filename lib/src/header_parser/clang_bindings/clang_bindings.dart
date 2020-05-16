/// Call [init(dylib)] to initialise dynamicLibrary before using

/// AUTOMATICALLY GENERATED DO NOT EDIT
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi2;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib) {
  _dylib = dylib;
}

///
ffi.Pointer<ffi.Void> clang_createIndex(
  int excludeDeclarationsFromPCH,
  int displayDiagnostics,
) {
  return _clang_createIndex(
    excludeDeclarationsFromPCH,
    displayDiagnostics,
  );
}

final _dart_clang_createIndex _clang_createIndex =
    _dylib.lookupFunction<_c_clang_createIndex, _dart_clang_createIndex>(
        'clang_createIndex');

typedef _c_clang_createIndex = ffi.Pointer<ffi.Void> Function(
  ffi.Int32 excludeDeclarationsFromPCH,
  ffi.Int32 displayDiagnostics,
);

typedef _dart_clang_createIndex = ffi.Pointer<ffi.Void> Function(
  int excludeDeclarationsFromPCH,
  int displayDiagnostics,
);

///
void clang_disposeIndex(
  ffi.Pointer<ffi.Void> index,
) {
  return _clang_disposeIndex(
    index,
  );
}

final _dart_clang_disposeIndex _clang_disposeIndex =
    _dylib.lookupFunction<_c_clang_disposeIndex, _dart_clang_disposeIndex>(
        'clang_disposeIndex');

typedef _c_clang_disposeIndex = ffi.Void Function(
  ffi.Pointer<ffi.Void> index,
);

typedef _dart_clang_disposeIndex = void Function(
  ffi.Pointer<ffi.Void> index,
);

///
ffi.Pointer<CXTranslationUnitImpl> clang_parseTranslationUnit(
  ffi.Pointer<ffi.Void> cxindex,
  ffi.Pointer<ffi2.Utf8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi2.Utf8>> cmd_line_args,
  int num_cmd_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  int options,
) {
  return _clang_parseTranslationUnit(
    cxindex,
    source_filename,
    cmd_line_args,
    num_cmd_line_args,
    unsaved_files,
    num_unsaved_files,
    options,
  );
}

final _dart_clang_parseTranslationUnit _clang_parseTranslationUnit =
    _dylib.lookupFunction<_c_clang_parseTranslationUnit,
        _dart_clang_parseTranslationUnit>('clang_parseTranslationUnit');

typedef _c_clang_parseTranslationUnit = ffi.Pointer<CXTranslationUnitImpl>
    Function(
  ffi.Pointer<ffi.Void> cxindex,
  ffi.Pointer<ffi2.Utf8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi2.Utf8>> cmd_line_args,
  ffi.Int32 num_cmd_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  ffi.Uint32 num_unsaved_files,
  ffi.Uint32 options,
);

typedef _dart_clang_parseTranslationUnit = ffi.Pointer<CXTranslationUnitImpl>
    Function(
  ffi.Pointer<ffi.Void> cxindex,
  ffi.Pointer<ffi2.Utf8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi2.Utf8>> cmd_line_args,
  int num_cmd_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  int options,
);

///
void clang_disposeTranslationUnit(
  ffi.Pointer<CXTranslationUnitImpl> cxtranslation_unit,
) {
  return _clang_disposeTranslationUnit(
    cxtranslation_unit,
  );
}

final _dart_clang_disposeTranslationUnit _clang_disposeTranslationUnit =
    _dylib.lookupFunction<_c_clang_disposeTranslationUnit,
        _dart_clang_disposeTranslationUnit>('clang_disposeTranslationUnit');

typedef _c_clang_disposeTranslationUnit = ffi.Void Function(
  ffi.Pointer<CXTranslationUnitImpl> cxtranslation_unit,
);

typedef _dart_clang_disposeTranslationUnit = void Function(
  ffi.Pointer<CXTranslationUnitImpl> cxtranslation_unit,
);

///
ffi.Pointer<CXCursor> clang_getTranslationUnitCursor_wrap(
  ffi.Pointer<CXTranslationUnitImpl> cxtranslation_unit,
) {
  return _clang_getTranslationUnitCursor_wrap(
    cxtranslation_unit,
  );
}

final _dart_clang_getTranslationUnitCursor_wrap
    _clang_getTranslationUnitCursor_wrap = _dylib.lookupFunction<
            _c_clang_getTranslationUnitCursor_wrap,
            _dart_clang_getTranslationUnitCursor_wrap>(
        'clang_getTranslationUnitCursor_wrap');

typedef _c_clang_getTranslationUnitCursor_wrap = ffi.Pointer<CXCursor> Function(
  ffi.Pointer<CXTranslationUnitImpl> cxtranslation_unit,
);

typedef _dart_clang_getTranslationUnitCursor_wrap = ffi.Pointer<CXCursor>
    Function(
  ffi.Pointer<CXTranslationUnitImpl> cxtranslation_unit,
);

///
int clang_getNumDiagnostics(
  ffi.Pointer<CXTranslationUnitImpl> cxtranslationunit,
) {
  return _clang_getNumDiagnostics(
    cxtranslationunit,
  );
}

final _dart_clang_getNumDiagnostics _clang_getNumDiagnostics = _dylib
    .lookupFunction<_c_clang_getNumDiagnostics, _dart_clang_getNumDiagnostics>(
        'clang_getNumDiagnostics');

typedef _c_clang_getNumDiagnostics = ffi.Uint32 Function(
  ffi.Pointer<CXTranslationUnitImpl> cxtranslationunit,
);

typedef _dart_clang_getNumDiagnostics = int Function(
  ffi.Pointer<CXTranslationUnitImpl> cxtranslationunit,
);

///
ffi.Pointer<ffi.Void> clang_getDiagnostic(
  ffi.Pointer<CXTranslationUnitImpl> cxTranslationUnit,
  int position,
) {
  return _clang_getDiagnostic(
    cxTranslationUnit,
    position,
  );
}

final _dart_clang_getDiagnostic _clang_getDiagnostic =
    _dylib.lookupFunction<_c_clang_getDiagnostic, _dart_clang_getDiagnostic>(
        'clang_getDiagnostic');

typedef _c_clang_getDiagnostic = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXTranslationUnitImpl> cxTranslationUnit,
  ffi.Int32 position,
);

typedef _dart_clang_getDiagnostic = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXTranslationUnitImpl> cxTranslationUnit,
  int position,
);

///
ffi.Pointer<CXString> clang_formatDiagnostic_wrap(
  ffi.Pointer<ffi.Void> diagnostic,
  int diagnosticOptions,
) {
  return _clang_formatDiagnostic_wrap(
    diagnostic,
    diagnosticOptions,
  );
}

final _dart_clang_formatDiagnostic_wrap _clang_formatDiagnostic_wrap =
    _dylib.lookupFunction<_c_clang_formatDiagnostic_wrap,
        _dart_clang_formatDiagnostic_wrap>('clang_formatDiagnostic_wrap');

typedef _c_clang_formatDiagnostic_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<ffi.Void> diagnostic,
  ffi.Uint32 diagnosticOptions,
);

typedef _dart_clang_formatDiagnostic_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<ffi.Void> diagnostic,
  int diagnosticOptions,
);

///
int clang_defaultDiagnosticDisplayOptions() {
  return _clang_defaultDiagnosticDisplayOptions();
}

final _dart_clang_defaultDiagnosticDisplayOptions
    _clang_defaultDiagnosticDisplayOptions = _dylib.lookupFunction<
            _c_clang_defaultDiagnosticDisplayOptions,
            _dart_clang_defaultDiagnosticDisplayOptions>(
        'clang_defaultDiagnosticDisplayOptions');

typedef _c_clang_defaultDiagnosticDisplayOptions = ffi.Uint32 Function();

typedef _dart_clang_defaultDiagnosticDisplayOptions = int Function();

///
ffi.Pointer<ffi2.Utf8> clang_getCString_wrap(
  ffi.Pointer<CXString> cxstringPtr,
) {
  return _clang_getCString_wrap(
    cxstringPtr,
  );
}

final _dart_clang_getCString_wrap _clang_getCString_wrap = _dylib
    .lookupFunction<_c_clang_getCString_wrap, _dart_clang_getCString_wrap>(
        'clang_getCString_wrap');

typedef _c_clang_getCString_wrap = ffi.Pointer<ffi2.Utf8> Function(
  ffi.Pointer<CXString> cxstringPtr,
);

typedef _dart_clang_getCString_wrap = ffi.Pointer<ffi2.Utf8> Function(
  ffi.Pointer<CXString> cxstringPtr,
);

///
void clang_disposeString_wrap(
  ffi.Pointer<CXString> cxstringPtr,
) {
  return _clang_disposeString_wrap(
    cxstringPtr,
  );
}

final _dart_clang_disposeString_wrap _clang_disposeString_wrap =
    _dylib.lookupFunction<_c_clang_disposeString_wrap,
        _dart_clang_disposeString_wrap>('clang_disposeString_wrap');

typedef _c_clang_disposeString_wrap = ffi.Void Function(
  ffi.Pointer<CXString> cxstringPtr,
);

typedef _dart_clang_disposeString_wrap = void Function(
  ffi.Pointer<CXString> cxstringPtr,
);

///
ffi.Pointer<CXString> clang_getCursorSpelling_wrap(
  ffi.Pointer<CXCursor> cursor,
) {
  return _clang_getCursorSpelling_wrap(
    cursor,
  );
}

final _dart_clang_getCursorSpelling_wrap _clang_getCursorSpelling_wrap =
    _dylib.lookupFunction<_c_clang_getCursorSpelling_wrap,
        _dart_clang_getCursorSpelling_wrap>('clang_getCursorSpelling_wrap');

typedef _c_clang_getCursorSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<CXCursor> cursor,
);

typedef _dart_clang_getCursorSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<CXCursor> cursor,
);

///
int clang_getCursorKind_wrap(
  ffi.Pointer<CXCursor> cursor,
) {
  return _clang_getCursorKind_wrap(
    cursor,
  );
}

final _dart_clang_getCursorKind_wrap _clang_getCursorKind_wrap =
    _dylib.lookupFunction<_c_clang_getCursorKind_wrap,
        _dart_clang_getCursorKind_wrap>('clang_getCursorKind_wrap');

typedef _c_clang_getCursorKind_wrap = ffi.Int32 Function(
  ffi.Pointer<CXCursor> cursor,
);

typedef _dart_clang_getCursorKind_wrap = int Function(
  ffi.Pointer<CXCursor> cursor,
);

///
ffi.Pointer<CXString> clang_getCursorKindSpelling_wrap(
  int kind,
) {
  return _clang_getCursorKindSpelling_wrap(
    kind,
  );
}

final _dart_clang_getCursorKindSpelling_wrap _clang_getCursorKindSpelling_wrap =
    _dylib.lookupFunction<_c_clang_getCursorKindSpelling_wrap,
            _dart_clang_getCursorKindSpelling_wrap>(
        'clang_getCursorKindSpelling_wrap');

typedef _c_clang_getCursorKindSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Int32 kind,
);

typedef _dart_clang_getCursorKindSpelling_wrap = ffi.Pointer<CXString> Function(
  int kind,
);

///
ffi.Pointer<CXType> clang_getCursorType_wrap(
  ffi.Pointer<CXCursor> cursor,
) {
  return _clang_getCursorType_wrap(
    cursor,
  );
}

final _dart_clang_getCursorType_wrap _clang_getCursorType_wrap =
    _dylib.lookupFunction<_c_clang_getCursorType_wrap,
        _dart_clang_getCursorType_wrap>('clang_getCursorType_wrap');

typedef _c_clang_getCursorType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXCursor> cursor,
);

typedef _dart_clang_getCursorType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXCursor> cursor,
);

///
ffi.Pointer<CXString> clang_getTypeSpelling_wrap(
  ffi.Pointer<CXType> typePtr,
) {
  return _clang_getTypeSpelling_wrap(
    typePtr,
  );
}

final _dart_clang_getTypeSpelling_wrap _clang_getTypeSpelling_wrap =
    _dylib.lookupFunction<_c_clang_getTypeSpelling_wrap,
        _dart_clang_getTypeSpelling_wrap>('clang_getTypeSpelling_wrap');

typedef _c_clang_getTypeSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<CXType> typePtr,
);

typedef _dart_clang_getTypeSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<CXType> typePtr,
);

///
ffi.Pointer<CXType> clang_getResultType_wrap(
  ffi.Pointer<CXType> functionType,
) {
  return _clang_getResultType_wrap(
    functionType,
  );
}

final _dart_clang_getResultType_wrap _clang_getResultType_wrap =
    _dylib.lookupFunction<_c_clang_getResultType_wrap,
        _dart_clang_getResultType_wrap>('clang_getResultType_wrap');

typedef _c_clang_getResultType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> functionType,
);

typedef _dart_clang_getResultType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> functionType,
);

///
ffi.Pointer<CXType> clang_getPointeeType_wrap(
  ffi.Pointer<CXType> pointerType,
) {
  return _clang_getPointeeType_wrap(
    pointerType,
  );
}

final _dart_clang_getPointeeType_wrap _clang_getPointeeType_wrap =
    _dylib.lookupFunction<_c_clang_getPointeeType_wrap,
        _dart_clang_getPointeeType_wrap>('clang_getPointeeType_wrap');

typedef _c_clang_getPointeeType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> pointerType,
);

typedef _dart_clang_getPointeeType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> pointerType,
);

/// C signature for `visitorFunction` parameter in [clang_visitChildren_wrap]
typedef visitorFunctionSignature = ffi.Int32 Function(
  ffi.Pointer<CXCursor> cursor,
  ffi.Pointer<CXCursor> parent,
  ffi.Pointer<ffi.Void> clientData,
);

///
int clang_visitChildren_wrap(
  ffi.Pointer<CXCursor> cursor,
  ffi.Pointer<ffi.NativeFunction<visitorFunctionSignature>>
      pointerToVisitorFunc,
  ffi.Pointer<ffi.Void> clientData,
) {
  return _clang_visitChildren_wrap(
    cursor,
    pointerToVisitorFunc,
    clientData,
  );
}

final _dart_clang_visitChildren_wrap _clang_visitChildren_wrap =
    _dylib.lookupFunction<_c_clang_visitChildren_wrap,
        _dart_clang_visitChildren_wrap>('clang_visitChildren_wrap');

typedef _c_clang_visitChildren_wrap = ffi.Int32 Function(
  ffi.Pointer<CXCursor> cursor,
  ffi.Pointer<ffi.NativeFunction<visitorFunctionSignature>>
      pointerToVisitorFunc,
  ffi.Pointer<ffi.Void> clientData,
);

typedef _dart_clang_visitChildren_wrap = int Function(
  ffi.Pointer<CXCursor> cursor,
  ffi.Pointer<ffi.NativeFunction<visitorFunctionSignature>>
      pointerToVisitorFunc,
  ffi.Pointer<ffi.Void> clientData,
);

///
class CXUnsavedFile extends ffi.Struct {}

///
class CXString extends ffi.Struct {}

///
class CXCursor extends ffi.Struct {
  @ffi.Int32()
  int kind;
}

///
class CXType extends ffi.Struct {
  @ffi.Int32()
  int kind;
}

///
class CXTranslationUnitImpl extends ffi.Struct {}

const int CXTranslationUnit_None = 0x0;

const int CXChildVisit_Break = 0;

const int CXChildVisit_Continue = 1;

const int CXChildVisit_Recurse = 2;

const int CXCursor_FunctionDecl = 8;

const int CXCursor_ParmDecl = 10;

const int CXType_Invalid = 0;

const int CXType_Void = 2;

const int CXType_Int = 17;

const int CXType_FunctionProto = 111;

const int CXType_Pointer = 101;

const int CXType_Float = 21;

const int CXType_Double = 22;
