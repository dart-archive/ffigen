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
class CXCursor extends ffi.Struct {}

///
class CXString extends ffi.Struct {}

///
class CXTranslationUnitImpl extends ffi.Struct {}

///
class CXType extends ffi.Struct {
  @ffi.Int32()
  int kind;
}

///
class CXUnsavedFile extends ffi.Struct {}

/// Free cursor after use,
ffi.Pointer<CXCursor> clang_Cursor_getArgument_wrap(
  ffi.Pointer<CXCursor> cursor,
  int i,
) {
  return _clang_Cursor_getArgument_wrap(
    cursor,
    i,
  );
}

final _dart_clang_Cursor_getArgument_wrap _clang_Cursor_getArgument_wrap =
    _dylib.lookupFunction<_c_clang_Cursor_getArgument_wrap,
        _dart_clang_Cursor_getArgument_wrap>('clang_Cursor_getArgument_wrap');

typedef _c_clang_Cursor_getArgument_wrap = ffi.Pointer<CXCursor> Function(
  ffi.Pointer<CXCursor> cursor,
  ffi.Uint32 i,
);

typedef _dart_clang_Cursor_getArgument_wrap = ffi.Pointer<CXCursor> Function(
  ffi.Pointer<CXCursor> cursor,
  int i,
);

///
ffi.Pointer<CXString> clang_Cursor_getBriefCommentText_wrap(
  ffi.Pointer<CXCursor> cursor,
) {
  return _clang_Cursor_getBriefCommentText_wrap(
    cursor,
  );
}

final _dart_clang_Cursor_getBriefCommentText_wrap
    _clang_Cursor_getBriefCommentText_wrap = _dylib.lookupFunction<
            _c_clang_Cursor_getBriefCommentText_wrap,
            _dart_clang_Cursor_getBriefCommentText_wrap>(
        'clang_Cursor_getBriefCommentText_wrap');

typedef _c_clang_Cursor_getBriefCommentText_wrap = ffi.Pointer<CXString>
    Function(
  ffi.Pointer<CXCursor> cursor,
);

typedef _dart_clang_Cursor_getBriefCommentText_wrap = ffi.Pointer<CXString>
    Function(
  ffi.Pointer<CXCursor> cursor,
);

/// Get Arguments of a function/method, returns -1 for other cursors
///
/// Free cursor after use
int clang_Cursor_getNumArguments_wrap(
  ffi.Pointer<CXCursor> cursor,
) {
  return _clang_Cursor_getNumArguments_wrap(
    cursor,
  );
}

final _dart_clang_Cursor_getNumArguments_wrap
    _clang_Cursor_getNumArguments_wrap = _dylib.lookupFunction<
            _c_clang_Cursor_getNumArguments_wrap,
            _dart_clang_Cursor_getNumArguments_wrap>(
        'clang_Cursor_getNumArguments_wrap');

typedef _c_clang_Cursor_getNumArguments_wrap = ffi.Int32 Function(
  ffi.Pointer<CXCursor> cursor,
);

typedef _dart_clang_Cursor_getNumArguments_wrap = int Function(
  ffi.Pointer<CXCursor> cursor,
);

/// Free cxtype after use
ffi.Pointer<CXType> clang_Type_getNamedType_wrap(
  ffi.Pointer<CXType> elaboratedType,
) {
  return _clang_Type_getNamedType_wrap(
    elaboratedType,
  );
}

final _dart_clang_Type_getNamedType_wrap _clang_Type_getNamedType_wrap =
    _dylib.lookupFunction<_c_clang_Type_getNamedType_wrap,
        _dart_clang_Type_getNamedType_wrap>('clang_Type_getNamedType_wrap');

typedef _c_clang_Type_getNamedType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> elaboratedType,
);

typedef _dart_clang_Type_getNamedType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> elaboratedType,
);

/// Dispose index using [clang_disposeIndex]
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
void clang_disposeDiagnostic(
  ffi.Pointer<ffi.Void> diagnostic,
) {
  return _clang_disposeDiagnostic(
    diagnostic,
  );
}

final _dart_clang_disposeDiagnostic _clang_disposeDiagnostic = _dylib
    .lookupFunction<_c_clang_disposeDiagnostic, _dart_clang_disposeDiagnostic>(
        'clang_disposeDiagnostic');

typedef _c_clang_disposeDiagnostic = ffi.Void Function(
  ffi.Pointer<ffi.Void> diagnostic,
);

typedef _dart_clang_disposeDiagnostic = void Function(
  ffi.Pointer<ffi.Void> diagnostic,
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

/// Free a CXString using this (Do not use free)
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

/// Dispose [CXString] after use using [clang_disposeString_wrap]
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

/// Free cursor after use,
ffi.Pointer<CXType> clang_getArgType_wrap(
  ffi.Pointer<CXType> cxtype,
  int i,
) {
  return _clang_getArgType_wrap(
    cxtype,
    i,
  );
}

final _dart_clang_getArgType_wrap _clang_getArgType_wrap = _dylib
    .lookupFunction<_c_clang_getArgType_wrap, _dart_clang_getArgType_wrap>(
        'clang_getArgType_wrap');

typedef _c_clang_getArgType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> cxtype,
  ffi.Uint32 i,
);

typedef _dart_clang_getArgType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> cxtype,
  int i,
);

/// Dispose [CXString] using [clang_disposeString_wrap], it also frees the CString(const char *), do not free CString directly
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

/// Free cxtype after use
ffi.Pointer<CXType> clang_getCanonicalType_wrap(
  ffi.Pointer<CXType> typerefType,
) {
  return _clang_getCanonicalType_wrap(
    typerefType,
  );
}

