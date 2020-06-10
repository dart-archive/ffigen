/// AUTO GENERATED FILE, DO NOT EDIT
import 'dart:ffi' as ffi;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib) {
  _dylib = dylib;
}

/// Contains the results of code-completion.
class CXCodeCompleteResults extends ffi.Struct {
  ffi.Pointer<CXCompletionResult> Results;

  @ffi.Uint32()
  int NumResults;
}

/// A single result of code completion.
class CXCompletionResult extends ffi.Struct {
  @ffi.Int32()
  int CursorKind;

  ffi.Pointer<ffi.Void> CompletionString;
}

/// A cursor representing some element in the abstract syntax tree for a translation unit.
class CXCursor extends ffi.Struct {
  @ffi.Int32()
  int kind;

  @ffi.Int32()
  int xdata;

  ffi.Pointer<ffi.Void> _data_item_0;
  ffi.Pointer<ffi.Void> _data_item_1;
  ffi.Pointer<ffi.Void> _data_item_2;

  /// helper for array, supports `[]` operator
  _ArrayHelper_CXCursor_data get data => _ArrayHelper_CXCursor_data(this, 3);
}

/// Helper for array data in struct CXCursor
class _ArrayHelper_CXCursor_data {
  final CXCursor _struct;
  final int length;
  _ArrayHelper_CXCursor_data(this._struct, this.length);
  void operator []=(int index, ffi.Pointer<ffi.Void> value) {
    switch (index) {
      case 0:
        _struct._data_item_0 = value;
        break;
      case 1:
        _struct._data_item_1 = value;
        break;
      case 2:
        _struct._data_item_2 = value;
        break;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  ffi.Pointer<ffi.Void> operator [](int index) {
    switch (index) {
      case 0:
        return _struct._data_item_0;
      case 1:
        return _struct._data_item_1;
      case 2:
        return _struct._data_item_2;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  @override
  String toString() {
    if (length == 0) return '[]';
    var sb = StringBuffer('[');
    sb.write(this[0]);
    for (var i = 1; i < length; i++) {
      sb.write(',');
      sb.write(this[i]);
    }
    sb.write(']');
    return sb.toString();
  }
}

class CXCursorAndRangeVisitor extends ffi.Struct {
  ffi.Pointer<ffi.Void> context;

  ffi.Pointer<ffi.NativeFunction<_typedefC_noname_2>> visit;
}

class CXCursorSetImpl extends ffi.Struct {}

/// Uniquely identifies a CXFile, that refers to the same underlying file, across an indexing session.
class CXFileUniqueID extends ffi.Struct {
  @ffi.Uint64()
  int _data_item_0;
  @ffi.Uint64()
  int _data_item_1;
  @ffi.Uint64()
  int _data_item_2;

  /// helper for array, supports `[]` operator
  _ArrayHelper_CXFileUniqueID_data get data =>
      _ArrayHelper_CXFileUniqueID_data(this, 3);
}

/// Helper for array data in struct CXFileUniqueID
class _ArrayHelper_CXFileUniqueID_data {
  final CXFileUniqueID _struct;
  final int length;
  _ArrayHelper_CXFileUniqueID_data(this._struct, this.length);
  void operator []=(int index, int value) {
    switch (index) {
      case 0:
        _struct._data_item_0 = value;
        break;
      case 1:
        _struct._data_item_1 = value;
        break;
      case 2:
        _struct._data_item_2 = value;
        break;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  int operator [](int index) {
    switch (index) {
      case 0:
        return _struct._data_item_0;
      case 1:
        return _struct._data_item_1;
      case 2:
        return _struct._data_item_2;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  @override
  String toString() {
    if (length == 0) return '[]';
    var sb = StringBuffer('[');
    sb.write(this[0]);
    for (var i = 1; i < length; i++) {
      sb.write(',');
      sb.write(this[i]);
    }
    sb.write(']');
    return sb.toString();
  }
}

class CXGlobalOptFlags {
  static const int CXGlobalOpt_None = 0;
  static const int CXGlobalOpt_ThreadBackgroundPriorityForIndexing = 1;
  static const int CXGlobalOpt_ThreadBackgroundPriorityForEditing = 2;
  static const int CXGlobalOpt_ThreadBackgroundPriorityForAll = 3;
}

class CXIdxAttrInfo extends ffi.Struct {}

class CXIdxBaseClassInfo extends ffi.Struct {}

class CXIdxCXXClassDeclInfo extends ffi.Struct {
  ffi.Pointer<CXIdxDeclInfo> declInfo;

  ffi.Pointer<ffi.Pointer<CXIdxBaseClassInfo>> bases;

  @ffi.Uint32()
  int numBases;
}

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
class CXIdxLoc extends ffi.Struct {
  ffi.Pointer<ffi.Void> _ptr_data_item_0;
  ffi.Pointer<ffi.Void> _ptr_data_item_1;
  ffi.Pointer<ffi.Void> _ptr_data_item_2;

  /// helper for array, supports `[]` operator
  _ArrayHelper_CXIdxLoc_ptr_data get ptr_data =>
      _ArrayHelper_CXIdxLoc_ptr_data(this, 3);
  @ffi.Uint32()
  int int_data;
}

/// Helper for array ptr_data in struct CXIdxLoc
class _ArrayHelper_CXIdxLoc_ptr_data {
  final CXIdxLoc _struct;
  final int length;
  _ArrayHelper_CXIdxLoc_ptr_data(this._struct, this.length);
  void operator []=(int index, ffi.Pointer<ffi.Void> value) {
    switch (index) {
      case 0:
        _struct._ptr_data_item_0 = value;
        break;
      case 1:
        _struct._ptr_data_item_1 = value;
        break;
      case 2:
        _struct._ptr_data_item_2 = value;
        break;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  ffi.Pointer<ffi.Void> operator [](int index) {
    switch (index) {
      case 0:
        return _struct._ptr_data_item_0;
      case 1:
        return _struct._ptr_data_item_1;
      case 2:
        return _struct._ptr_data_item_2;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  @override
  String toString() {
    if (length == 0) return '[]';
    var sb = StringBuffer('[');
    sb.write(this[0]);
    for (var i = 1; i < length; i++) {
      sb.write(',');
      sb.write(this[i]);
    }
    sb.write(']');
    return sb.toString();
  }
}

class CXIdxObjCCategoryDeclInfo extends ffi.Struct {}

class CXIdxObjCContainerDeclInfo extends ffi.Struct {
  ffi.Pointer<CXIdxDeclInfo> declInfo;

  @ffi.Int32()
  int kind;
}

class CXIdxObjCInterfaceDeclInfo extends ffi.Struct {
  ffi.Pointer<CXIdxObjCContainerDeclInfo> containerInfo;

  ffi.Pointer<CXIdxBaseClassInfo> superInfo;

  ffi.Pointer<CXIdxObjCProtocolRefListInfo> protocols;
}

class CXIdxObjCPropertyDeclInfo extends ffi.Struct {
  ffi.Pointer<CXIdxDeclInfo> declInfo;

  ffi.Pointer<CXIdxEntityInfo> getter;

  ffi.Pointer<CXIdxEntityInfo> setter;
}

class CXIdxObjCProtocolRefInfo extends ffi.Struct {}

class CXIdxObjCProtocolRefListInfo extends ffi.Struct {
  ffi.Pointer<ffi.Pointer<CXIdxObjCProtocolRefInfo>> protocols;

  @ffi.Uint32()
  int numProtocols;
}

typedef CXInclusionVisitor = ffi.Void Function(
  ffi.Pointer<ffi.Void>,
  ffi.Pointer<CXSourceLocation>,
  ffi.Uint32,
  ffi.Pointer<ffi.Void>,
);

/// Describes the availability of a given entity on a particular platform, e.g., a particular class might only be available on Mac OS 10.7 or newer.
class CXPlatformAvailability extends ffi.Struct {}

/// Identifies a specific source location within a translation unit.
class CXSourceLocation extends ffi.Struct {
  ffi.Pointer<ffi.Void> _ptr_data_item_0;
  ffi.Pointer<ffi.Void> _ptr_data_item_1;
  ffi.Pointer<ffi.Void> _ptr_data_item_2;

  /// helper for array, supports `[]` operator
  _ArrayHelper_CXSourceLocation_ptr_data get ptr_data =>
      _ArrayHelper_CXSourceLocation_ptr_data(this, 3);
  @ffi.Uint32()
  int int_data;
}

/// Helper for array ptr_data in struct CXSourceLocation
class _ArrayHelper_CXSourceLocation_ptr_data {
  final CXSourceLocation _struct;
  final int length;
  _ArrayHelper_CXSourceLocation_ptr_data(this._struct, this.length);
  void operator []=(int index, ffi.Pointer<ffi.Void> value) {
    switch (index) {
      case 0:
        _struct._ptr_data_item_0 = value;
        break;
      case 1:
        _struct._ptr_data_item_1 = value;
        break;
      case 2:
        _struct._ptr_data_item_2 = value;
        break;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  ffi.Pointer<ffi.Void> operator [](int index) {
    switch (index) {
      case 0:
        return _struct._ptr_data_item_0;
      case 1:
        return _struct._ptr_data_item_1;
      case 2:
        return _struct._ptr_data_item_2;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  @override
  String toString() {
    if (length == 0) return '[]';
    var sb = StringBuffer('[');
    sb.write(this[0]);
    for (var i = 1; i < length; i++) {
      sb.write(',');
      sb.write(this[i]);
    }
    sb.write(']');
    return sb.toString();
  }
}

/// Identifies a half-open character range in the source code.
class CXSourceRange extends ffi.Struct {
  ffi.Pointer<ffi.Void> _ptr_data_item_0;
  ffi.Pointer<ffi.Void> _ptr_data_item_1;
  ffi.Pointer<ffi.Void> _ptr_data_item_2;

  /// helper for array, supports `[]` operator
  _ArrayHelper_CXSourceRange_ptr_data get ptr_data =>
      _ArrayHelper_CXSourceRange_ptr_data(this, 3);
  @ffi.Uint32()
  int begin_int_data;

  @ffi.Uint32()
  int end_int_data;
}

/// Helper for array ptr_data in struct CXSourceRange
class _ArrayHelper_CXSourceRange_ptr_data {
  final CXSourceRange _struct;
  final int length;
  _ArrayHelper_CXSourceRange_ptr_data(this._struct, this.length);
  void operator []=(int index, ffi.Pointer<ffi.Void> value) {
    switch (index) {
      case 0:
        _struct._ptr_data_item_0 = value;
        break;
      case 1:
        _struct._ptr_data_item_1 = value;
        break;
      case 2:
        _struct._ptr_data_item_2 = value;
        break;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  ffi.Pointer<ffi.Void> operator [](int index) {
    switch (index) {
      case 0:
        return _struct._ptr_data_item_0;
      case 1:
        return _struct._ptr_data_item_1;
      case 2:
        return _struct._ptr_data_item_2;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  @override
  String toString() {
    if (length == 0) return '[]';
    var sb = StringBuffer('[');
    sb.write(this[0]);
    for (var i = 1; i < length; i++) {
      sb.write(',');
      sb.write(this[i]);
    }
    sb.write(']');
    return sb.toString();
  }
}

/// Identifies an array of ranges.
class CXSourceRangeList extends ffi.Struct {
  @ffi.Uint32()
  int count;

  ffi.Pointer<CXSourceRange> ranges;
}

/// A character string.
class CXString extends ffi.Struct {
  ffi.Pointer<ffi.Void> data;

  @ffi.Uint32()
  int private_flags;
}

class CXStringSet extends ffi.Struct {
  ffi.Pointer<CXString> Strings;

  @ffi.Uint32()
  int Count;
}

/// The memory usage of a CXTranslationUnit, broken into categories.
class CXTUResourceUsage extends ffi.Struct {
  ffi.Pointer<ffi.Void> data;

  @ffi.Uint32()
  int numEntries;

  ffi.Pointer<CXTUResourceUsageEntry> entries;
}

class CXTUResourceUsageEntry extends ffi.Struct {
  @ffi.Int32()
  int kind;

  @ffi.Uint64()
  int amount;
}

class CXTargetInfoImpl extends ffi.Struct {}

/// Describes a single preprocessing token.
class CXToken extends ffi.Struct {
  @ffi.Uint32()
  int _int_data_item_0;
  @ffi.Uint32()
  int _int_data_item_1;
  @ffi.Uint32()
  int _int_data_item_2;

  /// helper for array, supports `[]` operator
  _ArrayHelper_CXToken_int_data get int_data =>
      _ArrayHelper_CXToken_int_data(this, 3);
  ffi.Pointer<ffi.Void> ptr_data;
}

/// Helper for array int_data in struct CXToken
class _ArrayHelper_CXToken_int_data {
  final CXToken _struct;
  final int length;
  _ArrayHelper_CXToken_int_data(this._struct, this.length);
  void operator []=(int index, int value) {
    switch (index) {
      case 0:
        _struct._int_data_item_0 = value;
        break;
      case 1:
        _struct._int_data_item_1 = value;
        break;
      case 2:
        _struct._int_data_item_2 = value;
        break;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  int operator [](int index) {
    switch (index) {
      case 0:
        return _struct._int_data_item_0;
      case 1:
        return _struct._int_data_item_1;
      case 2:
        return _struct._int_data_item_2;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  @override
  String toString() {
    if (length == 0) return '[]';
    var sb = StringBuffer('[');
    sb.write(this[0]);
    for (var i = 1; i < length; i++) {
      sb.write(',');
      sb.write(this[i]);
    }
    sb.write(']');
    return sb.toString();
  }
}

class CXTranslationUnitImpl extends ffi.Struct {}

/// The type of an element in the abstract syntax tree.
class CXType extends ffi.Struct {
  @ffi.Int32()
  int kind;

  ffi.Pointer<ffi.Void> _data_item_0;
  ffi.Pointer<ffi.Void> _data_item_1;
  ffi.Pointer<ffi.Void> _data_item_2;

  /// helper for array, supports `[]` operator
  _ArrayHelper_CXType_data get data => _ArrayHelper_CXType_data(this, 3);
}

/// Helper for array data in struct CXType
class _ArrayHelper_CXType_data {
  final CXType _struct;
  final int length;
  _ArrayHelper_CXType_data(this._struct, this.length);
  void operator []=(int index, ffi.Pointer<ffi.Void> value) {
    switch (index) {
      case 0:
        _struct._data_item_0 = value;
        break;
      case 1:
        _struct._data_item_1 = value;
        break;
      case 2:
        _struct._data_item_2 = value;
        break;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  ffi.Pointer<ffi.Void> operator [](int index) {
    switch (index) {
      case 0:
        return _struct._data_item_0;
      case 1:
        return _struct._data_item_1;
      case 2:
        return _struct._data_item_2;
      default:
        throw RangeError('Index $index must be in the range [0..2].');
    }
  }

  @override
  String toString() {
    if (length == 0) return '[]';
    var sb = StringBuffer('[');
    sb.write(this[0]);
    for (var i = 1; i < length; i++) {
      sb.write(',');
      sb.write(this[i]);
    }
    sb.write(']');
    return sb.toString();
  }
}

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
class CXUnsavedFile extends ffi.Struct {
  ffi.Pointer<ffi.Int8> Filename;

  ffi.Pointer<ffi.Int8> Contents;

  @ffi.Uint64()
  int Length;
}

/// Describes a version number of the form major.minor.subminor.
class CXVersion extends ffi.Struct {
  @ffi.Int32()
  int Major;

  @ffi.Int32()
  int Minor;

  @ffi.Int32()
  int Subminor;
}

/// A group of callbacks used by #clang_indexSourceFile and #clang_indexTranslationUnit.
class IndexerCallbacks extends ffi.Struct {
  ffi.Pointer<ffi.NativeFunction<_typedefC_noname_3>> abortQuery;

  ffi.Pointer<ffi.NativeFunction<_typedefC_noname_4>> diagnostic;

  ffi.Pointer<ffi.NativeFunction<_typedefC_noname_5>> enteredMainFile;

  ffi.Pointer<ffi.NativeFunction<_typedefC_noname_6>> ppIncludedFile;

  ffi.Pointer<ffi.NativeFunction<_typedefC_noname_7>> importedASTFile;

  ffi.Pointer<ffi.NativeFunction<_typedefC_noname_8>> startedTranslationUnit;

  ffi.Pointer<ffi.NativeFunction<_typedefC_noname_9>> indexDeclaration;

  ffi.Pointer<ffi.NativeFunction<_typedefC_noname_10>> indexEntityReference;
}

typedef ModifiedCXCursorVisitor = ffi.Int32 Function(
  ffi.Pointer<CXCursor>,
  ffi.Pointer<CXCursor>,
  ffi.Pointer<ffi.Void>,
);

typedef _typedefC_noname_1 = ffi.Void Function(
  ffi.Pointer<ffi.Void>,
);

typedef _typedefC_noname_10 = ffi.Void Function(
  ffi.Pointer<ffi.Void>,
  ffi.Pointer<CXIdxEntityRefInfo>,
);

typedef _typedefC_noname_2 = ffi.Int32 Function(
  ffi.Pointer<ffi.Void>,
  CXCursor,
  CXSourceRange,
);

typedef _typedefC_noname_3 = ffi.Int32 Function(
  ffi.Pointer<ffi.Void>,
  ffi.Pointer<ffi.Void>,
);

typedef _typedefC_noname_4 = ffi.Void Function(
  ffi.Pointer<ffi.Void>,
  ffi.Pointer<ffi.Void>,
  ffi.Pointer<ffi.Void>,
);

typedef _typedefC_noname_5 = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void>,
  ffi.Pointer<ffi.Void>,
  ffi.Pointer<ffi.Void>,
);

typedef _typedefC_noname_6 = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void>,
  ffi.Pointer<CXIdxIncludedFileInfo>,
);

typedef _typedefC_noname_7 = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void>,
  ffi.Pointer<CXIdxImportedASTFileInfo>,
);

typedef _typedefC_noname_8 = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void>,
  ffi.Pointer<ffi.Void>,
);

typedef _typedefC_noname_9 = ffi.Void Function(
  ffi.Pointer<ffi.Void>,
  ffi.Pointer<CXIdxDeclInfo>,
);

/// Gets the general options associated with a CXIndex.
int clang_CXIndex_getGlobalOptions(
  ffi.Pointer<ffi.Void> arg0,
) {
  return _clang_CXIndex_getGlobalOptions(
    arg0,
  );
}

final _dart_clang_CXIndex_getGlobalOptions _clang_CXIndex_getGlobalOptions =
    _dylib.lookupFunction<_c_clang_CXIndex_getGlobalOptions,
        _dart_clang_CXIndex_getGlobalOptions>('clang_CXIndex_getGlobalOptions');

typedef _c_clang_CXIndex_getGlobalOptions = ffi.Uint32 Function(
  ffi.Pointer<ffi.Void> arg0,
);

typedef _dart_clang_CXIndex_getGlobalOptions = int Function(
  ffi.Pointer<ffi.Void> arg0,
);

/// Sets general options associated with a CXIndex.
void clang_CXIndex_setGlobalOptions(
  ffi.Pointer<ffi.Void> arg0,
  int options,
) {
  return _clang_CXIndex_setGlobalOptions(
    arg0,
    options,
  );
}

final _dart_clang_CXIndex_setGlobalOptions _clang_CXIndex_setGlobalOptions =
    _dylib.lookupFunction<_c_clang_CXIndex_setGlobalOptions,
        _dart_clang_CXIndex_setGlobalOptions>('clang_CXIndex_setGlobalOptions');

typedef _c_clang_CXIndex_setGlobalOptions = ffi.Void Function(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Uint32 options,
);

typedef _dart_clang_CXIndex_setGlobalOptions = void Function(
  ffi.Pointer<ffi.Void> arg0,
  int options,
);

/// Sets the invocation emission path option in a CXIndex.
void clang_CXIndex_setInvocationEmissionPathOption(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Pointer<ffi.Int8> Path,
) {
  return _clang_CXIndex_setInvocationEmissionPathOption(
    arg0,
    Path,
  );
}

final _dart_clang_CXIndex_setInvocationEmissionPathOption
    _clang_CXIndex_setInvocationEmissionPathOption = _dylib.lookupFunction<
            _c_clang_CXIndex_setInvocationEmissionPathOption,
            _dart_clang_CXIndex_setInvocationEmissionPathOption>(
        'clang_CXIndex_setInvocationEmissionPathOption');

typedef _c_clang_CXIndex_setInvocationEmissionPathOption = ffi.Void Function(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Pointer<ffi.Int8> Path,
);

typedef _dart_clang_CXIndex_setInvocationEmissionPathOption = void Function(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Pointer<ffi.Int8> Path,
);

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

/// Disposes the created Eval memory.
void clang_EvalResult_dispose(
  ffi.Pointer<ffi.Void> E,
) {
  return _clang_EvalResult_dispose(
    E,
  );
}

final _dart_clang_EvalResult_dispose _clang_EvalResult_dispose =
    _dylib.lookupFunction<_c_clang_EvalResult_dispose,
        _dart_clang_EvalResult_dispose>('clang_EvalResult_dispose');

typedef _c_clang_EvalResult_dispose = ffi.Void Function(
  ffi.Pointer<ffi.Void> E,
);

typedef _dart_clang_EvalResult_dispose = void Function(
  ffi.Pointer<ffi.Void> E,
);

/// Returns the evaluation result as double if the kind is double.
double clang_EvalResult_getAsDouble(
  ffi.Pointer<ffi.Void> E,
) {
  return _clang_EvalResult_getAsDouble(
    E,
  );
}

final _dart_clang_EvalResult_getAsDouble _clang_EvalResult_getAsDouble =
    _dylib.lookupFunction<_c_clang_EvalResult_getAsDouble,
        _dart_clang_EvalResult_getAsDouble>('clang_EvalResult_getAsDouble');

typedef _c_clang_EvalResult_getAsDouble = ffi.Double Function(
  ffi.Pointer<ffi.Void> E,
);

typedef _dart_clang_EvalResult_getAsDouble = double Function(
  ffi.Pointer<ffi.Void> E,
);

/// Returns the evaluation result as integer if the kind is Int.
int clang_EvalResult_getAsInt(
  ffi.Pointer<ffi.Void> E,
) {
  return _clang_EvalResult_getAsInt(
    E,
  );
}

final _dart_clang_EvalResult_getAsInt _clang_EvalResult_getAsInt =
    _dylib.lookupFunction<_c_clang_EvalResult_getAsInt,
        _dart_clang_EvalResult_getAsInt>('clang_EvalResult_getAsInt');

typedef _c_clang_EvalResult_getAsInt = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> E,
);

typedef _dart_clang_EvalResult_getAsInt = int Function(
  ffi.Pointer<ffi.Void> E,
);

/// Returns the evaluation result as a long long integer if the kind is Int. This prevents overflows that may happen if the result is returned with clang_EvalResult_getAsInt.
int clang_EvalResult_getAsLongLong(
  ffi.Pointer<ffi.Void> E,
) {
  return _clang_EvalResult_getAsLongLong(
    E,
  );
}

final _dart_clang_EvalResult_getAsLongLong _clang_EvalResult_getAsLongLong =
    _dylib.lookupFunction<_c_clang_EvalResult_getAsLongLong,
        _dart_clang_EvalResult_getAsLongLong>('clang_EvalResult_getAsLongLong');

typedef _c_clang_EvalResult_getAsLongLong = ffi.Int64 Function(
  ffi.Pointer<ffi.Void> E,
);

typedef _dart_clang_EvalResult_getAsLongLong = int Function(
  ffi.Pointer<ffi.Void> E,
);

/// Returns the evaluation result as a constant string if the kind is other than Int or float. User must not free this pointer, instead call clang_EvalResult_dispose on the CXEvalResult returned by clang_Cursor_Evaluate.
ffi.Pointer<ffi.Int8> clang_EvalResult_getAsStr(
  ffi.Pointer<ffi.Void> E,
) {
  return _clang_EvalResult_getAsStr(
    E,
  );
}

final _dart_clang_EvalResult_getAsStr _clang_EvalResult_getAsStr =
    _dylib.lookupFunction<_c_clang_EvalResult_getAsStr,
        _dart_clang_EvalResult_getAsStr>('clang_EvalResult_getAsStr');

typedef _c_clang_EvalResult_getAsStr = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<ffi.Void> E,
);

typedef _dart_clang_EvalResult_getAsStr = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<ffi.Void> E,
);

/// Returns the evaluation result as an unsigned integer if the kind is Int and clang_EvalResult_isUnsignedInt is non-zero.
int clang_EvalResult_getAsUnsigned(
  ffi.Pointer<ffi.Void> E,
) {
  return _clang_EvalResult_getAsUnsigned(
    E,
  );
}

final _dart_clang_EvalResult_getAsUnsigned _clang_EvalResult_getAsUnsigned =
    _dylib.lookupFunction<_c_clang_EvalResult_getAsUnsigned,
        _dart_clang_EvalResult_getAsUnsigned>('clang_EvalResult_getAsUnsigned');

typedef _c_clang_EvalResult_getAsUnsigned = ffi.Uint64 Function(
  ffi.Pointer<ffi.Void> E,
);

typedef _dart_clang_EvalResult_getAsUnsigned = int Function(
  ffi.Pointer<ffi.Void> E,
);

/// Returns the kind of the evaluated result.
int clang_EvalResult_getKind(
  ffi.Pointer<ffi.Void> E,
) {
  return _clang_EvalResult_getKind(
    E,
  );
}

final _dart_clang_EvalResult_getKind _clang_EvalResult_getKind =
    _dylib.lookupFunction<_c_clang_EvalResult_getKind,
        _dart_clang_EvalResult_getKind>('clang_EvalResult_getKind');

typedef _c_clang_EvalResult_getKind = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> E,
);

typedef _dart_clang_EvalResult_getKind = int Function(
  ffi.Pointer<ffi.Void> E,
);

/// Returns a non-zero value if the kind is Int and the evaluation result resulted in an unsigned integer.
int clang_EvalResult_isUnsignedInt(
  ffi.Pointer<ffi.Void> E,
) {
  return _clang_EvalResult_isUnsignedInt(
    E,
  );
}

final _dart_clang_EvalResult_isUnsignedInt _clang_EvalResult_isUnsignedInt =
    _dylib.lookupFunction<_c_clang_EvalResult_isUnsignedInt,
        _dart_clang_EvalResult_isUnsignedInt>('clang_EvalResult_isUnsignedInt');

typedef _c_clang_EvalResult_isUnsignedInt = ffi.Uint32 Function(
  ffi.Pointer<ffi.Void> E,
);

typedef _dart_clang_EvalResult_isUnsignedInt = int Function(
  ffi.Pointer<ffi.Void> E,
);

/// Returns non-zero if the file1 and file2 point to the same file, or they are both NULL.
int clang_File_isEqual(
  ffi.Pointer<ffi.Void> file1,
  ffi.Pointer<ffi.Void> file2,
) {
  return _clang_File_isEqual(
    file1,
    file2,
  );
}

final _dart_clang_File_isEqual _clang_File_isEqual =
    _dylib.lookupFunction<_c_clang_File_isEqual, _dart_clang_File_isEqual>(
        'clang_File_isEqual');

typedef _c_clang_File_isEqual = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> file1,
  ffi.Pointer<ffi.Void> file2,
);

typedef _dart_clang_File_isEqual = int Function(
  ffi.Pointer<ffi.Void> file1,
  ffi.Pointer<ffi.Void> file2,
);

/// An indexing action/session, to be applied to one or multiple translation units.
ffi.Pointer<ffi.Void> clang_IndexAction_create(
  ffi.Pointer<ffi.Void> CIdx,
) {
  return _clang_IndexAction_create(
    CIdx,
  );
}

final _dart_clang_IndexAction_create _clang_IndexAction_create =
    _dylib.lookupFunction<_c_clang_IndexAction_create,
        _dart_clang_IndexAction_create>('clang_IndexAction_create');

typedef _c_clang_IndexAction_create = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void> CIdx,
);

typedef _dart_clang_IndexAction_create = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void> CIdx,
);

/// Destroy the given index action.
void clang_IndexAction_dispose(
  ffi.Pointer<ffi.Void> arg0,
) {
  return _clang_IndexAction_dispose(
    arg0,
  );
}

final _dart_clang_IndexAction_dispose _clang_IndexAction_dispose =
    _dylib.lookupFunction<_c_clang_IndexAction_dispose,
        _dart_clang_IndexAction_dispose>('clang_IndexAction_dispose');

typedef _c_clang_IndexAction_dispose = ffi.Void Function(
  ffi.Pointer<ffi.Void> arg0,
);

typedef _dart_clang_IndexAction_dispose = void Function(
  ffi.Pointer<ffi.Void> arg0,
);

/// Returns the module file where the provided module object came from.
ffi.Pointer<ffi.Void> clang_Module_getASTFile(
  ffi.Pointer<ffi.Void> Module,
) {
  return _clang_Module_getASTFile(
    Module,
  );
}

final _dart_clang_Module_getASTFile _clang_Module_getASTFile = _dylib
    .lookupFunction<_c_clang_Module_getASTFile, _dart_clang_Module_getASTFile>(
        'clang_Module_getASTFile');

typedef _c_clang_Module_getASTFile = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void> Module,
);

typedef _dart_clang_Module_getASTFile = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void> Module,
);

/// Returns the number of top level headers associated with this module.
int clang_Module_getNumTopLevelHeaders(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
  ffi.Pointer<ffi.Void> Module,
) {
  return _clang_Module_getNumTopLevelHeaders(
    arg0,
    Module,
  );
}

final _dart_clang_Module_getNumTopLevelHeaders
    _clang_Module_getNumTopLevelHeaders = _dylib.lookupFunction<
            _c_clang_Module_getNumTopLevelHeaders,
            _dart_clang_Module_getNumTopLevelHeaders>(
        'clang_Module_getNumTopLevelHeaders');

typedef _c_clang_Module_getNumTopLevelHeaders = ffi.Uint32 Function(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
  ffi.Pointer<ffi.Void> Module,
);

typedef _dart_clang_Module_getNumTopLevelHeaders = int Function(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
  ffi.Pointer<ffi.Void> Module,
);

/// Returns the parent of a sub-module or NULL if the given module is top-level, e.g. for 'std.vector' it will return the 'std' module.
ffi.Pointer<ffi.Void> clang_Module_getParent(
  ffi.Pointer<ffi.Void> Module,
) {
  return _clang_Module_getParent(
    Module,
  );
}

final _dart_clang_Module_getParent _clang_Module_getParent = _dylib
    .lookupFunction<_c_clang_Module_getParent, _dart_clang_Module_getParent>(
        'clang_Module_getParent');

typedef _c_clang_Module_getParent = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void> Module,
);

typedef _dart_clang_Module_getParent = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void> Module,
);

/// Returns the specified top level header associated with the module.
ffi.Pointer<ffi.Void> clang_Module_getTopLevelHeader(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
  ffi.Pointer<ffi.Void> Module,
  int Index,
) {
  return _clang_Module_getTopLevelHeader(
    arg0,
    Module,
    Index,
  );
}

final _dart_clang_Module_getTopLevelHeader _clang_Module_getTopLevelHeader =
    _dylib.lookupFunction<_c_clang_Module_getTopLevelHeader,
        _dart_clang_Module_getTopLevelHeader>('clang_Module_getTopLevelHeader');

typedef _c_clang_Module_getTopLevelHeader = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
  ffi.Pointer<ffi.Void> Module,
  ffi.Uint32 Index,
);

typedef _dart_clang_Module_getTopLevelHeader = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
  ffi.Pointer<ffi.Void> Module,
  int Index,
);

/// Returns non-zero if the module is a system one.
int clang_Module_isSystem(
  ffi.Pointer<ffi.Void> Module,
) {
  return _clang_Module_isSystem(
    Module,
  );
}

final _dart_clang_Module_isSystem _clang_Module_isSystem = _dylib
    .lookupFunction<_c_clang_Module_isSystem, _dart_clang_Module_isSystem>(
        'clang_Module_isSystem');

typedef _c_clang_Module_isSystem = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> Module,
);

typedef _dart_clang_Module_isSystem = int Function(
  ffi.Pointer<ffi.Void> Module,
);

/// Release a printing policy.
void clang_PrintingPolicy_dispose(
  ffi.Pointer<ffi.Void> Policy,
) {
  return _clang_PrintingPolicy_dispose(
    Policy,
  );
}

final _dart_clang_PrintingPolicy_dispose _clang_PrintingPolicy_dispose =
    _dylib.lookupFunction<_c_clang_PrintingPolicy_dispose,
        _dart_clang_PrintingPolicy_dispose>('clang_PrintingPolicy_dispose');

typedef _c_clang_PrintingPolicy_dispose = ffi.Void Function(
  ffi.Pointer<ffi.Void> Policy,
);

typedef _dart_clang_PrintingPolicy_dispose = void Function(
  ffi.Pointer<ffi.Void> Policy,
);

/// Get a property value for the given printing policy.
int clang_PrintingPolicy_getProperty(
  ffi.Pointer<ffi.Void> Policy,
  int Property,
) {
  return _clang_PrintingPolicy_getProperty(
    Policy,
    Property,
  );
}

final _dart_clang_PrintingPolicy_getProperty _clang_PrintingPolicy_getProperty =
    _dylib.lookupFunction<_c_clang_PrintingPolicy_getProperty,
            _dart_clang_PrintingPolicy_getProperty>(
        'clang_PrintingPolicy_getProperty');

typedef _c_clang_PrintingPolicy_getProperty = ffi.Uint32 Function(
  ffi.Pointer<ffi.Void> Policy,
  ffi.Int32 Property,
);

typedef _dart_clang_PrintingPolicy_getProperty = int Function(
  ffi.Pointer<ffi.Void> Policy,
  int Property,
);

/// Set a property value for the given printing policy.
void clang_PrintingPolicy_setProperty(
  ffi.Pointer<ffi.Void> Policy,
  int Property,
  int Value,
) {
  return _clang_PrintingPolicy_setProperty(
    Policy,
    Property,
    Value,
  );
}

final _dart_clang_PrintingPolicy_setProperty _clang_PrintingPolicy_setProperty =
    _dylib.lookupFunction<_c_clang_PrintingPolicy_setProperty,
            _dart_clang_PrintingPolicy_setProperty>(
        'clang_PrintingPolicy_setProperty');

typedef _c_clang_PrintingPolicy_setProperty = ffi.Void Function(
  ffi.Pointer<ffi.Void> Policy,
  ffi.Int32 Property,
  ffi.Uint32 Value,
);

typedef _dart_clang_PrintingPolicy_setProperty = void Function(
  ffi.Pointer<ffi.Void> Policy,
  int Property,
  int Value,
);

/// Destroy the CXTargetInfo object.
void clang_TargetInfo_dispose(
  ffi.Pointer<CXTargetInfoImpl> Info,
) {
  return _clang_TargetInfo_dispose(
    Info,
  );
}

final _dart_clang_TargetInfo_dispose _clang_TargetInfo_dispose =
    _dylib.lookupFunction<_c_clang_TargetInfo_dispose,
        _dart_clang_TargetInfo_dispose>('clang_TargetInfo_dispose');

typedef _c_clang_TargetInfo_dispose = ffi.Void Function(
  ffi.Pointer<CXTargetInfoImpl> Info,
);

typedef _dart_clang_TargetInfo_dispose = void Function(
  ffi.Pointer<CXTargetInfoImpl> Info,
);

/// Get the pointer width of the target in bits.
int clang_TargetInfo_getPointerWidth(
  ffi.Pointer<CXTargetInfoImpl> Info,
) {
  return _clang_TargetInfo_getPointerWidth(
    Info,
  );
}

final _dart_clang_TargetInfo_getPointerWidth _clang_TargetInfo_getPointerWidth =
    _dylib.lookupFunction<_c_clang_TargetInfo_getPointerWidth,
            _dart_clang_TargetInfo_getPointerWidth>(
        'clang_TargetInfo_getPointerWidth');

typedef _c_clang_TargetInfo_getPointerWidth = ffi.Int32 Function(
  ffi.Pointer<CXTargetInfoImpl> Info,
);

typedef _dart_clang_TargetInfo_getPointerWidth = int Function(
  ffi.Pointer<CXTargetInfoImpl> Info,
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

/// Annotate the given set of tokens by providing cursors for each token that can be mapped to a specific entity within the abstract syntax tree.
void clang_annotateTokens(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  ffi.Pointer<CXToken> Tokens,
  int NumTokens,
  ffi.Pointer<CXCursor> Cursors,
) {
  return _clang_annotateTokens(
    TU,
    Tokens,
    NumTokens,
    Cursors,
  );
}

final _dart_clang_annotateTokens _clang_annotateTokens =
    _dylib.lookupFunction<_c_clang_annotateTokens, _dart_clang_annotateTokens>(
        'clang_annotateTokens');

typedef _c_clang_annotateTokens = ffi.Void Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  ffi.Pointer<CXToken> Tokens,
  ffi.Uint32 NumTokens,
  ffi.Pointer<CXCursor> Cursors,
);

typedef _dart_clang_annotateTokens = void Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  ffi.Pointer<CXToken> Tokens,
  int NumTokens,
  ffi.Pointer<CXCursor> Cursors,
);

/// Perform code completion at a given location in a translation unit.
ffi.Pointer<CXCodeCompleteResults> clang_codeCompleteAt(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  ffi.Pointer<ffi.Int8> complete_filename,
  int complete_line,
  int complete_column,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  int options,
) {
  return _clang_codeCompleteAt(
    TU,
    complete_filename,
    complete_line,
    complete_column,
    unsaved_files,
    num_unsaved_files,
    options,
  );
}

final _dart_clang_codeCompleteAt _clang_codeCompleteAt =
    _dylib.lookupFunction<_c_clang_codeCompleteAt, _dart_clang_codeCompleteAt>(
        'clang_codeCompleteAt');

typedef _c_clang_codeCompleteAt = ffi.Pointer<CXCodeCompleteResults> Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  ffi.Pointer<ffi.Int8> complete_filename,
  ffi.Uint32 complete_line,
  ffi.Uint32 complete_column,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  ffi.Uint32 num_unsaved_files,
  ffi.Uint32 options,
);

typedef _dart_clang_codeCompleteAt = ffi.Pointer<CXCodeCompleteResults>
    Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  ffi.Pointer<ffi.Int8> complete_filename,
  int complete_line,
  int complete_column,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  int options,
);

/// Returns the cursor kind for the container for the current code completion context. The container is only guaranteed to be set for contexts where a container exists (i.e. member accesses or Objective-C message sends); if there is not a container, this function will return CXCursor_InvalidCode.
int clang_codeCompleteGetContainerKind(
  ffi.Pointer<CXCodeCompleteResults> Results,
  ffi.Pointer<ffi.Uint32> IsIncomplete,
) {
  return _clang_codeCompleteGetContainerKind(
    Results,
    IsIncomplete,
  );
}

final _dart_clang_codeCompleteGetContainerKind
    _clang_codeCompleteGetContainerKind = _dylib.lookupFunction<
            _c_clang_codeCompleteGetContainerKind,
            _dart_clang_codeCompleteGetContainerKind>(
        'clang_codeCompleteGetContainerKind');

typedef _c_clang_codeCompleteGetContainerKind = ffi.Int32 Function(
  ffi.Pointer<CXCodeCompleteResults> Results,
  ffi.Pointer<ffi.Uint32> IsIncomplete,
);

typedef _dart_clang_codeCompleteGetContainerKind = int Function(
  ffi.Pointer<CXCodeCompleteResults> Results,
  ffi.Pointer<ffi.Uint32> IsIncomplete,
);

/// Determines what completions are appropriate for the context the given code completion.
int clang_codeCompleteGetContexts(
  ffi.Pointer<CXCodeCompleteResults> Results,
) {
  return _clang_codeCompleteGetContexts(
    Results,
  );
}

final _dart_clang_codeCompleteGetContexts _clang_codeCompleteGetContexts =
    _dylib.lookupFunction<_c_clang_codeCompleteGetContexts,
        _dart_clang_codeCompleteGetContexts>('clang_codeCompleteGetContexts');

typedef _c_clang_codeCompleteGetContexts = ffi.Uint64 Function(
  ffi.Pointer<CXCodeCompleteResults> Results,
);

typedef _dart_clang_codeCompleteGetContexts = int Function(
  ffi.Pointer<CXCodeCompleteResults> Results,
);

/// Retrieve a diagnostic associated with the given code completion.
ffi.Pointer<ffi.Void> clang_codeCompleteGetDiagnostic(
  ffi.Pointer<CXCodeCompleteResults> Results,
  int Index,
) {
  return _clang_codeCompleteGetDiagnostic(
    Results,
    Index,
  );
}

final _dart_clang_codeCompleteGetDiagnostic _clang_codeCompleteGetDiagnostic =
    _dylib.lookupFunction<_c_clang_codeCompleteGetDiagnostic,
            _dart_clang_codeCompleteGetDiagnostic>(
        'clang_codeCompleteGetDiagnostic');

typedef _c_clang_codeCompleteGetDiagnostic = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXCodeCompleteResults> Results,
  ffi.Uint32 Index,
);

typedef _dart_clang_codeCompleteGetDiagnostic = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXCodeCompleteResults> Results,
  int Index,
);

/// Determine the number of diagnostics produced prior to the location where code completion was performed.
int clang_codeCompleteGetNumDiagnostics(
  ffi.Pointer<CXCodeCompleteResults> Results,
) {
  return _clang_codeCompleteGetNumDiagnostics(
    Results,
  );
}

final _dart_clang_codeCompleteGetNumDiagnostics
    _clang_codeCompleteGetNumDiagnostics = _dylib.lookupFunction<
            _c_clang_codeCompleteGetNumDiagnostics,
            _dart_clang_codeCompleteGetNumDiagnostics>(
        'clang_codeCompleteGetNumDiagnostics');

typedef _c_clang_codeCompleteGetNumDiagnostics = ffi.Uint32 Function(
  ffi.Pointer<CXCodeCompleteResults> Results,
);

typedef _dart_clang_codeCompleteGetNumDiagnostics = int Function(
  ffi.Pointer<CXCodeCompleteResults> Results,
);

/// Creates an empty CXCursorSet.
ffi.Pointer<CXCursorSetImpl> clang_createCXCursorSet() {
  return _clang_createCXCursorSet();
}

final _dart_clang_createCXCursorSet _clang_createCXCursorSet = _dylib
    .lookupFunction<_c_clang_createCXCursorSet, _dart_clang_createCXCursorSet>(
        'clang_createCXCursorSet');

typedef _c_clang_createCXCursorSet = ffi.Pointer<CXCursorSetImpl> Function();

typedef _dart_clang_createCXCursorSet = ffi.Pointer<CXCursorSetImpl> Function();

/// Provides a shared context for creating translation units.
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

/// Same as clang_createTranslationUnit2, but returns the CXTranslationUnit instead of an error code. In case of an error this routine returns a NULL CXTranslationUnit, without further detailed error codes.
ffi.Pointer<CXTranslationUnitImpl> clang_createTranslationUnit(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> ast_filename,
) {
  return _clang_createTranslationUnit(
    CIdx,
    ast_filename,
  );
}

final _dart_clang_createTranslationUnit _clang_createTranslationUnit =
    _dylib.lookupFunction<_c_clang_createTranslationUnit,
        _dart_clang_createTranslationUnit>('clang_createTranslationUnit');

typedef _c_clang_createTranslationUnit = ffi.Pointer<CXTranslationUnitImpl>
    Function(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> ast_filename,
);

typedef _dart_clang_createTranslationUnit = ffi.Pointer<CXTranslationUnitImpl>
    Function(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> ast_filename,
);

/// Create a translation unit from an AST file ( -emit-ast).
int clang_createTranslationUnit2(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> ast_filename,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
) {
  return _clang_createTranslationUnit2(
    CIdx,
    ast_filename,
    out_TU,
  );
}

final _dart_clang_createTranslationUnit2 _clang_createTranslationUnit2 =
    _dylib.lookupFunction<_c_clang_createTranslationUnit2,
        _dart_clang_createTranslationUnit2>('clang_createTranslationUnit2');

typedef _c_clang_createTranslationUnit2 = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> ast_filename,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
);

typedef _dart_clang_createTranslationUnit2 = int Function(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> ast_filename,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
);

/// Return the CXTranslationUnit for a given source file and the provided command line arguments one would pass to the compiler.
ffi.Pointer<CXTranslationUnitImpl> clang_createTranslationUnitFromSourceFile(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> source_filename,
  int num_clang_command_line_args,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> clang_command_line_args,
  int num_unsaved_files,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
) {
  return _clang_createTranslationUnitFromSourceFile(
    CIdx,
    source_filename,
    num_clang_command_line_args,
    clang_command_line_args,
    num_unsaved_files,
    unsaved_files,
  );
}

final _dart_clang_createTranslationUnitFromSourceFile
    _clang_createTranslationUnitFromSourceFile = _dylib.lookupFunction<
            _c_clang_createTranslationUnitFromSourceFile,
            _dart_clang_createTranslationUnitFromSourceFile>(
        'clang_createTranslationUnitFromSourceFile');

typedef _c_clang_createTranslationUnitFromSourceFile
    = ffi.Pointer<CXTranslationUnitImpl> Function(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Int32 num_clang_command_line_args,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> clang_command_line_args,
  ffi.Uint32 num_unsaved_files,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
);

typedef _dart_clang_createTranslationUnitFromSourceFile
    = ffi.Pointer<CXTranslationUnitImpl> Function(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> source_filename,
  int num_clang_command_line_args,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> clang_command_line_args,
  int num_unsaved_files,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
);

/// Returns a default set of code-completion options that can be passed to clang_codeCompleteAt().
int clang_defaultCodeCompleteOptions() {
  return _clang_defaultCodeCompleteOptions();
}

final _dart_clang_defaultCodeCompleteOptions _clang_defaultCodeCompleteOptions =
    _dylib.lookupFunction<_c_clang_defaultCodeCompleteOptions,
            _dart_clang_defaultCodeCompleteOptions>(
        'clang_defaultCodeCompleteOptions');

typedef _c_clang_defaultCodeCompleteOptions = ffi.Uint32 Function();

typedef _dart_clang_defaultCodeCompleteOptions = int Function();

/// Retrieve the set of display options most similar to the default behavior of the clang compiler.
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

/// Returns the set of flags that is suitable for parsing a translation unit that is being edited.
int clang_defaultEditingTranslationUnitOptions() {
  return _clang_defaultEditingTranslationUnitOptions();
}

final _dart_clang_defaultEditingTranslationUnitOptions
    _clang_defaultEditingTranslationUnitOptions = _dylib.lookupFunction<
            _c_clang_defaultEditingTranslationUnitOptions,
            _dart_clang_defaultEditingTranslationUnitOptions>(
        'clang_defaultEditingTranslationUnitOptions');

typedef _c_clang_defaultEditingTranslationUnitOptions = ffi.Uint32 Function();

typedef _dart_clang_defaultEditingTranslationUnitOptions = int Function();

/// Returns the set of flags that is suitable for reparsing a translation unit.
int clang_defaultReparseOptions(
  ffi.Pointer<CXTranslationUnitImpl> TU,
) {
  return _clang_defaultReparseOptions(
    TU,
  );
}

final _dart_clang_defaultReparseOptions _clang_defaultReparseOptions =
    _dylib.lookupFunction<_c_clang_defaultReparseOptions,
        _dart_clang_defaultReparseOptions>('clang_defaultReparseOptions');

typedef _c_clang_defaultReparseOptions = ffi.Uint32 Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
);

typedef _dart_clang_defaultReparseOptions = int Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
);

