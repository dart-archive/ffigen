import 'package:ffigen/src/header_parser/clang_bindings/clang_constants.dart'
    as clang;
import 'package:ffigen/src/code_generator.dart'
    show SupportedNativeType, FfiUtilType;

/// Utility to convert CXType to [code_generator.Type]
///
/// key: CXTypekindEnum, Value: TypeString for code_generator
var cxTypeKindToSupportedNativeTypes = <int, SupportedNativeType>{
  clang.CXTypeKind.CXType_Void: SupportedNativeType.Void,
  clang.CXTypeKind.CXType_UChar: SupportedNativeType.Uint8,
  clang.CXTypeKind.CXType_UShort: SupportedNativeType.Uint16,
  clang.CXTypeKind.CXType_UInt: SupportedNativeType.Uint32,
  clang.CXTypeKind.CXType_ULong: SupportedNativeType.Uint64,
  clang.CXTypeKind.CXType_ULongLong: SupportedNativeType.Uint64,
  clang.CXTypeKind.CXType_SChar: SupportedNativeType.Int8,
  clang.CXTypeKind.CXType_Short: SupportedNativeType.Int16,
  clang.CXTypeKind.CXType_Int: SupportedNativeType.Int32,
  clang.CXTypeKind.CXType_Long: SupportedNativeType.Int64,
  clang.CXTypeKind.CXType_LongLong: SupportedNativeType.Int64,
  clang.CXTypeKind.CXType_Float: SupportedNativeType.Float,
  clang.CXTypeKind.CXType_Double: SupportedNativeType.Double,
};

var cxTypeKindToFfiUtilType = <int, FfiUtilType>{
  clang.CXTypeKind.CXType_Char_S: FfiUtilType.Utf8,
};

// TODO: check type to use for enums
var enumNativeType = SupportedNativeType.Int32;
