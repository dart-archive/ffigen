/// AUTO GENERATED FILE, DO NOT EDIT
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi2;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib) {
  _dylib = dylib;
}

/// Contains the results of code-completion.
class CXCodeCompleteResults extends ffi.Struct {}

/// A single result of code completion.
class CXCompletionResult extends ffi.Struct {}

/// A cursor representing some element in the abstract syntax tree for a translation unit.
class CXCursor extends ffi.Struct {}

class CXCursorAndRangeVisitor extends ffi.Struct {}

class CXCursorSetImpl extends ffi.Struct {}

/// Uniquely identifies a CXFile, that refers to the same underlying file, across an indexing session.
class CXFileUniqueID extends ffi.Struct {}

class CXGlobalOptFlags {
  static const int CXGlobalOpt_None = 0;
  static const int CXGlobalOpt_ThreadBackgroundPriorityForIndexing = 1;
  static const int CXGlobalOpt_ThreadBackgroundPriorityForEditing = 2;
  static const int CXGlobalOpt_ThreadBackgroundPriorityForAll = 3;
}

class CXIdxAttrInfo extends ffi.Struct {}

class CXIdxBaseClassInfo extends ffi.Struct {}

class CXIdxCXXClassDeclInfo extends ffi.Struct {}

class CXIdxContainerInfo extends ffi.Struct {}

class CXIdxDeclInfo extends ffi.Struct {}

class CXIdxEntityInfo extends ffi.Struct {}

/// Data for IndexerCallbacks#indexEntityReference.
class CXIdxEntityRefInfo extends ffi.Struct {}

class CXIdxIBOutletCollectionAttrInfo extends ffi.Struct {}

/// Data for IndexerCallbacks#importedASTFile.
class CXIdxImportedASTFileInfo extends ffi.Struct {}

/// Data for ppIncludedFile callback.
class CXIdxIncludedFileInfo extends ffi.Struct {}

/// Source location passed to index callbacks.
class CXIdxLoc extends ffi.Struct {}

class CXIdxObjCCategoryDeclInfo extends ffi.Struct {}

class CXIdxObjCContainerDeclInfo extends ffi.Struct {}

class CXIdxObjCInterfaceDeclInfo extends ffi.Struct {}

class CXIdxObjCPropertyDeclInfo extends ffi.Struct {}

class CXIdxObjCProtocolRefInfo extends ffi.Struct {}

class CXIdxObjCProtocolRefListInfo extends ffi.Struct {}

class CXModuleMapDescriptorImpl extends ffi.Struct {}

/// Describes the availability of a given entity on a particular platform, e.g., a particular class might only be available on Mac OS 10.7 or newer.
class CXPlatformAvailability extends ffi.Struct {}

/// Identifies a specific source location within a translation unit.
class CXSourceLocation extends ffi.Struct {}

/// Identifies a half-open character range in the source code.
class CXSourceRange extends ffi.Struct {}

/// Identifies an array of ranges.
class CXSourceRangeList extends ffi.Struct {}

/// A character string.
class CXString extends ffi.Struct {}

class CXStringSet extends ffi.Struct {}

/// The memory usage of a CXTranslationUnit, broken into categories.
class CXTUResourceUsage extends ffi.Struct {}

class CXTUResourceUsageEntry extends ffi.Struct {}

class CXTargetInfoImpl extends ffi.Struct {}

/// Describes a single preprocessing token.
class CXToken extends ffi.Struct {}

class CXTranslationUnitImpl extends ffi.Struct {}

/// The type of an element in the abstract syntax tree.
class CXType extends ffi.Struct {}