/// Returns the set of flags that is suitable for saving a translation unit.
int clang_defaultSaveOptions(
  ffi.Pointer<CXTranslationUnitImpl> TU,
) {
  return _clang_defaultSaveOptions(
    TU,
  );
}

final _dart_clang_defaultSaveOptions _clang_defaultSaveOptions =
    _dylib.lookupFunction<_c_clang_defaultSaveOptions,
        _dart_clang_defaultSaveOptions>('clang_defaultSaveOptions');

typedef _c_clang_defaultSaveOptions = ffi.Uint32 Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
);

typedef _dart_clang_defaultSaveOptions = int Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
);

/// Disposes a CXCursorSet and releases its associated memory.
void clang_disposeCXCursorSet(
  ffi.Pointer<CXCursorSetImpl> cset,
) {
  return _clang_disposeCXCursorSet(
    cset,
  );
}

final _dart_clang_disposeCXCursorSet _clang_disposeCXCursorSet =
    _dylib.lookupFunction<_c_clang_disposeCXCursorSet,
        _dart_clang_disposeCXCursorSet>('clang_disposeCXCursorSet');

typedef _c_clang_disposeCXCursorSet = ffi.Void Function(
  ffi.Pointer<CXCursorSetImpl> cset,
);

typedef _dart_clang_disposeCXCursorSet = void Function(
  ffi.Pointer<CXCursorSetImpl> cset,
);

