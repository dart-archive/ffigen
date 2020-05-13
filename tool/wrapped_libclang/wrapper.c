#include <clang-c/Index.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define aloc(T) ((T *)malloc(sizeof(T)))

// START ===== Functions for testing libclang behavior in C
enum CXChildVisitResult visitor_for_test_in_c(CXCursor cursor, CXCursor parent, CXClientData clientData)
{
    printf("Cursor- kind: %s, name: %s\n", clang_getCString(clang_getCursorKindSpelling(clang_getCursorKind(cursor))), clang_getCString(clang_getCursorSpelling(cursor)));
    return CXChildVisit_Continue;
}
int test_in_c()
{
    printf("==========================run==========================\n");
    CXIndex Index = clang_createIndex(0, 0);
    CXTranslationUnit TU = clang_parseTranslationUnit(Index,
                                                      "./test.h", 0, 0, NULL, 0, CXTranslationUnit_None);

    if (TU == NULL)
    {
        printf("Error creating TU\n");
        return 0;
    }

    CXCursor root = clang_getTranslationUnitCursor(TU);

    unsigned a = clang_visitChildren(root, visitor_for_test_in_c, NULL);

    clang_disposeTranslationUnit(TU);
    clang_disposeIndex(Index);
    printf("\n==========================end==========================\n");
    return 0;
}
// END ===== Functions for testing libclang behavior in C ============================

// START ===== WRAPPER FUNCTIONS =====================

const char *clang_getCString_wrap(CXString *string)
{
    const char *a = clang_getCString(*string);

    return a;
}

void clang_disposeString_wrap(CXString *string)
{
    return clang_disposeString(*string);
}

enum CXCursorKind clang_getCursorKind_wrap(CXCursor *cursor)
{
    return clang_getCursorKind(*cursor);
}

CXString *clang_getCursorKindSpelling_wrap(enum CXCursorKind kind)
{
    CXString *s = aloc(CXString);
    *s = clang_getCursorKindSpelling(kind);
    return s;
}

CXType *clang_getCursorType_wrap(CXCursor *cursor)
{
    CXType *t = aloc(CXType);
    *t = clang_getCursorType(*cursor);
    return t;
}

CXString *clang_getTypeSpelling_wrap(CXType *type)
{
    CXString *s = aloc(CXString);
    *s = clang_getTypeSpelling(*type);
    return s;
}

CXType *clang_getResultType_wrap(CXType *functionType){
    CXType *t = aloc(CXType);
    *t = clang_getResultType(*functionType);
    return t;
}

CXType *clang_getPointeeType_wrap(CXType *pointerType){
    CXType *t = aloc(CXType);
    *t = clang_getPointeeType(*pointerType);
    return t;
}

CXString *clang_getCursorSpelling_wrap(CXCursor *cursor)
{
    CXString *s = aloc(CXString);
    *s = clang_getCursorSpelling(*cursor);
    return s;
}

CXCursor *clang_getTranslationUnitCursor_wrap(CXTranslationUnit tu)
{
    CXCursor *c = aloc(CXCursor);
    *c = clang_getTranslationUnitCursor(tu);
    return c;
}

CXString *clang_formatDiagnostic_wrap(CXDiagnostic diag, int opts)
{
    CXString *s = aloc(CXString);
    *s = clang_formatDiagnostic(diag, opts);
    return s;
}

// alternative typedef for [CXCursorVisitor] using pointer for passing cursor and parent
// instead of passing by value
typedef enum CXChildVisitResult (*ModifiedCXCursorVisitor)(CXCursor *cursor,
                                                           CXCursor *parent,
                                                           CXClientData client_data);

// global variable
// holds Pointer to Dart function received from [clang_visitChildren_wrap]
// called in [_visitorWrap]
ModifiedCXCursorVisitor modifiedVisitor;

// do not write binding for this function
// used by [clang_visitChildren_wrap]
enum CXChildVisitResult _visitorwrap(CXCursor cursor, CXCursor parent, CXClientData clientData)
{
    CXCursor *ncursor = aloc(CXCursor);
    CXCursor *nparent = aloc(CXCursor);
    *ncursor = cursor;
    *nparent = parent;
    enum CXChildVisitResult e = modifiedVisitor(ncursor, nparent, clientData);
    return e;
}

// visitor is a function pointer with parameters having pointers to cxcursor
// instead of cxcursor by default
unsigned clang_visitChildren_wrap(CXCursor *parent, ModifiedCXCursorVisitor _modifiedVisitor, CXClientData clientData)
{
    modifiedVisitor = _modifiedVisitor;
    return clang_visitChildren(*parent, _visitorwrap, clientData);
}

// END ===== WRAPPER FUNCTIONS =====================
