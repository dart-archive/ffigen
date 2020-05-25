/// AUTO GENERATED FILE, DO NOT EDIT
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi2;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib) {
  _dylib = dylib;
}

class CXGlobalOptFlags {
  static const int CXGlobalOpt_None = 0;
  static const int CXGlobalOpt_ThreadBackgroundPriorityForIndexing = 1;
  static const int CXGlobalOpt_ThreadBackgroundPriorityForEditing = 2;
  static const int CXGlobalOpt_ThreadBackgroundPriorityForAll = 3;
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