final _dart_clang_getCanonicalType_wrap _clang_getCanonicalType_wrap =
    _dylib.lookupFunction<_c_clang_getCanonicalType_wrap,
        _dart_clang_getCanonicalType_wrap>('clang_getCanonicalType_wrap');

typedef _c_clang_getCanonicalType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> typerefType,
);

typedef _dart_clang_getCanonicalType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> typerefType,
);

/// dispose CXString using [clang_disposeString_wrap]
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

/// Free cursor after use
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

/// Free cursor after use, dispose CXString using [clang_disposeString_wrap]
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

/// Free CXType after use
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

/// Dispose diagnostic using [clang_disposeDiagnostic]
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
int clang_getEnumConstantDeclValue_wrap(
  ffi.Pointer<CXCursor> cursor,
) {
  return _clang_getEnumConstantDeclValue_wrap(
    cursor,
  );
}

final _dart_clang_getEnumConstantDeclValue_wrap
    _clang_getEnumConstantDeclValue_wrap = _dylib.lookupFunction<
            _c_clang_getEnumConstantDeclValue_wrap,
            _dart_clang_getEnumConstantDeclValue_wrap>(
        'clang_getEnumConstantDeclValue_wrap');

typedef _c_clang_getEnumConstantDeclValue_wrap = ffi.Int64 Function(
  ffi.Pointer<CXCursor> cursor,
);

typedef _dart_clang_getEnumConstantDeclValue_wrap = int Function(
  ffi.Pointer<CXCursor> cursor,
);

/// Get Arguments of a function type, returns -1 for other cxtypes
///
/// Free cxtype after use
int clang_getNumArgTypes_wrap(
  ffi.Pointer<CXType> cxtype,
) {
  return _clang_getNumArgTypes_wrap(
    cxtype,
  );
}

final _dart_clang_getNumArgTypes_wrap _clang_getNumArgTypes_wrap =
    _dylib.lookupFunction<_c_clang_getNumArgTypes_wrap,
        _dart_clang_getNumArgTypes_wrap>('clang_getNumArgTypes_wrap');

typedef _c_clang_getNumArgTypes_wrap = ffi.Int32 Function(
  ffi.Pointer<CXType> cxtype,
);

typedef _dart_clang_getNumArgTypes_wrap = int Function(
  ffi.Pointer<CXType> cxtype,
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

/// Free cxtype after use
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

/// Free cxtype after use
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

/// Free [CXcursor] after use
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

/// Free cxcursor after use
ffi.Pointer<CXCursor> clang_getTypeDeclaration_wrap(
  ffi.Pointer<CXType> cxtype,
) {
  return _clang_getTypeDeclaration_wrap(
    cxtype,
  );
}

final _dart_clang_getTypeDeclaration_wrap _clang_getTypeDeclaration_wrap =
    _dylib.lookupFunction<_c_clang_getTypeDeclaration_wrap,
        _dart_clang_getTypeDeclaration_wrap>('clang_getTypeDeclaration_wrap');

typedef _c_clang_getTypeDeclaration_wrap = ffi.Pointer<CXCursor> Function(
  ffi.Pointer<CXType> cxtype,
);

typedef _dart_clang_getTypeDeclaration_wrap = ffi.Pointer<CXCursor> Function(
  ffi.Pointer<CXType> cxtype,
);

/// Dispose CXString after use
ffi.Pointer<CXString> clang_getTypeKindSpelling_wrap(
  int typeKind,
) {
  return _clang_getTypeKindSpelling_wrap(
    typeKind,
  );
}

final _dart_clang_getTypeKindSpelling_wrap _clang_getTypeKindSpelling_wrap =
    _dylib.lookupFunction<_c_clang_getTypeKindSpelling_wrap,
        _dart_clang_getTypeKindSpelling_wrap>('clang_getTypeKindSpelling_wrap');

typedef _c_clang_getTypeKindSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Int32 typeKind,
);

typedef _dart_clang_getTypeKindSpelling_wrap = ffi.Pointer<CXString> Function(
  int typeKind,
);

/// Free cxtype after use, dispose CXString using [clang_disposeString_wrap]
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

/// Free cxtype after use
ffi.Pointer<CXType> clang_getTypedefDeclUnderlyingType_wrap(
  ffi.Pointer<CXCursor> typerefType,
) {
  return _clang_getTypedefDeclUnderlyingType_wrap(
    typerefType,
  );
}

final _dart_clang_getTypedefDeclUnderlyingType_wrap
    _clang_getTypedefDeclUnderlyingType_wrap = _dylib.lookupFunction<
            _c_clang_getTypedefDeclUnderlyingType_wrap,
            _dart_clang_getTypedefDeclUnderlyingType_wrap>(
        'clang_getTypedefDeclUnderlyingType_wrap');

typedef _c_clang_getTypedefDeclUnderlyingType_wrap = ffi.Pointer<CXType>
    Function(
  ffi.Pointer<CXCursor> typerefType,
);

typedef _dart_clang_getTypedefDeclUnderlyingType_wrap = ffi.Pointer<CXType>
    Function(
  ffi.Pointer<CXCursor> typerefType,
);

/// Dispose tu using [clang_disposeTranslationUnit]
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

/// Free cursor after use
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

/// C signature for `visitorFunction` parameter in [clang_visitChildren_wrap]
typedef visitorFunctionSignature = ffi.Int32 Function(
  ffi.Pointer<CXCursor> cursor,
  ffi.Pointer<CXCursor> parent,
  ffi.Pointer<ffi.Void> clientData,
);
