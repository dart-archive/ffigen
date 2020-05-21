/// AUTO GENERATED FILE, DO NOT EDIT
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi2;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib) {
  _dylib = dylib;
}

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

ffi.Pointer<ffi2.Utf8> clang_getCString_wrap(
  ffi.Pointer<ffi.Pointer<ffi.Void>> string,
) {
  return _clang_getCString_wrap(
    string,
  );
}

final _dart_clang_getCString_wrap _clang_getCString_wrap = _dylib
    .lookupFunction<_c_clang_getCString_wrap, _dart_clang_getCString_wrap>(
        'clang_getCString_wrap');

typedef _c_clang_getCString_wrap = ffi.Pointer<ffi2.Utf8> Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> string,
);

typedef _dart_clang_getCString_wrap = ffi.Pointer<ffi2.Utf8> Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> string,
);

void clang_disposeString_wrap(
  ffi.Pointer<ffi.Pointer<ffi.Void>> string,
) {
  return _clang_disposeString_wrap(
    string,
  );
}

final _dart_clang_disposeString_wrap _clang_disposeString_wrap =
    _dylib.lookupFunction<_c_clang_disposeString_wrap,
        _dart_clang_disposeString_wrap>('clang_disposeString_wrap');

typedef _c_clang_disposeString_wrap = ffi.Void Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> string,
);

typedef _dart_clang_disposeString_wrap = void Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> string,
);

ffi.Pointer<ffi.Pointer<ffi.Void>> clang_getCursorType_wrap(
  ffi.Pointer<ffi.Pointer<ffi.Void>> cursor,
) {
  return _clang_getCursorType_wrap(
    cursor,
  );
}

final _dart_clang_getCursorType_wrap _clang_getCursorType_wrap =
    _dylib.lookupFunction<_c_clang_getCursorType_wrap,
        _dart_clang_getCursorType_wrap>('clang_getCursorType_wrap');

typedef _c_clang_getCursorType_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> cursor,
);

typedef _dart_clang_getCursorType_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> cursor,
);

ffi.Pointer<ffi.Pointer<ffi.Void>> clang_getTypeSpelling_wrap(
  ffi.Pointer<ffi.Pointer<ffi.Void>> type,
) {
  return _clang_getTypeSpelling_wrap(
    type,
  );
}

final _dart_clang_getTypeSpelling_wrap _clang_getTypeSpelling_wrap =
    _dylib.lookupFunction<_c_clang_getTypeSpelling_wrap,
        _dart_clang_getTypeSpelling_wrap>('clang_getTypeSpelling_wrap');

typedef _c_clang_getTypeSpelling_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> type,
);

typedef _dart_clang_getTypeSpelling_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> type,
);

ffi.Pointer<ffi.Pointer<ffi.Void>> clang_getResultType_wrap(
  ffi.Pointer<ffi.Pointer<ffi.Void>> functionType,
) {
  return _clang_getResultType_wrap(
    functionType,
  );
}

final _dart_clang_getResultType_wrap _clang_getResultType_wrap =
    _dylib.lookupFunction<_c_clang_getResultType_wrap,
        _dart_clang_getResultType_wrap>('clang_getResultType_wrap');

typedef _c_clang_getResultType_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> functionType,
);

typedef _dart_clang_getResultType_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> functionType,
);

ffi.Pointer<ffi.Pointer<ffi.Void>> clang_getPointeeType_wrap(
  ffi.Pointer<ffi.Pointer<ffi.Void>> pointerType,
) {
  return _clang_getPointeeType_wrap(
    pointerType,
  );
}

final _dart_clang_getPointeeType_wrap _clang_getPointeeType_wrap =
    _dylib.lookupFunction<_c_clang_getPointeeType_wrap,
        _dart_clang_getPointeeType_wrap>('clang_getPointeeType_wrap');

typedef _c_clang_getPointeeType_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> pointerType,
);

typedef _dart_clang_getPointeeType_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> pointerType,
);

ffi.Pointer<ffi.Pointer<ffi.Void>> clang_getCursorSpelling_wrap(
  ffi.Pointer<ffi.Pointer<ffi.Void>> cursor,
) {
  return _clang_getCursorSpelling_wrap(
    cursor,
  );
}