/// Free the memory associated with a CXPlatformAvailability structure.
void clang_disposeCXPlatformAvailability(
  ffi.Pointer<CXPlatformAvailability> availability,
) {
  return _clang_disposeCXPlatformAvailability(
    availability,
  );
}

final _dart_clang_disposeCXPlatformAvailability
    _clang_disposeCXPlatformAvailability = _dylib.lookupFunction<
            _c_clang_disposeCXPlatformAvailability,
            _dart_clang_disposeCXPlatformAvailability>(
        'clang_disposeCXPlatformAvailability');

typedef _c_clang_disposeCXPlatformAvailability = ffi.Void Function(
  ffi.Pointer<CXPlatformAvailability> availability,
);

typedef _dart_clang_disposeCXPlatformAvailability = void Function(
  ffi.Pointer<CXPlatformAvailability> availability,
);

/// Free the given set of code-completion results.
void clang_disposeCodeCompleteResults(
  ffi.Pointer<CXCodeCompleteResults> Results,
) {
  return _clang_disposeCodeCompleteResults(
    Results,
  );
}

final _dart_clang_disposeCodeCompleteResults _clang_disposeCodeCompleteResults =
    _dylib.lookupFunction<_c_clang_disposeCodeCompleteResults,
            _dart_clang_disposeCodeCompleteResults>(
        'clang_disposeCodeCompleteResults');

