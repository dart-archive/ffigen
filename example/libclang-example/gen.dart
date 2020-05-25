/// AUTO GENERATED FILE, DO NOT EDIT
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi2;

/// Dynamic library
ffi.DynamicLibrary _dylib;

/// Initialises dynamic library
void init(ffi.DynamicLibrary dylib) {
  _dylib = dylib;
}

class CXCodeCompleteResults extends ffi.Struct {}

class CXCompletionResult extends ffi.Struct {}

class CXCursor extends ffi.Struct {}

class CXCursorAndRangeVisitor extends ffi.Struct {}

class CXCursorSetImpl extends ffi.Struct {}

class CXFileUniqueID extends ffi.Struct {}

class CXIdxAttrInfo extends ffi.Struct {}

class CXIdxBaseClassInfo extends ffi.Struct {}

class CXIdxCXXClassDeclInfo extends ffi.Struct {}

class CXIdxContainerInfo extends ffi.Struct {}

class CXIdxDeclInfo extends ffi.Struct {}

class CXIdxEntityInfo extends ffi.Struct {}

class CXIdxEntityRefInfo extends ffi.Struct {}

class CXIdxIBOutletCollectionAttrInfo extends ffi.Struct {}

class CXIdxImportedASTFileInfo extends ffi.Struct {}

class CXIdxIncludedFileInfo extends ffi.Struct {}

class CXIdxLoc extends ffi.Struct {}

class CXIdxObjCCategoryDeclInfo extends ffi.Struct {}

class CXIdxObjCContainerDeclInfo extends ffi.Struct {}

class CXIdxObjCInterfaceDeclInfo extends ffi.Struct {}

class CXIdxObjCPropertyDeclInfo extends ffi.Struct {}

class CXIdxObjCProtocolRefInfo extends ffi.Struct {}

class CXIdxObjCProtocolRefListInfo extends ffi.Struct {}

class CXModuleMapDescriptorImpl extends ffi.Struct {}

class CXPlatformAvailability extends ffi.Struct {}

class CXSourceLocation extends ffi.Struct {}

class CXSourceRange extends ffi.Struct {}

class CXSourceRangeList extends ffi.Struct {}

class CXString extends ffi.Struct {}

class CXStringSet extends ffi.Struct {}

class CXTUResourceUsage extends ffi.Struct {}

class CXTUResourceUsageEntry extends ffi.Struct {}

class CXTargetInfoImpl extends ffi.Struct {}

class CXToken extends ffi.Struct {}

class CXTranslationUnitImpl extends ffi.Struct {}

class CXType extends ffi.Struct {}

class CXUnsavedFile extends ffi.Struct {}

class CXVersion extends ffi.Struct {}

class CXVirtualFileOverlayImpl extends ffi.Struct {}

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