final _dart_clang_getCursorSpelling_wrap _clang_getCursorSpelling_wrap =
    _dylib.lookupFunction<_c_clang_getCursorSpelling_wrap,
        _dart_clang_getCursorSpelling_wrap>('clang_getCursorSpelling_wrap');

typedef _c_clang_getCursorSpelling_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> cursor,
);

typedef _dart_clang_getCursorSpelling_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> cursor,
);

ffi.Pointer<ffi.Pointer<ffi.Void>> clang_getTranslationUnitCursor_wrap(
  ffi.Pointer<ffi.Void> tu,
) {
  return _clang_getTranslationUnitCursor_wrap(
    tu,
  );
}

final _dart_clang_getTranslationUnitCursor_wrap
    _clang_getTranslationUnitCursor_wrap = _dylib.lookupFunction<
            _c_clang_getTranslationUnitCursor_wrap,
            _dart_clang_getTranslationUnitCursor_wrap>(
        'clang_getTranslationUnitCursor_wrap');

typedef _c_clang_getTranslationUnitCursor_wrap
    = ffi.Pointer<ffi.Pointer<ffi.Void>> Function(
  ffi.Pointer<ffi.Void> tu,
);

typedef _dart_clang_getTranslationUnitCursor_wrap
    = ffi.Pointer<ffi.Pointer<ffi.Void>> Function(
  ffi.Pointer<ffi.Void> tu,
);

ffi.Pointer<ffi.Pointer<ffi.Void>> clang_formatDiagnostic_wrap(
  ffi.Pointer<ffi.Void> diag,
  int opts,
) {
  return _clang_formatDiagnostic_wrap(
    diag,
    opts,
  );
}

final _dart_clang_formatDiagnostic_wrap _clang_formatDiagnostic_wrap =
    _dylib.lookupFunction<_c_clang_formatDiagnostic_wrap,
        _dart_clang_formatDiagnostic_wrap>('clang_formatDiagnostic_wrap');

typedef _c_clang_formatDiagnostic_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Void> diag,
  ffi.Int32 opts,
);

typedef _dart_clang_formatDiagnostic_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Void> diag,
  int opts,
);

int clang_visitChildren_wrap(
  ffi.Pointer<ffi.Pointer<ffi.Void>> parent,
  ffi.Pointer<ffi.Void> _modifiedVisitor,
  ffi.Pointer<ffi.Void> clientData,
) {
  return _clang_visitChildren_wrap(
    parent,
    _modifiedVisitor,
    clientData,
  );
}

final _dart_clang_visitChildren_wrap _clang_visitChildren_wrap =
    _dylib.lookupFunction<_c_clang_visitChildren_wrap,
        _dart_clang_visitChildren_wrap>('clang_visitChildren_wrap');

typedef _c_clang_visitChildren_wrap = ffi.Uint32 Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> parent,
  ffi.Pointer<ffi.Void> _modifiedVisitor,
  ffi.Pointer<ffi.Void> clientData,
);

typedef _dart_clang_visitChildren_wrap = int Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> parent,
  ffi.Pointer<ffi.Void> _modifiedVisitor,
  ffi.Pointer<ffi.Void> clientData,
);

int clang_Cursor_getNumArguments_wrap(
  ffi.Pointer<ffi.Pointer<ffi.Void>> cursor,
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
  ffi.Pointer<ffi.Pointer<ffi.Void>> cursor,
);

typedef _dart_clang_Cursor_getNumArguments_wrap = int Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> cursor,
);

ffi.Pointer<ffi.Pointer<ffi.Void>> clang_Cursor_getArgument_wrap(
  ffi.Pointer<ffi.Pointer<ffi.Void>> cursor,
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

typedef _c_clang_Cursor_getArgument_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> cursor,
  ffi.Uint32 i,
);

typedef _dart_clang_Cursor_getArgument_wrap = ffi.Pointer<ffi.Pointer<ffi.Void>>
    Function(
  ffi.Pointer<ffi.Pointer<ffi.Void>> cursor,
  int i,
);