typedef _c_clang_disposeCodeCompleteResults = ffi.Void Function(
  ffi.Pointer<CXCodeCompleteResults> Results,
);

typedef _dart_clang_disposeCodeCompleteResults = void Function(
  ffi.Pointer<CXCodeCompleteResults> Results,
);

/// Destroy a diagnostic.
void clang_disposeDiagnostic(
  ffi.Pointer<ffi.Void> Diagnostic,
) {
  return _clang_disposeDiagnostic(
    Diagnostic,
  );
}

final _dart_clang_disposeDiagnostic _clang_disposeDiagnostic = _dylib
    .lookupFunction<_c_clang_disposeDiagnostic, _dart_clang_disposeDiagnostic>(
        'clang_disposeDiagnostic');

typedef _c_clang_disposeDiagnostic = ffi.Void Function(
  ffi.Pointer<ffi.Void> Diagnostic,
);

typedef _dart_clang_disposeDiagnostic = void Function(
  ffi.Pointer<ffi.Void> Diagnostic,
);

/// Release a CXDiagnosticSet and all of its contained diagnostics.
void clang_disposeDiagnosticSet(
  ffi.Pointer<ffi.Void> Diags,
) {
  return _clang_disposeDiagnosticSet(
    Diags,
  );
}

final _dart_clang_disposeDiagnosticSet _clang_disposeDiagnosticSet =
    _dylib.lookupFunction<_c_clang_disposeDiagnosticSet,
        _dart_clang_disposeDiagnosticSet>('clang_disposeDiagnosticSet');

typedef _c_clang_disposeDiagnosticSet = ffi.Void Function(
  ffi.Pointer<ffi.Void> Diags,
);

typedef _dart_clang_disposeDiagnosticSet = void Function(
  ffi.Pointer<ffi.Void> Diags,
);

/// Destroy the given index.
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

/// Free the set of overridden cursors returned by clang_getOverriddenCursors().
void clang_disposeOverriddenCursors(
  ffi.Pointer<CXCursor> overridden,
) {
  return _clang_disposeOverriddenCursors(
    overridden,
  );
}

final _dart_clang_disposeOverriddenCursors _clang_disposeOverriddenCursors =
    _dylib.lookupFunction<_c_clang_disposeOverriddenCursors,
        _dart_clang_disposeOverriddenCursors>('clang_disposeOverriddenCursors');

typedef _c_clang_disposeOverriddenCursors = ffi.Void Function(
  ffi.Pointer<CXCursor> overridden,
);

typedef _dart_clang_disposeOverriddenCursors = void Function(
  ffi.Pointer<CXCursor> overridden,
);

/// Destroy the given CXSourceRangeList.
void clang_disposeSourceRangeList(
  ffi.Pointer<CXSourceRangeList> ranges,
) {
  return _clang_disposeSourceRangeList(
    ranges,
  );
}

final _dart_clang_disposeSourceRangeList _clang_disposeSourceRangeList =
    _dylib.lookupFunction<_c_clang_disposeSourceRangeList,
        _dart_clang_disposeSourceRangeList>('clang_disposeSourceRangeList');

typedef _c_clang_disposeSourceRangeList = ffi.Void Function(
  ffi.Pointer<CXSourceRangeList> ranges,
);

typedef _dart_clang_disposeSourceRangeList = void Function(
  ffi.Pointer<CXSourceRangeList> ranges,
);

/// Free the given string set.
void clang_disposeStringSet(
  ffi.Pointer<CXStringSet> set,
) {
  return _clang_disposeStringSet(
    set,
  );
}

final _dart_clang_disposeStringSet _clang_disposeStringSet = _dylib
    .lookupFunction<_c_clang_disposeStringSet, _dart_clang_disposeStringSet>(
        'clang_disposeStringSet');

typedef _c_clang_disposeStringSet = ffi.Void Function(
  ffi.Pointer<CXStringSet> set,
);

typedef _dart_clang_disposeStringSet = void Function(
  ffi.Pointer<CXStringSet> set,
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

/// Free the given set of tokens.
void clang_disposeTokens(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  ffi.Pointer<CXToken> Tokens,
  int NumTokens,
) {
  return _clang_disposeTokens(
    TU,
    Tokens,
    NumTokens,
  );
}

final _dart_clang_disposeTokens _clang_disposeTokens =
    _dylib.lookupFunction<_c_clang_disposeTokens, _dart_clang_disposeTokens>(
        'clang_disposeTokens');

typedef _c_clang_disposeTokens = ffi.Void Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  ffi.Pointer<CXToken> Tokens,
  ffi.Uint32 NumTokens,
);

typedef _dart_clang_disposeTokens = void Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  ffi.Pointer<CXToken> Tokens,
  int NumTokens,
);

/// Destroy the specified CXTranslationUnit object.
void clang_disposeTranslationUnit(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
) {
  return _clang_disposeTranslationUnit(
    arg0,
  );
}

final _dart_clang_disposeTranslationUnit _clang_disposeTranslationUnit =
    _dylib.lookupFunction<_c_clang_disposeTranslationUnit,
        _dart_clang_disposeTranslationUnit>('clang_disposeTranslationUnit');

typedef _c_clang_disposeTranslationUnit = ffi.Void Function(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
);

typedef _dart_clang_disposeTranslationUnit = void Function(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
);

void clang_enableStackTraces() {
  return _clang_enableStackTraces();
}

final _dart_clang_enableStackTraces _clang_enableStackTraces = _dylib
    .lookupFunction<_c_clang_enableStackTraces, _dart_clang_enableStackTraces>(
        'clang_enableStackTraces');

typedef _c_clang_enableStackTraces = ffi.Void Function();

typedef _dart_clang_enableStackTraces = void Function();

void clang_executeOnThread(
  ffi.Pointer<ffi.NativeFunction<_typedefC_noname_1>> fn,
  ffi.Pointer<ffi.Void> user_data,
  int stack_size,
) {
  return _clang_executeOnThread(
    fn,
    user_data,
    stack_size,
  );
}

final _dart_clang_executeOnThread _clang_executeOnThread = _dylib
    .lookupFunction<_c_clang_executeOnThread, _dart_clang_executeOnThread>(
        'clang_executeOnThread');

typedef _c_clang_executeOnThread = ffi.Void Function(
  ffi.Pointer<ffi.NativeFunction<_typedefC_noname_1>> fn,
  ffi.Pointer<ffi.Void> user_data,
  ffi.Uint32 stack_size,
);

typedef _dart_clang_executeOnThread = void Function(
  ffi.Pointer<ffi.NativeFunction<_typedefC_noname_1>> fn,
  ffi.Pointer<ffi.Void> user_data,
  int stack_size,
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

/// Retrieve all ranges from all files that were skipped by the preprocessor.
ffi.Pointer<CXSourceRangeList> clang_getAllSkippedRanges(
  ffi.Pointer<CXTranslationUnitImpl> tu,
) {
  return _clang_getAllSkippedRanges(
    tu,
  );
}

final _dart_clang_getAllSkippedRanges _clang_getAllSkippedRanges =
    _dylib.lookupFunction<_c_clang_getAllSkippedRanges,
        _dart_clang_getAllSkippedRanges>('clang_getAllSkippedRanges');

typedef _c_clang_getAllSkippedRanges = ffi.Pointer<CXSourceRangeList> Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
);

typedef _dart_clang_getAllSkippedRanges = ffi.Pointer<CXSourceRangeList>
    Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
);

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