class CXTypeKind {
  static const int CXType_Invalid = 0;
  static const int CXType_Unexposed = 1;
  static const int CXType_Void = 2;
  static const int CXType_Bool = 3;
  static const int CXType_Char_U = 4;
  static const int CXType_UChar = 5;
  static const int CXType_Char16 = 6;
  static const int CXType_Char32 = 7;
  static const int CXType_UShort = 8;
  static const int CXType_UInt = 9;
  static const int CXType_ULong = 10;
  static const int CXType_ULongLong = 11;
  static const int CXType_UInt128 = 12;
  static const int CXType_Char_S = 13;
  static const int CXType_SChar = 14;
  static const int CXType_WChar = 15;
  static const int CXType_Short = 16;
  static const int CXType_Int = 17;
  static const int CXType_Long = 18;
  static const int CXType_LongLong = 19;
  static const int CXType_Int128 = 20;
  static const int CXType_Float = 21;
  static const int CXType_Double = 22;
  static const int CXType_LongDouble = 23;
  static const int CXType_NullPtr = 24;
  static const int CXType_Overload = 25;
  static const int CXType_Dependent = 26;
  static const int CXType_ObjCId = 27;
  static const int CXType_ObjCClass = 28;
  static const int CXType_ObjCSel = 29;
  static const int CXType_Float128 = 30;
  static const int CXType_Half = 31;
  static const int CXType_Float16 = 32;
  static const int CXType_ShortAccum = 33;
  static const int CXType_Accum = 34;
  static const int CXType_LongAccum = 35;
  static const int CXType_UShortAccum = 36;
  static const int CXType_UAccum = 37;
  static const int CXType_ULongAccum = 38;
  static const int CXType_FirstBuiltin = 2;
  static const int CXType_LastBuiltin = 38;
  static const int CXType_Complex = 100;
  static const int CXType_Pointer = 101;
  static const int CXType_BlockPointer = 102;
  static const int CXType_LValueReference = 103;
  static const int CXType_RValueReference = 104;
  static const int CXType_Record = 105;
  static const int CXType_Enum = 106;
  static const int CXType_Typedef = 107;
  static const int CXType_ObjCInterface = 108;
  static const int CXType_ObjCObjectPointer = 109;
  static const int CXType_FunctionNoProto = 110;
  static const int CXType_FunctionProto = 111;
  static const int CXType_ConstantArray = 112;
  static const int CXType_Vector = 113;
  static const int CXType_IncompleteArray = 114;
  static const int CXType_VariableArray = 115;
  static const int CXType_DependentSizedArray = 116;
  static const int CXType_MemberPointer = 117;
  static const int CXType_Auto = 118;
  static const int CXType_Elaborated = 119;
  static const int CXType_Pipe = 120;
  static const int CXType_OCLImage1dRO = 121;
  static const int CXType_OCLImage1dArrayRO = 122;
  static const int CXType_OCLImage1dBufferRO = 123;
  static const int CXType_OCLImage2dRO = 124;
  static const int CXType_OCLImage2dArrayRO = 125;
  static const int CXType_OCLImage2dDepthRO = 126;
  static const int CXType_OCLImage2dArrayDepthRO = 127;
  static const int CXType_OCLImage2dMSAARO = 128;
  static const int CXType_OCLImage2dArrayMSAARO = 129;
  static const int CXType_OCLImage2dMSAADepthRO = 130;
  static const int CXType_OCLImage2dArrayMSAADepthRO = 131;
  static const int CXType_OCLImage3dRO = 132;
  static const int CXType_OCLImage1dWO = 133;
  static const int CXType_OCLImage1dArrayWO = 134;
  static const int CXType_OCLImage1dBufferWO = 135;
  static const int CXType_OCLImage2dWO = 136;
  static const int CXType_OCLImage2dArrayWO = 137;
  static const int CXType_OCLImage2dDepthWO = 138;
  static const int CXType_OCLImage2dArrayDepthWO = 139;
  static const int CXType_OCLImage2dMSAAWO = 140;
  static const int CXType_OCLImage2dArrayMSAAWO = 141;
  static const int CXType_OCLImage2dMSAADepthWO = 142;
  static const int CXType_OCLImage2dArrayMSAADepthWO = 143;
  static const int CXType_OCLImage3dWO = 144;
  static const int CXType_OCLImage1dRW = 145;
  static const int CXType_OCLImage1dArrayRW = 146;
  static const int CXType_OCLImage1dBufferRW = 147;
  static const int CXType_OCLImage2dRW = 148;
  static const int CXType_OCLImage2dArrayRW = 149;
  static const int CXType_OCLImage2dDepthRW = 150;
  static const int CXType_OCLImage2dArrayDepthRW = 151;
  static const int CXType_OCLImage2dMSAARW = 152;
  static const int CXType_OCLImage2dArrayMSAARW = 153;
  static const int CXType_OCLImage2dMSAADepthRW = 154;
  static const int CXType_OCLImage2dArrayMSAADepthRW = 155;
  static const int CXType_OCLImage3dRW = 156;
  static const int CXType_OCLSampler = 157;
  static const int CXType_OCLEvent = 158;
  static const int CXType_OCLQueue = 159;
  static const int CXType_OCLReserveID = 160;
  static const int CXType_ObjCObject = 161;
  static const int CXType_ObjCTypeParam = 162;
  static const int CXType_Attributed = 163;
  static const int CXType_OCLIntelSubgroupAVCMcePayload = 164;
  static const int CXType_OCLIntelSubgroupAVCImePayload = 165;
  static const int CXType_OCLIntelSubgroupAVCRefPayload = 166;
  static const int CXType_OCLIntelSubgroupAVCSicPayload = 167;
  static const int CXType_OCLIntelSubgroupAVCMceResult = 168;
  static const int CXType_OCLIntelSubgroupAVCImeResult = 169;
  static const int CXType_OCLIntelSubgroupAVCRefResult = 170;
  static const int CXType_OCLIntelSubgroupAVCSicResult = 171;
  static const int CXType_OCLIntelSubgroupAVCImeResultSingleRefStreamout = 172;
  static const int CXType_OCLIntelSubgroupAVCImeResultDualRefStreamout = 173;
  static const int CXType_OCLIntelSubgroupAVCImeSingleRefStreamin = 174;
  static const int CXType_OCLIntelSubgroupAVCImeDualRefStreamin = 175;
  static const int CXType_ExtVector = 176;
}

