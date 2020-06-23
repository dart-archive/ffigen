// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <clang-c/Index.h>
#include <stdio.h>
#include <stdlib.h>

// utility.
#define aloc(T) ((T *)malloc(sizeof(T)))
CXCursor *ptrToCXCursor(CXCursor t)
{
    CXCursor *c = aloc(CXCursor);
    *c = t;
    return c;
}
CXString *ptrToCXString(CXString t)
{
    CXString *c = aloc(CXString);
    *c = t;
    return c;
}
CXType *ptrToCXType(CXType t)
{
    CXType *c = aloc(CXType);
    *c = t;
    return c;
}
CXSourceLocation *ptrToCXSourceLocation(CXSourceLocation t)
{
    CXSourceLocation *c = aloc(CXSourceLocation);
    *c = t;
    return c;
}
// START ===== Functions for testing libclang behavior in C.
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
    clang_disposeString(*string);
    free(string);
    return;
}

enum CXCursorKind clang_getCursorKind_wrap(CXCursor *cursor)
{
    return clang_getCursorKind(*cursor);
}

CXString *clang_getCursorKindSpelling_wrap(enum CXCursorKind kind)
{
    return ptrToCXString(clang_getCursorKindSpelling(kind));
}

CXType *clang_getCursorType_wrap(CXCursor *cursor)
{
    return ptrToCXType(clang_getCursorType(*cursor));
}

CXString *clang_getTypeSpelling_wrap(CXType *type)
{
    return ptrToCXString(clang_getTypeSpelling(*type));
}

CXString *clang_getTypeKindSpelling_wrap(enum CXTypeKind typeKind)
{
    return ptrToCXString(clang_getTypeKindSpelling(typeKind));
}

CXType *clang_getResultType_wrap(CXType *functionType)
{
    return ptrToCXType(clang_getResultType(*functionType));
}

CXType *clang_getPointeeType_wrap(CXType *pointerType)
{
    return ptrToCXType(clang_getPointeeType(*pointerType));
}

CXType *clang_getCanonicalType_wrap(CXType *typerefType)
{
    return ptrToCXType(clang_getCanonicalType(*typerefType));
}

CXType *clang_Type_getNamedType_wrap(CXType *elaboratedType)
{
    return ptrToCXType(clang_Type_getNamedType(*elaboratedType));
}

CXCursor *clang_getTypeDeclaration_wrap(CXType *cxtype)
{
    return ptrToCXCursor(clang_getTypeDeclaration(*cxtype));
}

CXType *clang_getTypedefDeclUnderlyingType_wrap(CXCursor *cxcursor)
{
    return ptrToCXType(clang_getTypedefDeclUnderlyingType(*cxcursor));
}

/** The name of parameter, struct, typedef. */
CXString *clang_getCursorSpelling_wrap(CXCursor *cursor)
{
    return ptrToCXString(clang_getCursorSpelling(*cursor));
}

CXCursor *clang_getTranslationUnitCursor_wrap(CXTranslationUnit tu)
{
    return ptrToCXCursor(clang_getTranslationUnitCursor(tu));
}

CXString *clang_formatDiagnostic_wrap(CXDiagnostic diag, int opts)
{
    return ptrToCXString(clang_formatDiagnostic(diag, opts));
}

// alternative typedef for [CXCursorVisitor] using pointer for passing cursor and parent
// instead of passing by value
typedef enum CXChildVisitResult (*ModifiedCXCursorVisitor)(CXCursor *cursor,
                                                           CXCursor *parent,
                                                           CXClientData client_data);

// holds Pointers to Dart function received from [clang_visitChildren_wrap]
// called in [_visitorWrap]
struct _stackForVisitChildren
{
    ModifiedCXCursorVisitor modifiedVisitor;
    struct _stackForVisitChildren *link;
} * _visitorTop, *_visitorTemp;
void _push(ModifiedCXCursorVisitor modifiedVisitor)
{
    if (_visitorTop == NULL)
    {
        _visitorTop = (struct _stackForVisitChildren *)malloc(1 * sizeof(struct _stackForVisitChildren));
        _visitorTop->link = NULL;
        _visitorTop->modifiedVisitor = modifiedVisitor;
    }
    else
    {
        _visitorTemp = (struct _stackForVisitChildren *)malloc(1 * sizeof(struct _stackForVisitChildren));
        _visitorTemp->link = _visitorTop;
        _visitorTemp->modifiedVisitor = modifiedVisitor;
        _visitorTop = _visitorTemp;
    }
}
void _pop()
{
    _visitorTemp = _visitorTop;

    if (_visitorTemp == NULL)
    {
        printf("\n Error, Wrapper.C : Trying to pop from empty stack");
        return;
    }
    else
        _visitorTemp = _visitorTop->link;
    free(_visitorTop);
    _visitorTop = _visitorTemp;
}
ModifiedCXCursorVisitor _top()
{
    return _visitorTop->modifiedVisitor;
}
// Do not write binding for this function.
// used by [clang_visitChildren_wrap].
enum CXChildVisitResult
_visitorwrap(CXCursor cursor, CXCursor parent, CXClientData clientData)
{
    enum CXChildVisitResult e = (_top()(ptrToCXCursor(cursor), ptrToCXCursor(parent), clientData));
    return e;
}

/** Visitor is a function pointer with parameters having pointers to cxcursor
* instead of cxcursor by default. */
unsigned clang_visitChildren_wrap(CXCursor *parent, ModifiedCXCursorVisitor _modifiedVisitor, CXClientData clientData)
{
    _push(_modifiedVisitor);
    unsigned a = clang_visitChildren(*parent, _visitorwrap, clientData);
    _pop();
    return a;
}

int clang_Cursor_getNumArguments_wrap(CXCursor *cursor)
{
    return clang_Cursor_getNumArguments(*cursor);
}

CXCursor *clang_Cursor_getArgument_wrap(CXCursor *cursor, unsigned i)
{
    return ptrToCXCursor(clang_Cursor_getArgument(*cursor, i));
}

int clang_getNumArgTypes_wrap(CXType *cxtype)
{
    return clang_getNumArgTypes(*cxtype);
}

CXType *clang_getArgType_wrap(CXType *cxtype, unsigned i)
{
    return ptrToCXType(clang_getArgType(*cxtype, i));
}

long long clang_getEnumConstantDeclValue_wrap(CXCursor *cursor)
{
    return clang_getEnumConstantDeclValue(*cursor);
}

/** Returns the first paragraph of doxygen doc comment. */
CXString *clang_Cursor_getBriefCommentText_wrap(CXCursor *cursor)
{
    return ptrToCXString(clang_Cursor_getBriefCommentText(*cursor));
}

CXSourceLocation *clang_getCursorLocation_wrap(CXCursor *cursor)
{
    return ptrToCXSourceLocation(clang_getCursorLocation(*cursor));
}

void clang_getFileLocation_wrap(CXSourceLocation *location, CXFile *file, unsigned *line, unsigned *column, unsigned *offset)
{
    return clang_getFileLocation(*location, file, line, column, offset);
}

CXString *clang_getFileName_wrap(CXFile SFile)
{
    return ptrToCXString(clang_getFileName(SFile));
}

unsigned long long clang_getNumElements_wrap(CXType *cxtype)
{
    return clang_getNumElements(*cxtype);
}

CXType *clang_getArrayElementType_wrap(CXType *cxtype)
{
    return ptrToCXType(clang_getArrayElementType(*cxtype));
}

// END ===== WRAPPER FUNCTIONS =====================