ffi.Pointer<CXType> clang_getArrayElementType_wrap(
  ffi.Pointer<CXType> cxtype,
) {
  return _clang_getArrayElementType_wrap(
    cxtype,
  );
}

final _dart_clang_getArrayElementType_wrap _clang_getArrayElementType_wrap =
    _dylib.lookupFunction<_c_clang_getArrayElementType_wrap,
        _dart_clang_getArrayElementType_wrap>('clang_getArrayElementType_wrap');

typedef _c_clang_getArrayElementType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> cxtype,
);

typedef _dart_clang_getArrayElementType_wrap = ffi.Pointer<CXType> Function(
  ffi.Pointer<CXType> cxtype,
);

ffi.Pointer<ffi.Int8> clang_getCString_wrap(
  ffi.Pointer<CXString> string,
) {
  return _clang_getCString_wrap(
    string,
  );
}

final _dart_clang_getCString_wrap _clang_getCString_wrap = _dylib
    .lookupFunction<_c_clang_getCString_wrap, _dart_clang_getCString_wrap>(
        'clang_getCString_wrap');

typedef _c_clang_getCString_wrap = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<CXString> string,
);

typedef _dart_clang_getCString_wrap = ffi.Pointer<ffi.Int8> Function(
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

/// Retrieve the child diagnostics of a CXDiagnostic.
ffi.Pointer<ffi.Void> clang_getChildDiagnostics(
  ffi.Pointer<ffi.Void> D,
) {
  return _clang_getChildDiagnostics(
    D,
  );
}

final _dart_clang_getChildDiagnostics _clang_getChildDiagnostics =
    _dylib.lookupFunction<_c_clang_getChildDiagnostics,
        _dart_clang_getChildDiagnostics>('clang_getChildDiagnostics');

typedef _c_clang_getChildDiagnostics = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void> D,
);

typedef _dart_clang_getChildDiagnostics = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void> D,
);

/// Determine the availability of the entity that this code-completion string refers to.
int clang_getCompletionAvailability(
  ffi.Pointer<ffi.Void> completion_string,
) {
  return _clang_getCompletionAvailability(
    completion_string,
  );
}

final _dart_clang_getCompletionAvailability _clang_getCompletionAvailability =
    _dylib.lookupFunction<_c_clang_getCompletionAvailability,
            _dart_clang_getCompletionAvailability>(
        'clang_getCompletionAvailability');

typedef _c_clang_getCompletionAvailability = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> completion_string,
);

typedef _dart_clang_getCompletionAvailability = int Function(
  ffi.Pointer<ffi.Void> completion_string,
);

/// Retrieve the completion string associated with a particular chunk within a completion string.
ffi.Pointer<ffi.Void> clang_getCompletionChunkCompletionString(
  ffi.Pointer<ffi.Void> completion_string,
  int chunk_number,
) {
  return _clang_getCompletionChunkCompletionString(
    completion_string,
    chunk_number,
  );
}

final _dart_clang_getCompletionChunkCompletionString
    _clang_getCompletionChunkCompletionString = _dylib.lookupFunction<
            _c_clang_getCompletionChunkCompletionString,
            _dart_clang_getCompletionChunkCompletionString>(
        'clang_getCompletionChunkCompletionString');

typedef _c_clang_getCompletionChunkCompletionString = ffi.Pointer<ffi.Void>
    Function(
  ffi.Pointer<ffi.Void> completion_string,
  ffi.Uint32 chunk_number,
);

typedef _dart_clang_getCompletionChunkCompletionString = ffi.Pointer<ffi.Void>
    Function(
  ffi.Pointer<ffi.Void> completion_string,
  int chunk_number,
);

/// Determine the kind of a particular chunk within a completion string.
int clang_getCompletionChunkKind(
  ffi.Pointer<ffi.Void> completion_string,
  int chunk_number,
) {
  return _clang_getCompletionChunkKind(
    completion_string,
    chunk_number,
  );
}

final _dart_clang_getCompletionChunkKind _clang_getCompletionChunkKind =
    _dylib.lookupFunction<_c_clang_getCompletionChunkKind,
        _dart_clang_getCompletionChunkKind>('clang_getCompletionChunkKind');

typedef _c_clang_getCompletionChunkKind = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> completion_string,
  ffi.Uint32 chunk_number,
);

typedef _dart_clang_getCompletionChunkKind = int Function(
  ffi.Pointer<ffi.Void> completion_string,
  int chunk_number,
);

/// Retrieve the number of annotations associated with the given completion string.
int clang_getCompletionNumAnnotations(
  ffi.Pointer<ffi.Void> completion_string,
) {
  return _clang_getCompletionNumAnnotations(
    completion_string,
  );
}

final _dart_clang_getCompletionNumAnnotations
    _clang_getCompletionNumAnnotations = _dylib.lookupFunction<
            _c_clang_getCompletionNumAnnotations,
            _dart_clang_getCompletionNumAnnotations>(
        'clang_getCompletionNumAnnotations');

typedef _c_clang_getCompletionNumAnnotations = ffi.Uint32 Function(
  ffi.Pointer<ffi.Void> completion_string,
);

typedef _dart_clang_getCompletionNumAnnotations = int Function(
  ffi.Pointer<ffi.Void> completion_string,
);

/// Retrieve the number of fix-its for the given completion index.
int clang_getCompletionNumFixIts(
  ffi.Pointer<CXCodeCompleteResults> results,
  int completion_index,
) {
  return _clang_getCompletionNumFixIts(
    results,
    completion_index,
  );
}

final _dart_clang_getCompletionNumFixIts _clang_getCompletionNumFixIts =
    _dylib.lookupFunction<_c_clang_getCompletionNumFixIts,
        _dart_clang_getCompletionNumFixIts>('clang_getCompletionNumFixIts');

typedef _c_clang_getCompletionNumFixIts = ffi.Uint32 Function(
  ffi.Pointer<CXCodeCompleteResults> results,
  ffi.Uint32 completion_index,
);

typedef _dart_clang_getCompletionNumFixIts = int Function(
  ffi.Pointer<CXCodeCompleteResults> results,
  int completion_index,
);

/// Determine the priority of this code completion.
int clang_getCompletionPriority(
  ffi.Pointer<ffi.Void> completion_string,
) {
  return _clang_getCompletionPriority(
    completion_string,
  );
}

final _dart_clang_getCompletionPriority _clang_getCompletionPriority =
    _dylib.lookupFunction<_c_clang_getCompletionPriority,
        _dart_clang_getCompletionPriority>('clang_getCompletionPriority');

typedef _c_clang_getCompletionPriority = ffi.Uint32 Function(
  ffi.Pointer<ffi.Void> completion_string,
);

typedef _dart_clang_getCompletionPriority = int Function(
  ffi.Pointer<ffi.Void> completion_string,
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

ffi.Pointer<CXSourceLocation> clang_getCursorLocation_wrap(
  ffi.Pointer<CXCursor> cursor,
) {
  return _clang_getCursorLocation_wrap(
    cursor,
  );
}

final _dart_clang_getCursorLocation_wrap _clang_getCursorLocation_wrap =
    _dylib.lookupFunction<_c_clang_getCursorLocation_wrap,
        _dart_clang_getCursorLocation_wrap>('clang_getCursorLocation_wrap');

typedef _c_clang_getCursorLocation_wrap = ffi.Pointer<CXSourceLocation>
    Function(
  ffi.Pointer<CXCursor> cursor,
);

typedef _dart_clang_getCursorLocation_wrap = ffi.Pointer<CXSourceLocation>
    Function(
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

/// Retrieve a diagnostic associated with the given translation unit.
ffi.Pointer<ffi.Void> clang_getDiagnostic(
  ffi.Pointer<CXTranslationUnitImpl> Unit,
  int Index,
) {
  return _clang_getDiagnostic(
    Unit,
    Index,
  );
}

final _dart_clang_getDiagnostic _clang_getDiagnostic =
    _dylib.lookupFunction<_c_clang_getDiagnostic, _dart_clang_getDiagnostic>(
        'clang_getDiagnostic');

typedef _c_clang_getDiagnostic = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXTranslationUnitImpl> Unit,
  ffi.Uint32 Index,
);

typedef _dart_clang_getDiagnostic = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXTranslationUnitImpl> Unit,
  int Index,
);

/// Retrieve the category number for this diagnostic.
int clang_getDiagnosticCategory(
  ffi.Pointer<ffi.Void> arg0,
) {
  return _clang_getDiagnosticCategory(
    arg0,
  );
}

final _dart_clang_getDiagnosticCategory _clang_getDiagnosticCategory =
    _dylib.lookupFunction<_c_clang_getDiagnosticCategory,
        _dart_clang_getDiagnosticCategory>('clang_getDiagnosticCategory');

typedef _c_clang_getDiagnosticCategory = ffi.Uint32 Function(
  ffi.Pointer<ffi.Void> arg0,
);

typedef _dart_clang_getDiagnosticCategory = int Function(
  ffi.Pointer<ffi.Void> arg0,
);

/// Retrieve a diagnostic associated with the given CXDiagnosticSet.
ffi.Pointer<ffi.Void> clang_getDiagnosticInSet(
  ffi.Pointer<ffi.Void> Diags,
  int Index,
) {
  return _clang_getDiagnosticInSet(
    Diags,
    Index,
  );
}

final _dart_clang_getDiagnosticInSet _clang_getDiagnosticInSet =
    _dylib.lookupFunction<_c_clang_getDiagnosticInSet,
        _dart_clang_getDiagnosticInSet>('clang_getDiagnosticInSet');

typedef _c_clang_getDiagnosticInSet = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void> Diags,
  ffi.Uint32 Index,
);

typedef _dart_clang_getDiagnosticInSet = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Void> Diags,
  int Index,
);

/// Determine the number of fix-it hints associated with the given diagnostic.
int clang_getDiagnosticNumFixIts(
  ffi.Pointer<ffi.Void> Diagnostic,
) {
  return _clang_getDiagnosticNumFixIts(
    Diagnostic,
  );
}

final _dart_clang_getDiagnosticNumFixIts _clang_getDiagnosticNumFixIts =
    _dylib.lookupFunction<_c_clang_getDiagnosticNumFixIts,
        _dart_clang_getDiagnosticNumFixIts>('clang_getDiagnosticNumFixIts');

typedef _c_clang_getDiagnosticNumFixIts = ffi.Uint32 Function(
  ffi.Pointer<ffi.Void> Diagnostic,
);

typedef _dart_clang_getDiagnosticNumFixIts = int Function(
  ffi.Pointer<ffi.Void> Diagnostic,
);

/// Determine the number of source ranges associated with the given diagnostic.
int clang_getDiagnosticNumRanges(
  ffi.Pointer<ffi.Void> arg0,
) {
  return _clang_getDiagnosticNumRanges(
    arg0,
  );
}

final _dart_clang_getDiagnosticNumRanges _clang_getDiagnosticNumRanges =
    _dylib.lookupFunction<_c_clang_getDiagnosticNumRanges,
        _dart_clang_getDiagnosticNumRanges>('clang_getDiagnosticNumRanges');

typedef _c_clang_getDiagnosticNumRanges = ffi.Uint32 Function(
  ffi.Pointer<ffi.Void> arg0,
);

typedef _dart_clang_getDiagnosticNumRanges = int Function(
  ffi.Pointer<ffi.Void> arg0,
);

/// Retrieve the complete set of diagnostics associated with a translation unit.
ffi.Pointer<ffi.Void> clang_getDiagnosticSetFromTU(
  ffi.Pointer<CXTranslationUnitImpl> Unit,
) {
  return _clang_getDiagnosticSetFromTU(
    Unit,
  );
}

final _dart_clang_getDiagnosticSetFromTU _clang_getDiagnosticSetFromTU =
    _dylib.lookupFunction<_c_clang_getDiagnosticSetFromTU,
        _dart_clang_getDiagnosticSetFromTU>('clang_getDiagnosticSetFromTU');

typedef _c_clang_getDiagnosticSetFromTU = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXTranslationUnitImpl> Unit,
);

typedef _dart_clang_getDiagnosticSetFromTU = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXTranslationUnitImpl> Unit,
);

/// Determine the severity of the given diagnostic.
int clang_getDiagnosticSeverity(
  ffi.Pointer<ffi.Void> arg0,
) {
  return _clang_getDiagnosticSeverity(
    arg0,
  );
}

final _dart_clang_getDiagnosticSeverity _clang_getDiagnosticSeverity =
    _dylib.lookupFunction<_c_clang_getDiagnosticSeverity,
        _dart_clang_getDiagnosticSeverity>('clang_getDiagnosticSeverity');

typedef _c_clang_getDiagnosticSeverity = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> arg0,
);

typedef _dart_clang_getDiagnosticSeverity = int Function(
  ffi.Pointer<ffi.Void> arg0,
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

/// Retrieve a file handle within the given translation unit.
ffi.Pointer<ffi.Void> clang_getFile(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.Int8> file_name,
) {
  return _clang_getFile(
    tu,
    file_name,
  );
}

final _dart_clang_getFile _clang_getFile = _dylib
    .lookupFunction<_c_clang_getFile, _dart_clang_getFile>('clang_getFile');

typedef _c_clang_getFile = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.Int8> file_name,
);

typedef _dart_clang_getFile = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.Int8> file_name,
);

/// Retrieve the buffer associated with the given file.
ffi.Pointer<ffi.Int8> clang_getFileContents(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.Void> file,
  ffi.Pointer<ffi.Uint64> size,
) {
  return _clang_getFileContents(
    tu,
    file,
    size,
  );
}

final _dart_clang_getFileContents _clang_getFileContents = _dylib
    .lookupFunction<_c_clang_getFileContents, _dart_clang_getFileContents>(
        'clang_getFileContents');

typedef _c_clang_getFileContents = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.Void> file,
  ffi.Pointer<ffi.Uint64> size,
);

typedef _dart_clang_getFileContents = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.Void> file,
  ffi.Pointer<ffi.Uint64> size,
);

void clang_getFileLocation_wrap(
  ffi.Pointer<CXSourceLocation> location,
  ffi.Pointer<ffi.Pointer<ffi.Void>> file,
  ffi.Pointer<ffi.Uint32> line,
  ffi.Pointer<ffi.Uint32> column,
  ffi.Pointer<ffi.Uint32> offset,
) {
  return _clang_getFileLocation_wrap(
    location,
    file,
    line,
    column,
    offset,
  );
}

final _dart_clang_getFileLocation_wrap _clang_getFileLocation_wrap =
    _dylib.lookupFunction<_c_clang_getFileLocation_wrap,
        _dart_clang_getFileLocation_wrap>('clang_getFileLocation_wrap');