/// Provides the contents of a file that has not yet been saved to disk.
class CXUnsavedFile extends ffi.Struct {}

/// Describes a version number of the form major.minor.subminor.
class CXVersion extends ffi.Struct {}

class CXVirtualFileOverlayImpl extends ffi.Struct {}

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

/// Returns the first paragraph of doxygen doc comment
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

void clang_disposeString_wrap(
  ffi.Pointer<CXString> string,
) {
  return _clang_disposeString_wrap(
    string,
  );
}

final _dart_clang_disposeString_wrap _clang_disposeString_wrap =
    _dylib.lookupFunction<_c_clang_disposeString_wrap,
        _dart_clang_disposeString_wrap>('clang_disposeString_wrap');

typedef _c_clang_disposeString_wrap = ffi.Void Function(
  ffi.Pointer<CXString> string,
);

typedef _dart_clang_disposeString_wrap = void Function(
  ffi.Pointer<CXString> string,
);

ffi.Pointer<CXString> clang_formatDiagnostic_wrap(
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

typedef _c_clang_formatDiagnostic_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<ffi.Void> diag,
  ffi.Int32 opts,
);

typedef _dart_clang_formatDiagnostic_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<ffi.Void> diag,
  int opts,
);

ffi.Pointer<ffi2.Utf8> clang_getCString_wrap(
  ffi.Pointer<CXString> string,
) {
  return _clang_getCString_wrap(
    string,
  );
}

final _dart_clang_getCString_wrap _clang_getCString_wrap = _dylib
    .lookupFunction<_c_clang_getCString_wrap, _dart_clang_getCString_wrap>(
        'clang_getCString_wrap');

typedef _c_clang_getCString_wrap = ffi.Pointer<ffi2.Utf8> Function(
  ffi.Pointer<CXString> string,
);

typedef _dart_clang_getCString_wrap = ffi.Pointer<ffi2.Utf8> Function(
  ffi.Pointer<CXString> string,
);

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

/// The name of parameter, struct, typedef
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

ffi.Pointer<CXCursor> clang_getTranslationUnitCursor_wrap(
  ffi.Pointer<CXTranslationUnitImpl> tu,
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

typedef _c_clang_getTranslationUnitCursor_wrap = ffi.Pointer<CXCursor> Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
);

typedef _dart_clang_getTranslationUnitCursor_wrap = ffi.Pointer<CXCursor>
    Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
);

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

ffi.Pointer<CXString> clang_getTypeSpelling_wrap(
  ffi.Pointer<CXType> type,
) {
  return _clang_getTypeSpelling_wrap(
    type,
  );
}

final _dart_clang_getTypeSpelling_wrap _clang_getTypeSpelling_wrap =
    _dylib.lookupFunction<_c_clang_getTypeSpelling_wrap,
        _dart_clang_getTypeSpelling_wrap>('clang_getTypeSpelling_wrap');

typedef _c_clang_getTypeSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<CXType> type,
);

typedef _dart_clang_getTypeSpelling_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<CXType> type,
);

ffi.Pointer<CXType> clang_getTypedefDeclUnderlyingType_wrap(
  ffi.Pointer<CXCursor> cxcursor,
) {
  return _clang_getTypedefDeclUnderlyingType_wrap(
    cxcursor,
  );
}

final _dart_clang_getTypedefDeclUnderlyingType_wrap
    _clang_getTypedefDeclUnderlyingType_wrap = _dylib.lookupFunction<
            _c_clang_getTypedefDeclUnderlyingType_wrap,
            _dart_clang_getTypedefDeclUnderlyingType_wrap>(
        'clang_getTypedefDeclUnderlyingType_wrap');

typedef _c_clang_getTypedefDeclUnderlyingType_wrap = ffi.Pointer<CXType>
    Function(
  ffi.Pointer<CXCursor> cxcursor,
);

typedef _dart_clang_getTypedefDeclUnderlyingType_wrap = ffi.Pointer<CXType>
    Function(
  ffi.Pointer<CXCursor> cxcursor,
);
