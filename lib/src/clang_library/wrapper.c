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
CXSourceRange *ptrToCXSourceRange(CXSourceRange t)
{
    CXSourceRange *c = aloc(CXSourceRange);
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

// Alternative typedef for [CXCursorVisitor] using pointer for passing cursor and parent
// instead of passing by value
typedef enum CXChildVisitResult (*ModifiedCXCursorVisitor)(CXCursor *cursor,
                                                           CXCursor *parent,
                                                           CXClientData client_data);

struct _stackForVisitChildren
{
    ModifiedCXCursorVisitor modifiedVisitor;
    struct _stackForVisitChildren *link;
} * _visitorTemp;

// Holds list of Isolate-Processor pairs, each having their own stack
// to hold the vistorFunctions.
struct _listForIsolateProcessPair
{
    long long uid;
    struct _listForIsolateProcessPair *next;
    struct _stackForVisitChildren *_visitorTop;
} ipHead, *ipTemp;
// `ipHead` is used only as head marker and will not contain any information.

// Finds/Creates an Isolate-Processor pair from/in the linkedlist.
struct _listForIsolateProcessPair *_findIP(long long uid)
{
    struct _listForIsolateProcessPair *temp = ipHead.next;
    while (temp != NULL)
    {
        if (temp->uid == uid)
        {
            return temp;
        }
        temp = temp->next;
    }
    // If we reach here this means no IP pair was found and we should create one
    // and add it to the head of our list.
    temp = aloc(struct _listForIsolateProcessPair);
    temp->next = ipHead.next;
    temp->uid = uid;
    temp->_visitorTop = NULL;
    ipHead.next = temp;
    return temp;
}
void _push(ModifiedCXCursorVisitor modifiedVisitor, long long uid)
{
    struct _listForIsolateProcessPair *current = _findIP(uid);
    if (current->_visitorTop == NULL)
    {
        current->_visitorTop = aloc(struct _stackForVisitChildren);
        current->_visitorTop->link = NULL;
        current->_visitorTop->modifiedVisitor = modifiedVisitor;
    }
    else
    {
        _visitorTemp = aloc(struct _stackForVisitChildren);
        _visitorTemp->link = current->_visitorTop;
        _visitorTemp->modifiedVisitor = modifiedVisitor;
        current->_visitorTop = _visitorTemp;
    }
}
void _pop(long long uid)
{
    struct _listForIsolateProcessPair *current = _findIP(uid);
    _visitorTemp = current->_visitorTop;

    if (_visitorTemp == NULL)
    {
        printf("\n Error, Wrapper.C : Trying to pop from empty stack");
        return;
    }
    else
        _visitorTemp = current->_visitorTop->link;
    free(current->_visitorTop);
    current->_visitorTop = _visitorTemp;
}
ModifiedCXCursorVisitor _top(long long uid)
{
    return _findIP(uid)->_visitorTop->modifiedVisitor;
}

// Do not write binding for this function.
// used by [clang_visitChildren_wrap].
enum CXChildVisitResult
_visitorwrap(CXCursor cursor, CXCursor parent, CXClientData clientData)
{
    // Use clientData (which is a unique ID) to get reference to the stack which
    // this particular process-isolate pair uses.
    long long uid = *((long long *)clientData);
    enum CXChildVisitResult e = (_top(uid)(ptrToCXCursor(cursor), ptrToCXCursor(parent), clientData));
    return e;
}

/** Visitor is a function pointer with parameters having pointers to cxcursor
* instead of cxcursor by default. */
unsigned clang_visitChildren_wrap(CXCursor *parent, ModifiedCXCursorVisitor _modifiedVisitor, long long uid)
{
    long long *clientData = aloc(long long);
    *clientData = uid;
    _push(_modifiedVisitor, uid);
    unsigned a = clang_visitChildren(*parent, _visitorwrap, clientData);
    _pop(uid);
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

/** Returns non-zero if the ranges are the same, zero if they differ. */
unsigned clang_equalRanges_wrap(CXSourceRange *c1, CXSourceRange *c2)
{
    return clang_equalRanges(*c1, *c2);
}

/** Returns the comment range. */
CXSourceRange *clang_Cursor_getCommentRange_wrap(CXCursor *cursor)
{
    return ptrToCXSourceRange(clang_Cursor_getCommentRange(*cursor));
}

/** Returns the raw comment. */
CXString *clang_Cursor_getRawCommentText_wrap(CXCursor *cursor)
{
    return ptrToCXString(clang_Cursor_getRawCommentText(*cursor));
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

unsigned clang_Cursor_isMacroFunctionLike_wrap(CXCursor *cursor)
{
    return clang_Cursor_isMacroFunctionLike(*cursor);
}

unsigned clang_Cursor_isMacroBuiltin_wrap(CXCursor *cursor)
{
    return clang_Cursor_isMacroBuiltin(*cursor);
}

CXEvalResult clang_Cursor_Evaluate_wrap(CXCursor *cursor)
{
    return clang_Cursor_Evaluate(*cursor);
}

unsigned clang_Cursor_isAnonymous_wrap(CXCursor *cursor)
{
    return clang_Cursor_isAnonymous(*cursor);
}

unsigned clang_Cursor_isAnonymousRecordDecl_wrap(CXCursor *cursor)
{
    return clang_Cursor_isAnonymousRecordDecl(*cursor);
}

CXString *clang_getCursorUSR_wrap(CXCursor *cursor)
{
    return ptrToCXString(clang_getCursorUSR(*cursor));
}

int clang_getFieldDeclBitWidth_wrap(CXCursor *cursor){
    return clang_getFieldDeclBitWidth(*cursor);
}

// END ===== WRAPPER FUNCTIONS =====================