typedef _c_clang_getFileLocation_wrap = ffi.Void Function(
  ffi.Pointer<CXSourceLocation> location,
  ffi.Pointer<ffi.Pointer<ffi.Void>> file,
  ffi.Pointer<ffi.Uint32> line,
  ffi.Pointer<ffi.Uint32> column,
  ffi.Pointer<ffi.Uint32> offset,
);

typedef _dart_clang_getFileLocation_wrap = void Function(
  ffi.Pointer<CXSourceLocation> location,
  ffi.Pointer<ffi.Pointer<ffi.Void>> file,
  ffi.Pointer<ffi.Uint32> line,
  ffi.Pointer<ffi.Uint32> column,
  ffi.Pointer<ffi.Uint32> offset,
);

ffi.Pointer<CXString> clang_getFileName_wrap(
  ffi.Pointer<ffi.Void> SFile,
) {
  return _clang_getFileName_wrap(
    SFile,
  );
}

final _dart_clang_getFileName_wrap _clang_getFileName_wrap = _dylib
    .lookupFunction<_c_clang_getFileName_wrap, _dart_clang_getFileName_wrap>(
        'clang_getFileName_wrap');

typedef _c_clang_getFileName_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<ffi.Void> SFile,
);

typedef _dart_clang_getFileName_wrap = ffi.Pointer<CXString> Function(
  ffi.Pointer<ffi.Void> SFile,
);

/// Retrieve the last modification time of the given file.
int clang_getFileTime(
  ffi.Pointer<ffi.Void> SFile,
) {
  return _clang_getFileTime(
    SFile,
  );
}

final _dart_clang_getFileTime _clang_getFileTime =
    _dylib.lookupFunction<_c_clang_getFileTime, _dart_clang_getFileTime>(
        'clang_getFileTime');

typedef _c_clang_getFileTime = ffi.Int64 Function(
  ffi.Pointer<ffi.Void> SFile,
);

typedef _dart_clang_getFileTime = int Function(
  ffi.Pointer<ffi.Void> SFile,
);

/// Retrieve the unique ID for the given file.
int clang_getFileUniqueID(
  ffi.Pointer<ffi.Void> file,
  ffi.Pointer<CXFileUniqueID> outID,
) {
  return _clang_getFileUniqueID(
    file,
    outID,
  );
}

final _dart_clang_getFileUniqueID _clang_getFileUniqueID = _dylib
    .lookupFunction<_c_clang_getFileUniqueID, _dart_clang_getFileUniqueID>(
        'clang_getFileUniqueID');

typedef _c_clang_getFileUniqueID = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> file,
  ffi.Pointer<CXFileUniqueID> outID,
);

typedef _dart_clang_getFileUniqueID = int Function(
  ffi.Pointer<ffi.Void> file,
  ffi.Pointer<CXFileUniqueID> outID,
);

/// Visit the set of preprocessor inclusions in a translation unit. The visitor function is called with the provided data for every included file. This does not include headers included by the PCH file (unless one is inspecting the inclusions in the PCH file itself).
void clang_getInclusions(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.NativeFunction<CXInclusionVisitor>> visitor,
  ffi.Pointer<ffi.Void> client_data,
) {
  return _clang_getInclusions(
    tu,
    visitor,
    client_data,
  );
}

final _dart_clang_getInclusions _clang_getInclusions =
    _dylib.lookupFunction<_c_clang_getInclusions, _dart_clang_getInclusions>(
        'clang_getInclusions');

typedef _c_clang_getInclusions = ffi.Void Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.NativeFunction<CXInclusionVisitor>> visitor,
  ffi.Pointer<ffi.Void> client_data,
);

typedef _dart_clang_getInclusions = void Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.NativeFunction<CXInclusionVisitor>> visitor,
  ffi.Pointer<ffi.Void> client_data,
);

/// Given a CXFile header file, return the module that contains it, if one exists.
ffi.Pointer<ffi.Void> clang_getModuleForFile(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
  ffi.Pointer<ffi.Void> arg1,
) {
  return _clang_getModuleForFile(
    arg0,
    arg1,
  );
}

final _dart_clang_getModuleForFile _clang_getModuleForFile = _dylib
    .lookupFunction<_c_clang_getModuleForFile, _dart_clang_getModuleForFile>(
        'clang_getModuleForFile');

typedef _c_clang_getModuleForFile = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
  ffi.Pointer<ffi.Void> arg1,
);

typedef _dart_clang_getModuleForFile = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
  ffi.Pointer<ffi.Void> arg1,
);

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

/// Retrieve the number of chunks in the given code-completion string.
int clang_getNumCompletionChunks(
  ffi.Pointer<ffi.Void> completion_string,
) {
  return _clang_getNumCompletionChunks(
    completion_string,
  );
}

final _dart_clang_getNumCompletionChunks _clang_getNumCompletionChunks =
    _dylib.lookupFunction<_c_clang_getNumCompletionChunks,
        _dart_clang_getNumCompletionChunks>('clang_getNumCompletionChunks');

typedef _c_clang_getNumCompletionChunks = ffi.Uint32 Function(
  ffi.Pointer<ffi.Void> completion_string,
);

typedef _dart_clang_getNumCompletionChunks = int Function(
  ffi.Pointer<ffi.Void> completion_string,
);

/// Determine the number of diagnostics produced for the given translation unit.
int clang_getNumDiagnostics(
  ffi.Pointer<CXTranslationUnitImpl> Unit,
) {
  return _clang_getNumDiagnostics(
    Unit,
  );
}

final _dart_clang_getNumDiagnostics _clang_getNumDiagnostics = _dylib
    .lookupFunction<_c_clang_getNumDiagnostics, _dart_clang_getNumDiagnostics>(
        'clang_getNumDiagnostics');

typedef _c_clang_getNumDiagnostics = ffi.Uint32 Function(
  ffi.Pointer<CXTranslationUnitImpl> Unit,
);

typedef _dart_clang_getNumDiagnostics = int Function(
  ffi.Pointer<CXTranslationUnitImpl> Unit,
);

/// Determine the number of diagnostics in a CXDiagnosticSet.
int clang_getNumDiagnosticsInSet(
  ffi.Pointer<ffi.Void> Diags,
) {
  return _clang_getNumDiagnosticsInSet(
    Diags,
  );
}

final _dart_clang_getNumDiagnosticsInSet _clang_getNumDiagnosticsInSet =
    _dylib.lookupFunction<_c_clang_getNumDiagnosticsInSet,
        _dart_clang_getNumDiagnosticsInSet>('clang_getNumDiagnosticsInSet');

typedef _c_clang_getNumDiagnosticsInSet = ffi.Uint32 Function(
  ffi.Pointer<ffi.Void> Diags,
);

typedef _dart_clang_getNumDiagnosticsInSet = int Function(
  ffi.Pointer<ffi.Void> Diags,
);

int clang_getNumElements_wrap(
  ffi.Pointer<CXType> cxtype,
) {
  return _clang_getNumElements_wrap(
    cxtype,
  );
}

final _dart_clang_getNumElements_wrap _clang_getNumElements_wrap =
    _dylib.lookupFunction<_c_clang_getNumElements_wrap,
        _dart_clang_getNumElements_wrap>('clang_getNumElements_wrap');

typedef _c_clang_getNumElements_wrap = ffi.Uint64 Function(
  ffi.Pointer<CXType> cxtype,
);

typedef _dart_clang_getNumElements_wrap = int Function(
  ffi.Pointer<CXType> cxtype,
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

/// Retrieve a remapping.
ffi.Pointer<ffi.Void> clang_getRemappings(
  ffi.Pointer<ffi.Int8> path,
) {
  return _clang_getRemappings(
    path,
  );
}

final _dart_clang_getRemappings _clang_getRemappings =
    _dylib.lookupFunction<_c_clang_getRemappings, _dart_clang_getRemappings>(
        'clang_getRemappings');

typedef _c_clang_getRemappings = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Int8> path,
);

typedef _dart_clang_getRemappings = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Int8> path,
);

/// Retrieve a remapping.
ffi.Pointer<ffi.Void> clang_getRemappingsFromFileList(
  ffi.Pointer<ffi.Pointer<ffi.Int8>> filePaths,
  int numFiles,
) {
  return _clang_getRemappingsFromFileList(
    filePaths,
    numFiles,
  );
}

final _dart_clang_getRemappingsFromFileList _clang_getRemappingsFromFileList =
    _dylib.lookupFunction<_c_clang_getRemappingsFromFileList,
            _dart_clang_getRemappingsFromFileList>(
        'clang_getRemappingsFromFileList');

typedef _c_clang_getRemappingsFromFileList = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Pointer<ffi.Int8>> filePaths,
  ffi.Uint32 numFiles,
);

typedef _dart_clang_getRemappingsFromFileList = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Pointer<ffi.Int8>> filePaths,
  int numFiles,
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

/// Retrieve all ranges that were skipped by the preprocessor.
ffi.Pointer<CXSourceRangeList> clang_getSkippedRanges(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.Void> file,
) {
  return _clang_getSkippedRanges(
    tu,
    file,
  );
}

final _dart_clang_getSkippedRanges _clang_getSkippedRanges = _dylib
    .lookupFunction<_c_clang_getSkippedRanges, _dart_clang_getSkippedRanges>(
        'clang_getSkippedRanges');

typedef _c_clang_getSkippedRanges = ffi.Pointer<CXSourceRangeList> Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.Void> file,
);

typedef _dart_clang_getSkippedRanges = ffi.Pointer<CXSourceRangeList> Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.Void> file,
);

/// Returns the human-readable null-terminated C string that represents the name of the memory category. This string should never be freed.
ffi.Pointer<ffi.Int8> clang_getTUResourceUsageName(
  int kind,
) {
  return _clang_getTUResourceUsageName(
    kind,
  );
}

final _dart_clang_getTUResourceUsageName _clang_getTUResourceUsageName =
    _dylib.lookupFunction<_c_clang_getTUResourceUsageName,
        _dart_clang_getTUResourceUsageName>('clang_getTUResourceUsageName');

typedef _c_clang_getTUResourceUsageName = ffi.Pointer<ffi.Int8> Function(
  ffi.Int32 kind,
);

typedef _dart_clang_getTUResourceUsageName = ffi.Pointer<ffi.Int8> Function(
  int kind,
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

/// Get target information for this translation unit.
ffi.Pointer<CXTargetInfoImpl> clang_getTranslationUnitTargetInfo(
  ffi.Pointer<CXTranslationUnitImpl> CTUnit,
) {
  return _clang_getTranslationUnitTargetInfo(
    CTUnit,
  );
}

final _dart_clang_getTranslationUnitTargetInfo
    _clang_getTranslationUnitTargetInfo = _dylib.lookupFunction<
            _c_clang_getTranslationUnitTargetInfo,
            _dart_clang_getTranslationUnitTargetInfo>(
        'clang_getTranslationUnitTargetInfo');

typedef _c_clang_getTranslationUnitTargetInfo = ffi.Pointer<CXTargetInfoImpl>
    Function(
  ffi.Pointer<CXTranslationUnitImpl> CTUnit,
);

typedef _dart_clang_getTranslationUnitTargetInfo = ffi.Pointer<CXTargetInfoImpl>
    Function(
  ffi.Pointer<CXTranslationUnitImpl> CTUnit,
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

/// Index the given source file and the translation unit corresponding to that file via callbacks implemented through #IndexerCallbacks.
int clang_indexSourceFile(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Pointer<ffi.Void> client_data,
  ffi.Pointer<IndexerCallbacks> index_callbacks,
  int index_callbacks_size,
  int index_options,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  int num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
  int TU_options,
) {
  return _clang_indexSourceFile(
    arg0,
    client_data,
    index_callbacks,
    index_callbacks_size,
    index_options,
    source_filename,
    command_line_args,
    num_command_line_args,
    unsaved_files,
    num_unsaved_files,
    out_TU,
    TU_options,
  );
}

final _dart_clang_indexSourceFile _clang_indexSourceFile = _dylib
    .lookupFunction<_c_clang_indexSourceFile, _dart_clang_indexSourceFile>(
        'clang_indexSourceFile');

typedef _c_clang_indexSourceFile = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Pointer<ffi.Void> client_data,
  ffi.Pointer<IndexerCallbacks> index_callbacks,
  ffi.Uint32 index_callbacks_size,
  ffi.Uint32 index_options,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  ffi.Int32 num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  ffi.Uint32 num_unsaved_files,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
  ffi.Uint32 TU_options,
);

typedef _dart_clang_indexSourceFile = int Function(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Pointer<ffi.Void> client_data,
  ffi.Pointer<IndexerCallbacks> index_callbacks,
  int index_callbacks_size,
  int index_options,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  int num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
  int TU_options,
);

/// Same as clang_indexSourceFile but requires a full command line for command_line_args including argv[0]. This is useful if the standard library paths are relative to the binary.
int clang_indexSourceFileFullArgv(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Pointer<ffi.Void> client_data,
  ffi.Pointer<IndexerCallbacks> index_callbacks,
  int index_callbacks_size,
  int index_options,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  int num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
  int TU_options,
) {
  return _clang_indexSourceFileFullArgv(
    arg0,
    client_data,
    index_callbacks,
    index_callbacks_size,
    index_options,
    source_filename,
    command_line_args,
    num_command_line_args,
    unsaved_files,
    num_unsaved_files,
    out_TU,
    TU_options,
  );
}

final _dart_clang_indexSourceFileFullArgv _clang_indexSourceFileFullArgv =
    _dylib.lookupFunction<_c_clang_indexSourceFileFullArgv,
        _dart_clang_indexSourceFileFullArgv>('clang_indexSourceFileFullArgv');

typedef _c_clang_indexSourceFileFullArgv = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Pointer<ffi.Void> client_data,
  ffi.Pointer<IndexerCallbacks> index_callbacks,
  ffi.Uint32 index_callbacks_size,
  ffi.Uint32 index_options,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  ffi.Int32 num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  ffi.Uint32 num_unsaved_files,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
  ffi.Uint32 TU_options,
);

typedef _dart_clang_indexSourceFileFullArgv = int Function(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Pointer<ffi.Void> client_data,
  ffi.Pointer<IndexerCallbacks> index_callbacks,
  int index_callbacks_size,
  int index_options,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  int num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
  int TU_options,
);

/// Index the given translation unit via callbacks implemented through #IndexerCallbacks.
int clang_indexTranslationUnit(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Pointer<ffi.Void> client_data,
  ffi.Pointer<IndexerCallbacks> index_callbacks,
  int index_callbacks_size,
  int index_options,
  ffi.Pointer<CXTranslationUnitImpl> arg5,
) {
  return _clang_indexTranslationUnit(
    arg0,
    client_data,
    index_callbacks,
    index_callbacks_size,
    index_options,
    arg5,
  );
}

final _dart_clang_indexTranslationUnit _clang_indexTranslationUnit =
    _dylib.lookupFunction<_c_clang_indexTranslationUnit,
        _dart_clang_indexTranslationUnit>('clang_indexTranslationUnit');

typedef _c_clang_indexTranslationUnit = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Pointer<ffi.Void> client_data,
  ffi.Pointer<IndexerCallbacks> index_callbacks,
  ffi.Uint32 index_callbacks_size,
  ffi.Uint32 index_options,
  ffi.Pointer<CXTranslationUnitImpl> arg5,
);

typedef _dart_clang_indexTranslationUnit = int Function(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Pointer<ffi.Void> client_data,
  ffi.Pointer<IndexerCallbacks> index_callbacks,
  int index_callbacks_size,
  int index_options,
  ffi.Pointer<CXTranslationUnitImpl> arg5,
);

ffi.Pointer<CXIdxCXXClassDeclInfo> clang_index_getCXXClassDeclInfo(
  ffi.Pointer<CXIdxDeclInfo> arg0,
) {
  return _clang_index_getCXXClassDeclInfo(
    arg0,
  );
}

final _dart_clang_index_getCXXClassDeclInfo _clang_index_getCXXClassDeclInfo =
    _dylib.lookupFunction<_c_clang_index_getCXXClassDeclInfo,
            _dart_clang_index_getCXXClassDeclInfo>(
        'clang_index_getCXXClassDeclInfo');

typedef _c_clang_index_getCXXClassDeclInfo = ffi.Pointer<CXIdxCXXClassDeclInfo>
    Function(
  ffi.Pointer<CXIdxDeclInfo> arg0,
);

typedef _dart_clang_index_getCXXClassDeclInfo
    = ffi.Pointer<CXIdxCXXClassDeclInfo> Function(
  ffi.Pointer<CXIdxDeclInfo> arg0,
);

/// For retrieving a custom CXIdxClientContainer attached to a container.
ffi.Pointer<ffi.Void> clang_index_getClientContainer(
  ffi.Pointer<CXIdxContainerInfo> arg0,
) {
  return _clang_index_getClientContainer(
    arg0,
  );
}

final _dart_clang_index_getClientContainer _clang_index_getClientContainer =
    _dylib.lookupFunction<_c_clang_index_getClientContainer,
        _dart_clang_index_getClientContainer>('clang_index_getClientContainer');

typedef _c_clang_index_getClientContainer = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXIdxContainerInfo> arg0,
);

typedef _dart_clang_index_getClientContainer = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXIdxContainerInfo> arg0,
);

/// For retrieving a custom CXIdxClientEntity attached to an entity.
ffi.Pointer<ffi.Void> clang_index_getClientEntity(
  ffi.Pointer<CXIdxEntityInfo> arg0,
) {
  return _clang_index_getClientEntity(
    arg0,
  );
}

final _dart_clang_index_getClientEntity _clang_index_getClientEntity =
    _dylib.lookupFunction<_c_clang_index_getClientEntity,
        _dart_clang_index_getClientEntity>('clang_index_getClientEntity');

typedef _c_clang_index_getClientEntity = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXIdxEntityInfo> arg0,
);

typedef _dart_clang_index_getClientEntity = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<CXIdxEntityInfo> arg0,
);

ffi.Pointer<CXIdxIBOutletCollectionAttrInfo>
    clang_index_getIBOutletCollectionAttrInfo(
  ffi.Pointer<CXIdxAttrInfo> arg0,
) {
  return _clang_index_getIBOutletCollectionAttrInfo(
    arg0,
  );
}

final _dart_clang_index_getIBOutletCollectionAttrInfo
    _clang_index_getIBOutletCollectionAttrInfo = _dylib.lookupFunction<
            _c_clang_index_getIBOutletCollectionAttrInfo,
            _dart_clang_index_getIBOutletCollectionAttrInfo>(
        'clang_index_getIBOutletCollectionAttrInfo');

typedef _c_clang_index_getIBOutletCollectionAttrInfo
    = ffi.Pointer<CXIdxIBOutletCollectionAttrInfo> Function(
  ffi.Pointer<CXIdxAttrInfo> arg0,
);

typedef _dart_clang_index_getIBOutletCollectionAttrInfo
    = ffi.Pointer<CXIdxIBOutletCollectionAttrInfo> Function(
  ffi.Pointer<CXIdxAttrInfo> arg0,
);

ffi.Pointer<CXIdxObjCCategoryDeclInfo> clang_index_getObjCCategoryDeclInfo(
  ffi.Pointer<CXIdxDeclInfo> arg0,
) {
  return _clang_index_getObjCCategoryDeclInfo(
    arg0,
  );
}

final _dart_clang_index_getObjCCategoryDeclInfo
    _clang_index_getObjCCategoryDeclInfo = _dylib.lookupFunction<
            _c_clang_index_getObjCCategoryDeclInfo,
            _dart_clang_index_getObjCCategoryDeclInfo>(
        'clang_index_getObjCCategoryDeclInfo');

typedef _c_clang_index_getObjCCategoryDeclInfo
    = ffi.Pointer<CXIdxObjCCategoryDeclInfo> Function(
  ffi.Pointer<CXIdxDeclInfo> arg0,
);

typedef _dart_clang_index_getObjCCategoryDeclInfo
    = ffi.Pointer<CXIdxObjCCategoryDeclInfo> Function(
  ffi.Pointer<CXIdxDeclInfo> arg0,
);

ffi.Pointer<CXIdxObjCContainerDeclInfo> clang_index_getObjCContainerDeclInfo(
  ffi.Pointer<CXIdxDeclInfo> arg0,
) {
  return _clang_index_getObjCContainerDeclInfo(
    arg0,
  );
}

final _dart_clang_index_getObjCContainerDeclInfo
    _clang_index_getObjCContainerDeclInfo = _dylib.lookupFunction<
            _c_clang_index_getObjCContainerDeclInfo,
            _dart_clang_index_getObjCContainerDeclInfo>(
        'clang_index_getObjCContainerDeclInfo');

typedef _c_clang_index_getObjCContainerDeclInfo
    = ffi.Pointer<CXIdxObjCContainerDeclInfo> Function(
  ffi.Pointer<CXIdxDeclInfo> arg0,
);

typedef _dart_clang_index_getObjCContainerDeclInfo
    = ffi.Pointer<CXIdxObjCContainerDeclInfo> Function(
  ffi.Pointer<CXIdxDeclInfo> arg0,
);

ffi.Pointer<CXIdxObjCInterfaceDeclInfo> clang_index_getObjCInterfaceDeclInfo(
  ffi.Pointer<CXIdxDeclInfo> arg0,
) {
  return _clang_index_getObjCInterfaceDeclInfo(
    arg0,
  );
}

final _dart_clang_index_getObjCInterfaceDeclInfo
    _clang_index_getObjCInterfaceDeclInfo = _dylib.lookupFunction<
            _c_clang_index_getObjCInterfaceDeclInfo,
            _dart_clang_index_getObjCInterfaceDeclInfo>(
        'clang_index_getObjCInterfaceDeclInfo');

typedef _c_clang_index_getObjCInterfaceDeclInfo
    = ffi.Pointer<CXIdxObjCInterfaceDeclInfo> Function(
  ffi.Pointer<CXIdxDeclInfo> arg0,
);

typedef _dart_clang_index_getObjCInterfaceDeclInfo
    = ffi.Pointer<CXIdxObjCInterfaceDeclInfo> Function(
  ffi.Pointer<CXIdxDeclInfo> arg0,
);

ffi.Pointer<CXIdxObjCPropertyDeclInfo> clang_index_getObjCPropertyDeclInfo(
  ffi.Pointer<CXIdxDeclInfo> arg0,
) {
  return _clang_index_getObjCPropertyDeclInfo(
    arg0,
  );
}

final _dart_clang_index_getObjCPropertyDeclInfo
    _clang_index_getObjCPropertyDeclInfo = _dylib.lookupFunction<
            _c_clang_index_getObjCPropertyDeclInfo,
            _dart_clang_index_getObjCPropertyDeclInfo>(
        'clang_index_getObjCPropertyDeclInfo');

typedef _c_clang_index_getObjCPropertyDeclInfo
    = ffi.Pointer<CXIdxObjCPropertyDeclInfo> Function(
  ffi.Pointer<CXIdxDeclInfo> arg0,
);

typedef _dart_clang_index_getObjCPropertyDeclInfo
    = ffi.Pointer<CXIdxObjCPropertyDeclInfo> Function(
  ffi.Pointer<CXIdxDeclInfo> arg0,
);

ffi.Pointer<CXIdxObjCProtocolRefListInfo>
    clang_index_getObjCProtocolRefListInfo(
  ffi.Pointer<CXIdxDeclInfo> arg0,
) {
  return _clang_index_getObjCProtocolRefListInfo(
    arg0,
  );
}

final _dart_clang_index_getObjCProtocolRefListInfo
    _clang_index_getObjCProtocolRefListInfo = _dylib.lookupFunction<
            _c_clang_index_getObjCProtocolRefListInfo,
            _dart_clang_index_getObjCProtocolRefListInfo>(
        'clang_index_getObjCProtocolRefListInfo');

typedef _c_clang_index_getObjCProtocolRefListInfo
    = ffi.Pointer<CXIdxObjCProtocolRefListInfo> Function(
  ffi.Pointer<CXIdxDeclInfo> arg0,
);

typedef _dart_clang_index_getObjCProtocolRefListInfo
    = ffi.Pointer<CXIdxObjCProtocolRefListInfo> Function(
  ffi.Pointer<CXIdxDeclInfo> arg0,
);

int clang_index_isEntityObjCContainerKind(
  int arg0,
) {
  return _clang_index_isEntityObjCContainerKind(
    arg0,
  );
}

final _dart_clang_index_isEntityObjCContainerKind
    _clang_index_isEntityObjCContainerKind = _dylib.lookupFunction<
            _c_clang_index_isEntityObjCContainerKind,
            _dart_clang_index_isEntityObjCContainerKind>(
        'clang_index_isEntityObjCContainerKind');

typedef _c_clang_index_isEntityObjCContainerKind = ffi.Int32 Function(
  ffi.Int32 arg0,
);

typedef _dart_clang_index_isEntityObjCContainerKind = int Function(
  int arg0,
);

/// For setting a custom CXIdxClientContainer attached to a container.
void clang_index_setClientContainer(
  ffi.Pointer<CXIdxContainerInfo> arg0,
  ffi.Pointer<ffi.Void> arg1,
) {
  return _clang_index_setClientContainer(
    arg0,
    arg1,
  );
}

final _dart_clang_index_setClientContainer _clang_index_setClientContainer =
    _dylib.lookupFunction<_c_clang_index_setClientContainer,
        _dart_clang_index_setClientContainer>('clang_index_setClientContainer');

typedef _c_clang_index_setClientContainer = ffi.Void Function(
  ffi.Pointer<CXIdxContainerInfo> arg0,
  ffi.Pointer<ffi.Void> arg1,
);

typedef _dart_clang_index_setClientContainer = void Function(
  ffi.Pointer<CXIdxContainerInfo> arg0,
  ffi.Pointer<ffi.Void> arg1,
);

/// For setting a custom CXIdxClientEntity attached to an entity.
void clang_index_setClientEntity(
  ffi.Pointer<CXIdxEntityInfo> arg0,
  ffi.Pointer<ffi.Void> arg1,
) {
  return _clang_index_setClientEntity(
    arg0,
    arg1,
  );
}

final _dart_clang_index_setClientEntity _clang_index_setClientEntity =
    _dylib.lookupFunction<_c_clang_index_setClientEntity,
        _dart_clang_index_setClientEntity>('clang_index_setClientEntity');

typedef _c_clang_index_setClientEntity = ffi.Void Function(
  ffi.Pointer<CXIdxEntityInfo> arg0,
  ffi.Pointer<ffi.Void> arg1,
);

typedef _dart_clang_index_setClientEntity = void Function(
  ffi.Pointer<CXIdxEntityInfo> arg0,
  ffi.Pointer<ffi.Void> arg1,
);

/// Determine whether the given cursor kind represents an attribute.
int clang_isAttribute(
  int arg0,
) {
  return _clang_isAttribute(
    arg0,
  );
}

final _dart_clang_isAttribute _clang_isAttribute =
    _dylib.lookupFunction<_c_clang_isAttribute, _dart_clang_isAttribute>(
        'clang_isAttribute');

typedef _c_clang_isAttribute = ffi.Uint32 Function(
  ffi.Int32 arg0,
);

typedef _dart_clang_isAttribute = int Function(
  int arg0,
);

/// Determine whether the given cursor kind represents a declaration.
int clang_isDeclaration(
  int arg0,
) {
  return _clang_isDeclaration(
    arg0,
  );
}

final _dart_clang_isDeclaration _clang_isDeclaration =
    _dylib.lookupFunction<_c_clang_isDeclaration, _dart_clang_isDeclaration>(
        'clang_isDeclaration');

typedef _c_clang_isDeclaration = ffi.Uint32 Function(
  ffi.Int32 arg0,
);

typedef _dart_clang_isDeclaration = int Function(
  int arg0,
);

/// Determine whether the given cursor kind represents an expression.
int clang_isExpression(
  int arg0,
) {
  return _clang_isExpression(
    arg0,
  );
}

final _dart_clang_isExpression _clang_isExpression =
    _dylib.lookupFunction<_c_clang_isExpression, _dart_clang_isExpression>(
        'clang_isExpression');

typedef _c_clang_isExpression = ffi.Uint32 Function(
  ffi.Int32 arg0,
);

typedef _dart_clang_isExpression = int Function(
  int arg0,
);

/// Determine whether the given header is guarded against multiple inclusions, either with the conventional #ifndef/#define/#endif macro guards or with #pragma once.
int clang_isFileMultipleIncludeGuarded(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.Void> file,
) {
  return _clang_isFileMultipleIncludeGuarded(
    tu,
    file,
  );
}

final _dart_clang_isFileMultipleIncludeGuarded
    _clang_isFileMultipleIncludeGuarded = _dylib.lookupFunction<
            _c_clang_isFileMultipleIncludeGuarded,
            _dart_clang_isFileMultipleIncludeGuarded>(
        'clang_isFileMultipleIncludeGuarded');

typedef _c_clang_isFileMultipleIncludeGuarded = ffi.Uint32 Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.Void> file,
);

typedef _dart_clang_isFileMultipleIncludeGuarded = int Function(
  ffi.Pointer<CXTranslationUnitImpl> tu,
  ffi.Pointer<ffi.Void> file,
);

/// Determine whether the given cursor kind represents an invalid cursor.
int clang_isInvalid(
  int arg0,
) {
  return _clang_isInvalid(
    arg0,
  );
}

final _dart_clang_isInvalid _clang_isInvalid =
    _dylib.lookupFunction<_c_clang_isInvalid, _dart_clang_isInvalid>(
        'clang_isInvalid');

typedef _c_clang_isInvalid = ffi.Uint32 Function(
  ffi.Int32 arg0,
);

typedef _dart_clang_isInvalid = int Function(
  int arg0,
);

/// * Determine whether the given cursor represents a preprocessing element, such as a preprocessor directive or macro instantiation.
int clang_isPreprocessing(
  int arg0,
) {
  return _clang_isPreprocessing(
    arg0,
  );
}

final _dart_clang_isPreprocessing _clang_isPreprocessing = _dylib
    .lookupFunction<_c_clang_isPreprocessing, _dart_clang_isPreprocessing>(
        'clang_isPreprocessing');

typedef _c_clang_isPreprocessing = ffi.Uint32 Function(
  ffi.Int32 arg0,
);

typedef _dart_clang_isPreprocessing = int Function(
  int arg0,
);

/// Determine whether the given cursor kind represents a simple reference.
int clang_isReference(
  int arg0,
) {
  return _clang_isReference(
    arg0,
  );
}

final _dart_clang_isReference _clang_isReference =
    _dylib.lookupFunction<_c_clang_isReference, _dart_clang_isReference>(
        'clang_isReference');

typedef _c_clang_isReference = ffi.Uint32 Function(
  ffi.Int32 arg0,
);

typedef _dart_clang_isReference = int Function(
  int arg0,
);

/// Determine whether the given cursor kind represents a statement.
int clang_isStatement(
  int arg0,
) {
  return _clang_isStatement(
    arg0,
  );
}

final _dart_clang_isStatement _clang_isStatement =
    _dylib.lookupFunction<_c_clang_isStatement, _dart_clang_isStatement>(
        'clang_isStatement');

typedef _c_clang_isStatement = ffi.Uint32 Function(
  ffi.Int32 arg0,
);

typedef _dart_clang_isStatement = int Function(
  int arg0,
);

/// Determine whether the given cursor kind represents a translation unit.
int clang_isTranslationUnit(
  int arg0,
) {
  return _clang_isTranslationUnit(
    arg0,
  );
}

final _dart_clang_isTranslationUnit _clang_isTranslationUnit = _dylib
    .lookupFunction<_c_clang_isTranslationUnit, _dart_clang_isTranslationUnit>(
        'clang_isTranslationUnit');

typedef _c_clang_isTranslationUnit = ffi.Uint32 Function(
  ffi.Int32 arg0,
);

typedef _dart_clang_isTranslationUnit = int Function(
  int arg0,
);

/// * Determine whether the given cursor represents a currently unexposed piece of the AST (e.g., CXCursor_UnexposedStmt).
int clang_isUnexposed(
  int arg0,
) {
  return _clang_isUnexposed(
    arg0,
  );
}

final _dart_clang_isUnexposed _clang_isUnexposed =
    _dylib.lookupFunction<_c_clang_isUnexposed, _dart_clang_isUnexposed>(
        'clang_isUnexposed');

typedef _c_clang_isUnexposed = ffi.Uint32 Function(
  ffi.Int32 arg0,
);

typedef _dart_clang_isUnexposed = int Function(
  int arg0,
);

/// Deserialize a set of diagnostics from a Clang diagnostics bitcode file.
ffi.Pointer<ffi.Void> clang_loadDiagnostics(
  ffi.Pointer<ffi.Int8> file,
  ffi.Pointer<ffi.Int32> error,
  ffi.Pointer<CXString> errorString,
) {
  return _clang_loadDiagnostics(
    file,
    error,
    errorString,
  );
}

final _dart_clang_loadDiagnostics _clang_loadDiagnostics = _dylib
    .lookupFunction<_c_clang_loadDiagnostics, _dart_clang_loadDiagnostics>(
        'clang_loadDiagnostics');

typedef _c_clang_loadDiagnostics = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Int8> file,
  ffi.Pointer<ffi.Int32> error,
  ffi.Pointer<CXString> errorString,
);

typedef _dart_clang_loadDiagnostics = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<ffi.Int8> file,
  ffi.Pointer<ffi.Int32> error,
  ffi.Pointer<CXString> errorString,
);

/// Same as clang_parseTranslationUnit2, but returns the CXTranslationUnit instead of an error code. In case of an error this routine returns a NULL CXTranslationUnit, without further detailed error codes.
ffi.Pointer<CXTranslationUnitImpl> clang_parseTranslationUnit(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  int num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  int options,
) {
  return _clang_parseTranslationUnit(
    CIdx,
    source_filename,
    command_line_args,
    num_command_line_args,
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
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  ffi.Int32 num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  ffi.Uint32 num_unsaved_files,
  ffi.Uint32 options,
);

typedef _dart_clang_parseTranslationUnit = ffi.Pointer<CXTranslationUnitImpl>
    Function(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  int num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  int options,
);

/// Parse the given source file and the translation unit corresponding to that file.
int clang_parseTranslationUnit2(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  int num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  int options,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
) {
  return _clang_parseTranslationUnit2(
    CIdx,
    source_filename,
    command_line_args,
    num_command_line_args,
    unsaved_files,
    num_unsaved_files,
    options,
    out_TU,
  );
}

final _dart_clang_parseTranslationUnit2 _clang_parseTranslationUnit2 =
    _dylib.lookupFunction<_c_clang_parseTranslationUnit2,
        _dart_clang_parseTranslationUnit2>('clang_parseTranslationUnit2');

typedef _c_clang_parseTranslationUnit2 = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  ffi.Int32 num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  ffi.Uint32 num_unsaved_files,
  ffi.Uint32 options,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
);

typedef _dart_clang_parseTranslationUnit2 = int Function(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  int num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  int options,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
);

/// Same as clang_parseTranslationUnit2 but requires a full command line for command_line_args including argv[0]. This is useful if the standard library paths are relative to the binary.
int clang_parseTranslationUnit2FullArgv(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  int num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  int options,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
) {
  return _clang_parseTranslationUnit2FullArgv(
    CIdx,
    source_filename,
    command_line_args,
    num_command_line_args,
    unsaved_files,
    num_unsaved_files,
    options,
    out_TU,
  );
}

final _dart_clang_parseTranslationUnit2FullArgv
    _clang_parseTranslationUnit2FullArgv = _dylib.lookupFunction<
            _c_clang_parseTranslationUnit2FullArgv,
            _dart_clang_parseTranslationUnit2FullArgv>(
        'clang_parseTranslationUnit2FullArgv');

typedef _c_clang_parseTranslationUnit2FullArgv = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  ffi.Int32 num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  ffi.Uint32 num_unsaved_files,
  ffi.Uint32 options,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
);

typedef _dart_clang_parseTranslationUnit2FullArgv = int Function(
  ffi.Pointer<ffi.Void> CIdx,
  ffi.Pointer<ffi.Int8> source_filename,
  ffi.Pointer<ffi.Pointer<ffi.Int8>> command_line_args,
  int num_command_line_args,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int num_unsaved_files,
  int options,
  ffi.Pointer<ffi.Pointer<CXTranslationUnitImpl>> out_TU,
);

/// Dispose the remapping.
void clang_remap_dispose(
  ffi.Pointer<ffi.Void> arg0,
) {
  return _clang_remap_dispose(
    arg0,
  );
}

final _dart_clang_remap_dispose _clang_remap_dispose =
    _dylib.lookupFunction<_c_clang_remap_dispose, _dart_clang_remap_dispose>(
        'clang_remap_dispose');

typedef _c_clang_remap_dispose = ffi.Void Function(
  ffi.Pointer<ffi.Void> arg0,
);

typedef _dart_clang_remap_dispose = void Function(
  ffi.Pointer<ffi.Void> arg0,
);

/// Get the original and the associated filename from the remapping.
void clang_remap_getFilenames(
  ffi.Pointer<ffi.Void> arg0,
  int index,
  ffi.Pointer<CXString> original,
  ffi.Pointer<CXString> transformed,
) {
  return _clang_remap_getFilenames(
    arg0,
    index,
    original,
    transformed,
  );
}

final _dart_clang_remap_getFilenames _clang_remap_getFilenames =
    _dylib.lookupFunction<_c_clang_remap_getFilenames,
        _dart_clang_remap_getFilenames>('clang_remap_getFilenames');

typedef _c_clang_remap_getFilenames = ffi.Void Function(
  ffi.Pointer<ffi.Void> arg0,
  ffi.Uint32 index,
  ffi.Pointer<CXString> original,
  ffi.Pointer<CXString> transformed,
);

typedef _dart_clang_remap_getFilenames = void Function(
  ffi.Pointer<ffi.Void> arg0,
  int index,
  ffi.Pointer<CXString> original,
  ffi.Pointer<CXString> transformed,
);

/// Determine the number of remappings.
int clang_remap_getNumFiles(
  ffi.Pointer<ffi.Void> arg0,
) {
  return _clang_remap_getNumFiles(
    arg0,
  );
}

final _dart_clang_remap_getNumFiles _clang_remap_getNumFiles = _dylib
    .lookupFunction<_c_clang_remap_getNumFiles, _dart_clang_remap_getNumFiles>(
        'clang_remap_getNumFiles');

typedef _c_clang_remap_getNumFiles = ffi.Uint32 Function(
  ffi.Pointer<ffi.Void> arg0,
);

typedef _dart_clang_remap_getNumFiles = int Function(
  ffi.Pointer<ffi.Void> arg0,
);

/// Reparse the source files that produced this translation unit.
int clang_reparseTranslationUnit(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  int num_unsaved_files,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int options,
) {
  return _clang_reparseTranslationUnit(
    TU,
    num_unsaved_files,
    unsaved_files,
    options,
  );
}

final _dart_clang_reparseTranslationUnit _clang_reparseTranslationUnit =
    _dylib.lookupFunction<_c_clang_reparseTranslationUnit,
        _dart_clang_reparseTranslationUnit>('clang_reparseTranslationUnit');

typedef _c_clang_reparseTranslationUnit = ffi.Int32 Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  ffi.Uint32 num_unsaved_files,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  ffi.Uint32 options,
);

typedef _dart_clang_reparseTranslationUnit = int Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  int num_unsaved_files,
  ffi.Pointer<CXUnsavedFile> unsaved_files,
  int options,
);

/// Saves a translation unit into a serialized representation of that translation unit on disk.
int clang_saveTranslationUnit(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  ffi.Pointer<ffi.Int8> FileName,
  int options,
) {
  return _clang_saveTranslationUnit(
    TU,
    FileName,
    options,
  );
}

final _dart_clang_saveTranslationUnit _clang_saveTranslationUnit =
    _dylib.lookupFunction<_c_clang_saveTranslationUnit,
        _dart_clang_saveTranslationUnit>('clang_saveTranslationUnit');

typedef _c_clang_saveTranslationUnit = ffi.Int32 Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  ffi.Pointer<ffi.Int8> FileName,
  ffi.Uint32 options,
);

typedef _dart_clang_saveTranslationUnit = int Function(
  ffi.Pointer<CXTranslationUnitImpl> TU,
  ffi.Pointer<ffi.Int8> FileName,
  int options,
);

/// Sort the code-completion results in case-insensitive alphabetical order.
void clang_sortCodeCompletionResults(
  ffi.Pointer<CXCompletionResult> Results,
  int NumResults,
) {
  return _clang_sortCodeCompletionResults(
    Results,
    NumResults,
  );
}

final _dart_clang_sortCodeCompletionResults _clang_sortCodeCompletionResults =
    _dylib.lookupFunction<_c_clang_sortCodeCompletionResults,
            _dart_clang_sortCodeCompletionResults>(
        'clang_sortCodeCompletionResults');

typedef _c_clang_sortCodeCompletionResults = ffi.Void Function(
  ffi.Pointer<CXCompletionResult> Results,
  ffi.Uint32 NumResults,
);

typedef _dart_clang_sortCodeCompletionResults = void Function(
  ffi.Pointer<CXCompletionResult> Results,
  int NumResults,
);

/// Suspend a translation unit in order to free memory associated with it.
int clang_suspendTranslationUnit(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
) {
  return _clang_suspendTranslationUnit(
    arg0,
  );
}

final _dart_clang_suspendTranslationUnit _clang_suspendTranslationUnit =
    _dylib.lookupFunction<_c_clang_suspendTranslationUnit,
        _dart_clang_suspendTranslationUnit>('clang_suspendTranslationUnit');

typedef _c_clang_suspendTranslationUnit = ffi.Uint32 Function(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
);

typedef _dart_clang_suspendTranslationUnit = int Function(
  ffi.Pointer<CXTranslationUnitImpl> arg0,
);

/// Enable/disable crash recovery.
void clang_toggleCrashRecovery(
  int isEnabled,
) {
  return _clang_toggleCrashRecovery(
    isEnabled,
  );
}

final _dart_clang_toggleCrashRecovery _clang_toggleCrashRecovery =
    _dylib.lookupFunction<_c_clang_toggleCrashRecovery,
        _dart_clang_toggleCrashRecovery>('clang_toggleCrashRecovery');

typedef _c_clang_toggleCrashRecovery = ffi.Void Function(
  ffi.Uint32 isEnabled,
);

typedef _dart_clang_toggleCrashRecovery = void Function(
  int isEnabled,
);

/// visitor is a function pointer with parameters having pointers to cxcursor instead of cxcursor by default
int clang_visitChildren_wrap(
  ffi.Pointer<CXCursor> parent,
  ffi.Pointer<ffi.NativeFunction<ModifiedCXCursorVisitor>> _modifiedVisitor,
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
  ffi.Pointer<CXCursor> parent,
  ffi.Pointer<ffi.NativeFunction<ModifiedCXCursorVisitor>> _modifiedVisitor,
  ffi.Pointer<ffi.Void> clientData,
);

typedef _dart_clang_visitChildren_wrap = int Function(
  ffi.Pointer<CXCursor> parent,
  ffi.Pointer<ffi.NativeFunction<ModifiedCXCursorVisitor>> _modifiedVisitor,
  ffi.Pointer<ffi.Void> clientData,
);