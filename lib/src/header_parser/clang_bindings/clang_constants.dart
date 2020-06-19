// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// File created manually by pasting and editing code from clang's source headers

/// Used in clang_formatDiagnostics
class CXDiagnosticDisplayOptions {
  ///
  /// Display the source-location information where the
  /// diagnostic was located.
  ///
  /// When set, diagnostics will be prefixed by the file, line, and
  /// (optionally) column to which the diagnostic refers. For example,
  ///
  /// \code
  /// test.c:28: warning: extra tokens at end of #endif directive
  /// \endcode
  ///
  /// This option corresponds to the clang flag \c -fshow-source-location.

  static const CXDiagnostic_DisplaySourceLocation = 0x01;

  ///
  /// If displaying the source-location information of the
  /// diagnostic, also include the column number.
  ///
  /// This option corresponds to the clang flag \c -fshow-column.

  static const CXDiagnostic_DisplayColumn = 0x02;

  ///
  /// If displaying the source-location information of the
  /// diagnostic, also include information about source ranges in a
  /// machine-parsable format.
  ///
  /// This option corresponds to the clang flag
  /// \c -fdiagnostics-print-source-range-info.

  static const CXDiagnostic_DisplaySourceRanges = 0x04;

  ///
  /// Display the option name associated with this diagnostic, if any.
  ///
  /// The option name displayed (e.g., -Wconversion) will be placed in brackets
  /// after the diagnostic text. This option corresponds to the clang flag
  /// \c -fdiagnostics-show-option.

  static const CXDiagnostic_DisplayOption = 0x08;

  ///
  /// Display the category number associated with this diagnostic, if any.
  ///
  /// The category number is displayed within brackets after the diagnostic text.
  /// This option corresponds to the clang flag
  /// \c -fdiagnostics-show-category=id.

  static const CXDiagnostic_DisplayCategoryId = 0x10;

  ///
  /// Display the category name associated with this diagnostic, if any.
  ///
  /// The category name is displayed within brackets after the diagnostic text.
  /// This option corresponds to the clang flag
  /// \c -fdiagnostics-show-category=name.

  static const CXDiagnostic_DisplayCategoryName = 0x20;
}

/// Used in clang_parseTranslationUnit
class CXTranslationUnit_Flags {
  ///
  /// Used to indicate that no special translation-unit options are
  /// needed.

  static const CXTranslationUnit_None = 0x0;

  ///
  /// Used to indicate that the parser should construct a "detailed"
  /// preprocessing record, including all macro definitions and instantiations.
  ///
  /// Constructing a detailed preprocessing record requires more memory
  /// and time to parse, since the information contained in the record
  /// is usually not retained. However, it can be useful for
  /// applications that require more detailed information about the
  /// behavior of the preprocessor.

  static const CXTranslationUnit_DetailedPreprocessingRecord = 0x01;

  ///
  /// Used to indicate that the translation unit is incomplete.
  ///
  /// When a translation unit is considered "incomplete", semantic
  /// analysis that is typically performed at the end of the
  /// translation unit will be suppressed. For example, this suppresses
  /// the completion of tentative declarations in C and of
  /// instantiation of implicitly-instantiation function templates in
  /// C++. This option is typically used when parsing a header with the
  /// intent of producing a precompiled header.

  static const CXTranslationUnit_Incomplete = 0x02;

  ///
  /// Used to indicate that the translation unit should be built with an
  /// implicit precompiled header for the preamble.
  ///
  /// An implicit precompiled header is used as an optimization when a
  /// particular translation unit is likely to be reparsed many times
  /// when the sources aren't changing that often. In this case, an
  /// implicit precompiled header will be built containing all of the
  /// initial includes at the top of the main file (what we refer to as
  /// the "preamble" of the file). In subsequent parses, if the
  /// preamble or the files in it have not changed, \c
  /// clang_reparseTranslationUnit() will re-use the implicit
  /// precompiled header to improve parsing performance.

  static const CXTranslationUnit_PrecompiledPreamble = 0x04;

  ///
  /// Used to indicate that the translation unit should cache some
  /// code-completion results with each reparse of the source file.
  ///
  /// Caching of code-completion results is a performance optimization that
  /// introduces some overhead to reparsing but improves the performance of
  /// code-completion operations.

  static const CXTranslationUnit_CacheCompletionResults = 0x08;

  ///
  /// Used to indicate that the translation unit will be serialized with
  /// \c clang_saveTranslationUnit.
  ///
  /// This option is typically used when parsing a header with the intent of
  /// producing a precompiled header.

  static const CXTranslationUnit_ForSerialization = 0x10;

  ///
  /// DEPRECATED: Enabled chained precompiled preambles in C++.
  ///
  /// Note: this is a ///temporary/// option that is available only while
  /// we are testing C++ precompiled preamble support. It is deprecated.

  static const CXTranslationUnit_CXXChainedPCH = 0x20;

  ///
  /// Used to indicate that function/method bodies should be skipped while
  /// parsing.
  ///
  /// This option can be used to search for declarations/definitions while
  /// ignoring the usages.

  static const CXTranslationUnit_SkipFunctionBodies = 0x40;

  ///
  /// Used to indicate that brief documentation comments should be
  /// included into the set of code completions returned from this translation
  /// unit.

  static const CXTranslationUnit_IncludeBriefCommentsInCodeCompletion = 0x80;

  ///
  /// Used to indicate that the precompiled preamble should be created on
  /// the first parse. Otherwise it will be created on the first reparse. This
  /// trades runtime on the first parse (serializing the preamble takes time) for
  /// reduced runtime on the second parse (can now reuse the preamble).

  static const CXTranslationUnit_CreatePreambleOnFirstParse = 0x100;

  ///
  /// Do not stop processing when fatal errors are encountered.
  ///
  /// When fatal errors are encountered while parsing a translation unit,
  /// semantic analysis is typically stopped early when compiling code. A common
  /// source for fatal errors are unresolvable include files. For the
  /// purposes of an IDE, this is undesirable behavior and as much information
  /// as possible should be reported. Use this flag to enable this behavior.

  static const CXTranslationUnit_KeepGoing = 0x200;

  ///
  /// Sets the preprocessor in a mode for parsing a single file only.

  static const CXTranslationUnit_SingleFileParse = 0x400;

  ///
  /// Used in combination withstatic const CXTranslationUnit_SkipFunctionBodies to
  /// constrain the skipping of function bodies to the preamble.
  ///
  /// The function bodies of the main file are not skipped.

  static const CXTranslationUnit_LimitSkipFunctionBodiesToPreamble = 0x800;

  ///
  /// Used to indicate that attributed types should be included instatic const CXType.

  static const CXTranslationUnit_IncludeAttributedTypes = 0x1000;

  ///
  /// Used to indicate that implicit attributes should be visited.

  static const CXTranslationUnit_VisitImplicitAttributes = 0x2000;

  ///
  /// Used to indicate that non-errors from included files should be ignored.
  ///
  /// If set, clang_getDiagnosticSetFromTU() will not report e.g. warnings from
  /// included files anymore. This speeds up clang_getDiagnosticSetFromTU() for
  /// the case where these warnings are not of interest, as for an IDE for
  /// example, which typically shows only the diagnostics in the main file.

  static const CXTranslationUnit_IgnoreNonErrorsFromIncludedFiles = 0x4000;

  ///
  /// Tells the preprocessor not to skip excluded conditional blocks.

  static const CXTranslationUnit_RetainExcludedConditionalBlocks = 0x8000;
}

class CXChildVisitResult {
  ///
  /// Terminates the cursor traversal.

  static const CXChildVisit_Break = 0;

  ///
  /// Continues the cursor traversal with the next sibling of
  /// the cursor just visited, without visiting its children.

  static const CXChildVisit_Continue = 1;

  ///
  /// Recursively traverse the children of this cursor, using
  /// the same visitor and client data.

  static const CXChildVisit_Recurse = 2;
}

class CXCursorKind {
  /// Declarations
  ///
  /// A declaration whose specific kind is not exposed via this
  /// interface.
  ///
  /// Unexposed declarations have the same operations as any other kind
  /// of declaration; one can extract their location information,
  /// spelling, find their definitions, etc. However, the specific kind
  /// of the declaration is not reported.

  static const CXCursor_UnexposedDecl = 1;

  /// A C or C++ struct.
  static const CXCursor_StructDecl = 2;

  /// A C or C++ union.
  static const CXCursor_UnionDecl = 3;

  /// A C++ class.
  static const CXCursor_ClassDecl = 4;

  /// An enumeration.
  static const CXCursor_EnumDecl = 5;

  ///
  /// A field (in C) or non-static data member (in C++) in a
  /// struct, union, or C++ class.

  static const CXCursor_FieldDecl = 6;

  /// An enumerator constant.
  static const CXCursor_EnumConstantDecl = 7;

  /// A function.
  static const CXCursor_FunctionDecl = 8;

  /// A variable.
  static const CXCursor_VarDecl = 9;

  /// A function or method parameter.
  static const CXCursor_ParmDecl = 10;

  /// An Objective-C \@interface.
  static const CXCursor_ObjCInterfaceDecl = 11;

  /// An Objective-C \@interface for a category.
  static const CXCursor_ObjCCategoryDecl = 12;

  /// An Objective-C \@protocol declaration.
  static const CXCursor_ObjCProtocolDecl = 13;

  /// An Objective-C \@property declaration.
  static const CXCursor_ObjCPropertyDecl = 14;

  /// An Objective-C instance variable.
  static const CXCursor_ObjCIvarDecl = 15;

  /// An Objective-C instance method.
  static const CXCursor_ObjCInstanceMethodDecl = 16;

  /// An Objective-C class method.
  static const CXCursor_ObjCClassMethodDecl = 17;

  /// An Objective-C \@implementation.
  static const CXCursor_ObjCImplementationDecl = 18;

  /// An Objective-C \@implementation for a category.
  static const CXCursor_ObjCCategoryImplDecl = 19;

  /// A typedef.
  static const CXCursor_TypedefDecl = 20;

  /// A C++ class method.
  static const CXCursor_CXXMethod = 21;

  /// A C++ namespace.
  static const CXCursor_Namespace = 22;

  /// A linkage specification, e.g. 'extern "C"'.
  static const CXCursor_LinkageSpec = 23;

  /// A C++ constructor.
  static const CXCursor_Constructor = 24;

  /// A C++ destructor.
  static const CXCursor_Destructor = 25;

  /// A C++ conversion function.
  static const CXCursor_ConversionFunction = 26;

  /// A C++ template type parameter.
  static const CXCursor_TemplateTypeParameter = 27;

  /// A C++ non-type template parameter.
  static const CXCursor_NonTypeTemplateParameter = 28;

  /// A C++ template template parameter.
  static const CXCursor_TemplateTemplateParameter = 29;

  /// A C++ function template.
  static const CXCursor_FunctionTemplate = 30;

  /// A C++ class template.
  static const CXCursor_ClassTemplate = 31;

  /// A C++ class template partial specialization.
  static const CXCursor_ClassTemplatePartialSpecialization = 32;

  /// A C++ namespace alias declaration.
  static const CXCursor_NamespaceAlias = 33;

  /// A C++ using directive.
  static const CXCursor_UsingDirective = 34;

  /// A C++ using declaration.
  static const CXCursor_UsingDeclaration = 35;

  /// A C++ alias declaration
  static const CXCursor_TypeAliasDecl = 36;

  /// An Objective-C \@synthesize definition.
  static const CXCursor_ObjCSynthesizeDecl = 37;

  /// An Objective-C \@dynamic definition.
  static const CXCursor_ObjCDynamicDecl = 38;

  /// An access specifier.
  static const CXCursor_CXXAccessSpecifier = 39;

  static const CXCursor_FirstDecl = CXCursor_UnexposedDecl;
  static const CXCursor_LastDecl = CXCursor_CXXAccessSpecifier;

  // References
  static const CXCursor_FirstRef = 40; // Decl references
  static const CXCursor_ObjCSuperClassRef = 40;
  static const CXCursor_ObjCProtocolRef = 41;
  static const CXCursor_ObjCClassRef = 42;

  ///
  /// A reference to a type declaration.
  ///
  /// A type reference occurs anywhere where a type is named but not
  /// declared. For example, given:
  ///
  /// \code
  /// typedef unsigned size_type;
  /// size_type size;
  /// \endcode
  ///
  /// The typedef is a declaration of size_type (CXCursor_TypedefDecl),
  /// while the type of the variable "size" is referenced. The cursor
  /// referenced by the type of size is the typedef for size_type.

  static const CXCursor_TypeRef = 43;
  static const CXCursor_CXXBaseSpecifier = 44;

  ///
  /// A reference to a class template, function template, template
  /// template parameter, or class template partial specialization.

  static const CXCursor_TemplateRef = 45;

  ///
  /// A reference to a namespace or namespace alias.

  static const CXCursor_NamespaceRef = 46;

  ///
  /// A reference to a member of a struct, union, or class that occurs in
  /// some non-expression context, e.g., a designated initializer.

  static const CXCursor_MemberRef = 47;

  ///
  /// A reference to a labeled statement.
  ///
  /// This cursor kind is used to describe the jump to "start_over" in the
  /// goto statement in the following example:
  ///
  /// \code
  ///   start_over:
  ///     ++counter;
  ///
  ///     goto start_over;
  /// \endcode
  ///
  /// A label reference cursor refers to a label statement.

  static const CXCursor_LabelRef = 48;

  ///
  /// A reference to a set of overloaded functions or function templates
  /// that has not yet been resolved to a specific function or function template.
  ///
  /// An overloaded declaration reference cursor occurs in C++ templates where
  /// a dependent name refers to a function. For example:
  ///
  /// \code
  /// template<typename T> void swap(T&, T&);
  ///
  /// struct X { ... };
  /// void swap(X&, X&);
  ///
  /// template<typename T>
  /// void reverse(T/// first, T/// last) {
  ///   while (first < last - 1) {
  ///     swap(///first, ///--last);
  ///     ++first;
  ///   }
  /// }
  ///
  /// struct Y { };
  /// void swap(Y&, Y&);
  /// \endcode
  ///
  /// Here, the identifier "swap" is associated with an overloaded declaration
  /// reference. In the template definition, "swap" refers to either of the two
  /// "swap" functions declared above, so both results will be available. At
  /// instantiation time, "swap" may also refer to other functions found via
  /// argument-dependent lookup (e.g., the "swap" function at the end of the
  /// example).
  ///
  /// The functions \c clang_getNumOverloadedDecls() and
  /// \c clang_getOverloadedDecl() can be used to retrieve the definitions
  /// referenced by this cursor.

  static const CXCursor_OverloadedDeclRef = 49;

  ///
  /// A reference to a variable that occurs in some non-expression
  /// context, e.g., a C++ lambda capture list.

  static const CXCursor_VariableRef = 50;

  static const CXCursor_LastRef = CXCursor_VariableRef;

  // Error conditions
  static const CXCursor_FirstInvalid = 70;
  static const CXCursor_InvalidFile = 70;
  static const CXCursor_NoDeclFound = 71;
  static const CXCursor_NotImplemented = 72;
  static const CXCursor_InvalidCode = 73;
  static const CXCursor_LastInvalid = CXCursor_InvalidCode;

  // Expressions
  static const CXCursor_FirstExpr = 100;

  ///
  /// An expression whose specific kind is not exposed via this
  /// interface.
  ///
  /// Unexposed expressions have the same operations as any other kind
  /// of expression; one can extract their location information,
  /// spelling, children, etc. However, the specific kind of the
  /// expression is not reported.

  static const CXCursor_UnexposedExpr = 100;

  ///
  /// An expression that refers to some value declaration, such
  /// as a function, variable, or enumerator.

  static const CXCursor_DeclRefExpr = 101;

  ///
  /// An expression that refers to a member of a struct, union,
  /// class, Objective-C class, etc.

  static const CXCursor_MemberRefExpr = 102;

  /// An expression that calls a function.
  static const CXCursor_CallExpr = 103;

  /// An expression that sends a message to an Objective-C
  /// object or class.
  static const CXCursor_ObjCMessageExpr = 104;

  /// An expression that represents a block literal.
  static const CXCursor_BlockExpr = 105;

  /// An integer literal.

  static const CXCursor_IntegerLiteral = 106;

  /// A floating point number literal.

  static const CXCursor_FloatingLiteral = 107;

  /// An imaginary number literal.

  static const CXCursor_ImaginaryLiteral = 108;

  /// A string literal.

  static const CXCursor_StringLiteral = 109;

  /// A character literal.

  static const CXCursor_CharacterLiteral = 110;

  /// A parenthesized expression, e.g. "(1)".
  ///
  /// This AST node is only formed if full location information is requested.

  static const CXCursor_ParenExpr = 111;

  /// This represents the unary-expression's (except sizeof and
  /// alignof).

  static const CXCursor_UnaryOperator = 112;

  /// [C99 6.5.2.1] Array Subscripting.

  static const CXCursor_ArraySubscriptExpr = 113;

  /// A builtin binary operation expression such as "x + y" or
  /// "x <= y".

  static const CXCursor_BinaryOperator = 114;

  /// Compound assignment such as "+=".

  static const CXCursor_CompoundAssignOperator = 115;

  /// The ?: ternary operator.

  static const CXCursor_ConditionalOperator = 116;

  /// An explicit cast in C (C99 6.5.4) or a C-style cast in C++
  /// (C++ [expr.cast]), which uses the syntax (Type)expr.
  ///
  /// For example: (int)f.

  static const CXCursor_CStyleCastExpr = 117;

  /// [C99 6.5.2.5]

  static const CXCursor_CompoundLiteralExpr = 118;

  /// Describes an C or C++ initializer list.

  static const CXCursor_InitListExpr = 119;

  /// The GNU address of label extension, representing &&label.

  static const CXCursor_AddrLabelExpr = 120;

  /// This is the GNU Statement Expression extension: ({int X=4; X;})

  static const CXCursor_StmtExpr = 121;

  /// Represents a C11 generic selection.

  static const CXCursor_GenericSelectionExpr = 122;

  /// Implements the GNU __null extension, which is a name for a null
  /// pointer constant that has integral type (e.g., int or long) and is the same
  /// size and alignment as a pointer.
  ///
  /// The __null extension is typically only used by system headers, which define
  /// NULL as __null in C++ rather than using 0 (which is an integer that may not
  /// match the size of a pointer).

  static const CXCursor_GNUNullExpr = 123;

  /// C++'s static_cast<> expression.

  static const CXCursor_CXXStaticCastExpr = 124;

  /// C++'s dynamic_cast<> expression.

  static const CXCursor_CXXDynamicCastExpr = 125;

  /// C++'s reinterpret_cast<> expression.

  static const CXCursor_CXXReinterpretCastExpr = 126;

  /// C++'s const_cast<> expression.

  static const CXCursor_CXXConstCastExpr = 127;

  /// Represents an explicit C++ type conversion that uses "functional"
  /// notion (C++ [expr.type.conv]).
  ///
  /// Example:
  /// \code
  ///   x = int(0.5);
  /// \endcode

  static const CXCursor_CXXFunctionalCastExpr = 128;

  /// A C++ typeid expression (C++ [expr.typeid]).

  static const CXCursor_CXXTypeidExpr = 129;

  /// [C++ 2.13.5] C++ Boolean Literal.

  static const CXCursor_CXXBoolLiteralExpr = 130;

  /// [C++0x 2.14.7] C++ Pointer Literal.

  static const CXCursor_CXXNullPtrLiteralExpr = 131;

  /// Represents the "this" expression in C++

  static const CXCursor_CXXThisExpr = 132;

  /// [C++ 15] C++ Throw Expression.
  ///
  /// This handles 'throw' and 'throw' assignment-expression. When
  /// assignment-expression isn't present, Op will be null.

  static const CXCursor_CXXThrowExpr = 133;

  /// A new expression for memory allocation and constructor calls, e.g:
  /// "newstatic const CXXNewExpr(foo)".

  static const CXCursor_CXXNewExpr = 134;

  /// A delete expression for memory deallocation and destructor calls,
  /// e.g. "delete[] pArray".

  static const CXCursor_CXXDeleteExpr = 135;

  /// A unary expression. (noexcept, sizeof, or other traits)

  static const CXCursor_UnaryExpr = 136;

  /// An Objective-C string literal i.e. @"foo".

  static const CXCursor_ObjCStringLiteral = 137;

  /// An Objective-C \@encode expression.

  static const CXCursor_ObjCEncodeExpr = 138;

  /// An Objective-C \@selector expression.

  static const CXCursor_ObjCSelectorExpr = 139;

  /// An Objective-C \@protocol expression.

  static const CXCursor_ObjCProtocolExpr = 140;

  /// An Objective-C "bridged" cast expression, which casts between
  /// Objective-C pointers and C pointers, transferring ownership in the process.
  ///
  /// \code
  ///   NSString ///str = (__bridge_transfer NSString ///)CFCreateString();
  /// \endcode

  static const CXCursor_ObjCBridgedCastExpr = 141;

  /// Represents a C++0x pack expansion that produces a sequence of
  /// expressions.
  ///
  /// A pack expansion expression contains a pattern (which itself is an
  /// expression) followed by an ellipsis. For example:
  ///
  /// \code
  /// template<typename F, typename ...Types>
  /// void forward(F f, Types &&...args) {
  ///  f(static_cast<Types&&>(args)...);
  /// }
  /// \endcode

  static const CXCursor_PackExpansionExpr = 142;

  /// Represents an expression that computes the length of a parameter
  /// pack.
  ///
  /// \code
  /// template<typename ...Types>
  /// struct count {
  ///   static const CX unsigned value = sizeof...(Types);
  /// };
  /// \endcode

  static const CXCursor_SizeOfPackExpr = 143;

  //// Represents a C++ lambda expression that produces a local function
  /// object.
  ///
  /// \code
  /// void abssort(float ///x, unsigned N) {
  ///   std::sort(x, x + N,
  ///             [](float a, float b) {
  ///               return std::abs(a) < std::abs(b);
  ///             });
  /// }
  /// \endcode

  static const CXCursor_LambdaExpr = 144;

  /// Objective-c Boolean Literal.

  static const CXCursor_ObjCBoolLiteralExpr = 145;

  /// Represents the "self" expression in an Objective-C method.

  static const CXCursor_ObjCSelfExpr = 146;

  /// OpenMP 4.0 [2.4;  Array Section].

  static const CXCursor_OMPArraySectionExpr = 147;

  /// Represents an @available(...) check.

  static const CXCursor_ObjCAvailabilityCheckExpr = 148;

  ///
  /// Fixed point literal

  static const CXCursor_FixedPointLiteral = 149;

  static const CXCursor_LastExpr = CXCursor_FixedPointLiteral;

  // Statements
  static const CXCursor_FirstStmt = 200;

  ///
  /// A statement whose specific kind is not exposed via this
  /// interface.
  ///
  /// Unexposed statements have the same operations as any other kind of
  /// statement; one can extract their location information, spelling,
  /// children, etc. However, the specific kind of the statement is not
  /// reported.

  static const CXCursor_UnexposedStmt = 200;

  /// A labelled statement in a function.
  ///
  /// This cursor kind is used to describe the "start_over:" label statement in
  /// the following example:
  ///
  /// \code
  ///   start_over:
  ///     ++counter;
  /// \endcode
  ///

  static const CXCursor_LabelStmt = 201;

  /// A group of statements like { stmt stmt }.
  ///
  /// This cursor kind is used to describe compound statements, e.g. function
  /// bodies.

  static const CXCursor_CompoundStmt = 202;

  /// A case statement.

  static const CXCursor_CaseStmt = 203;

  /// A default statement.

  static const CXCursor_DefaultStmt = 204;

  /// An if statement

  static const CXCursor_IfStmt = 205;

  /// A switch statement.

  static const CXCursor_SwitchStmt = 206;

  /// A while statement.

  static const CXCursor_WhileStmt = 207;

  /// A do statement.

  static const CXCursor_DoStmt = 208;

  /// A for statement.

  static const CXCursor_ForStmt = 209;

  /// A goto statement.

  static const CXCursor_GotoStmt = 210;

  /// An indirect goto statement.

  static const CXCursor_IndirectGotoStmt = 211;

  /// A continue statement.

  static const CXCursor_ContinueStmt = 212;

  /// A break statement.

  static const CXCursor_BreakStmt = 213;

  /// A return statement.

  static const CXCursor_ReturnStmt = 214;

  /// A GCC inline assembly statement extension.

  static const CXCursor_GCCAsmStmt = 215;
  static const CXCursor_AsmStmt = CXCursor_GCCAsmStmt;

  /// Objective-C's overall \@try-\@catch-\@finally statement.

  static const CXCursor_ObjCAtTryStmt = 216;

  /// Objective-C's \@catch statement.

  static const CXCursor_ObjCAtCatchStmt = 217;

  /// Objective-C's \@finally statement.

  static const CXCursor_ObjCAtFinallyStmt = 218;

  /// Objective-C's \@throw statement.

  static const CXCursor_ObjCAtThrowStmt = 219;

  /// Objective-C's \@synchronized statement.

  static const CXCursor_ObjCAtSynchronizedStmt = 220;

  /// Objective-C's autorelease pool statement.

  static const CXCursor_ObjCAutoreleasePoolStmt = 221;

  /// Objective-C's collection statement.

  static const CXCursor_ObjCForCollectionStmt = 222;

  /// C++'s catch statement.

  static const CXCursor_CXXCatchStmt = 223;

  /// C++'s try statement.

  static const CXCursor_CXXTryStmt = 224;

  /// C++'s for (/// : ///) statement.

  static const CXCursor_CXXForRangeStmt = 225;

  /// Windows Structured Exception Handling's try statement.

  static const CXCursor_SEHTryStmt = 226;

  /// Windows Structured Exception Handling's except statement.

  static const CXCursor_SEHExceptStmt = 227;

  /// Windows Structured Exception Handling's finally statement.

  static const CXCursor_SEHFinallyStmt = 228;

  /// A MS inline assembly statement extension.

  static const CXCursor_MSAsmStmt = 229;

  /// The null statement ";": C99 6.8.3p3.
  ///
  /// This cursor kind is used to describe the null statement.

  static const CXCursor_NullStmt = 230;

  /// Adaptor class for mixing declarations with statements and
  /// expressions.

  static const CXCursor_DeclStmt = 231;

  /// OpenMP parallel directive.

  static const CXCursor_OMPParallelDirective = 232;

  /// OpenMP SIMD directive.

  static const CXCursor_OMPSimdDirective = 233;

  /// OpenMP for directive.

  static const CXCursor_OMPForDirective = 234;

  /// OpenMP sections directive.

  static const CXCursor_OMPSectionsDirective = 235;

  /// OpenMP section directive.

  static const CXCursor_OMPSectionDirective = 236;

  /// OpenMP single directive.

  static const CXCursor_OMPSingleDirective = 237;

  /// OpenMP parallel for directive.

  static const CXCursor_OMPParallelForDirective = 238;

  /// OpenMP parallel sections directive.

  static const CXCursor_OMPParallelSectionsDirective = 239;

  /// OpenMP task directive.

  static const CXCursor_OMPTaskDirective = 240;

  /// OpenMP master directive.

  static const CXCursor_OMPMasterDirective = 241;

  /// OpenMP critical directive.

  static const CXCursor_OMPCriticalDirective = 242;

  /// OpenMP taskyield directive.

  static const CXCursor_OMPTaskyieldDirective = 243;

  /// OpenMP barrier directive.

  static const CXCursor_OMPBarrierDirective = 244;

  /// OpenMP taskwait directive.

  static const CXCursor_OMPTaskwaitDirective = 245;

  /// OpenMP flush directive.

  static const CXCursor_OMPFlushDirective = 246;

  /// Windows Structured Exception Handling's leave statement.

  static const CXCursor_SEHLeaveStmt = 247;

  /// OpenMP ordered directive.

  static const CXCursor_OMPOrderedDirective = 248;

  /// OpenMP atomic directive.

  static const CXCursor_OMPAtomicDirective = 249;

  /// OpenMP for SIMD directive.

  static const CXCursor_OMPForSimdDirective = 250;

  /// OpenMP parallel for SIMD directive.

  static const CXCursor_OMPParallelForSimdDirective = 251;

  /// OpenMP target directive.

  static const CXCursor_OMPTargetDirective = 252;

  /// OpenMP teams directive.

  static const CXCursor_OMPTeamsDirective = 253;

  /// OpenMP taskgroup directive.

  static const CXCursor_OMPTaskgroupDirective = 254;

  /// OpenMP cancellation point directive.

  static const CXCursor_OMPCancellationPointDirective = 255;

  /// OpenMP cancel directive.

  static const CXCursor_OMPCancelDirective = 256;

  /// OpenMP target data directive.

  static const CXCursor_OMPTargetDataDirective = 257;

  /// OpenMP taskloop directive.

  static const CXCursor_OMPTaskLoopDirective = 258;

  /// OpenMP taskloop simd directive.

  static const CXCursor_OMPTaskLoopSimdDirective = 259;

  /// OpenMP distribute directive.

  static const CXCursor_OMPDistributeDirective = 260;

  /// OpenMP target enter data directive.

  static const CXCursor_OMPTargetEnterDataDirective = 261;

  /// OpenMP target exit data directive.

  static const CXCursor_OMPTargetExitDataDirective = 262;

  /// OpenMP target parallel directive.

  static const CXCursor_OMPTargetParallelDirective = 263;

  /// OpenMP target parallel for directive.

  static const CXCursor_OMPTargetParallelForDirective = 264;

  /// OpenMP target update directive.

  static const CXCursor_OMPTargetUpdateDirective = 265;

  /// OpenMP distribute parallel for directive.

  static const CXCursor_OMPDistributeParallelForDirective = 266;

  /// OpenMP distribute parallel for simd directive.

  static const CXCursor_OMPDistributeParallelForSimdDirective = 267;

  /// OpenMP distribute simd directive.

  static const CXCursor_OMPDistributeSimdDirective = 268;

  /// OpenMP target parallel for simd directive.

  static const CXCursor_OMPTargetParallelForSimdDirective = 269;

  /// OpenMP target simd directive.

  static const CXCursor_OMPTargetSimdDirective = 270;

  /// OpenMP teams distribute directive.

  static const CXCursor_OMPTeamsDistributeDirective = 271;

  /// OpenMP teams distribute simd directive.

  static const CXCursor_OMPTeamsDistributeSimdDirective = 272;

  /// OpenMP teams distribute parallel for simd directive.

  static const CXCursor_OMPTeamsDistributeParallelForSimdDirective = 273;

  /// OpenMP teams distribute parallel for directive.

  static const CXCursor_OMPTeamsDistributeParallelForDirective = 274;

  /// OpenMP target teams directive.

  static const CXCursor_OMPTargetTeamsDirective = 275;

  /// OpenMP target teams distribute directive.

  static const CXCursor_OMPTargetTeamsDistributeDirective = 276;

  /// OpenMP target teams distribute parallel for directive.

  static const CXCursor_OMPTargetTeamsDistributeParallelForDirective = 277;

  /// OpenMP target teams distribute parallel for simd directive.

  static const CXCursor_OMPTargetTeamsDistributeParallelForSimdDirective = 278;

  /// OpenMP target teams distribute simd directive.

  static const CXCursor_OMPTargetTeamsDistributeSimdDirective = 279;

  /// C++2a std::bit_cast expression.

  static const CXCursor_BuiltinBitCastExpr = 280;

  /// OpenMP master taskloop directive.

  static const CXCursor_OMPMasterTaskLoopDirective = 281;

  /// OpenMP parallel master taskloop directive.

  static const CXCursor_OMPParallelMasterTaskLoopDirective = 282;

  /// OpenMP master taskloop simd directive.

  static const CXCursor_OMPMasterTaskLoopSimdDirective = 283;

  /// OpenMP parallel master taskloop simd directive.

  static const CXCursor_OMPParallelMasterTaskLoopSimdDirective = 284;

  /// OpenMP parallel master directive.

  static const CXCursor_OMPParallelMasterDirective = 285;

  static const CXCursor_LastStmt = CXCursor_OMPParallelMasterDirective;

  ///
  /// Cursor that represents the translation unit itself.
  ///
  /// The translation unit cursor exists primarily to act as the root
  /// cursor for traversing the contents of a translation unit.

  static const CXCursor_TranslationUnit = 300;

  // Attributes
  static const CXCursor_FirstAttr = 400;

  ///
  /// An attribute whose specific kind is not exposed via this
  /// interface.

  static const CXCursor_UnexposedAttr = 400;

  static const CXCursor_IBActionAttr = 401;
  static const CXCursor_IBOutletAttr = 402;
  static const CXCursor_IBOutletCollectionAttr = 403;
  static const CXCursor_CXXFinalAttr = 404;
  static const CXCursor_CXXOverrideAttr = 405;
  static const CXCursor_AnnotateAttr = 406;
  static const CXCursor_AsmLabelAttr = 407;
  static const CXCursor_PackedAttr = 408;
  static const CXCursor_PureAttr = 409;
  static const CXCursor_ConstAttr = 410;
  static const CXCursor_NoDuplicateAttr = 411;
  static const CXCursor_CUDAConstantAttr = 412;
  static const CXCursor_CUDADeviceAttr = 413;
  static const CXCursor_CUDAGlobalAttr = 414;
  static const CXCursor_CUDAHostAttr = 415;
  static const CXCursor_CUDASharedAttr = 416;
  static const CXCursor_VisibilityAttr = 417;
  static const CXCursor_DLLExport = 418;
  static const CXCursor_DLLImport = 419;
  static const CXCursor_NSReturnsRetained = 420;
  static const CXCursor_NSReturnsNotRetained = 421;
  static const CXCursor_NSReturnsAutoreleased = 422;
  static const CXCursor_NSConsumesSelf = 423;
  static const CXCursor_NSConsumed = 424;
  static const CXCursor_ObjCException = 425;
  static const CXCursor_ObjCNSObject = 426;
  static const CXCursor_ObjCIndependentClass = 427;
  static const CXCursor_ObjCPreciseLifetime = 428;
  static const CXCursor_ObjCReturnsInnerPointer = 429;
  static const CXCursor_ObjCRequiresSuper = 430;
  static const CXCursor_ObjCRootClass = 431;
  static const CXCursor_ObjCSubclassingRestricted = 432;
  static const CXCursor_ObjCExplicitProtocolImpl = 433;
  static const CXCursor_ObjCDesignatedInitializer = 434;
  static const CXCursor_ObjCRuntimeVisible = 435;
  static const CXCursor_ObjCBoxable = 436;
  static const CXCursor_FlagEnum = 437;
  static const CXCursor_ConvergentAttr = 438;
  static const CXCursor_WarnUnusedAttr = 439;
  static const CXCursor_WarnUnusedResultAttr = 440;
  static const CXCursor_AlignedAttr = 441;
  static const CXCursor_LastAttr = CXCursor_AlignedAttr;

  // Preprocessing
  static const CXCursor_PreprocessingDirective = 500;
  static const CXCursor_MacroDefinition = 501;
  static const CXCursor_MacroExpansion = 502;
  static const CXCursor_MacroInstantiation = CXCursor_MacroExpansion;
  static const CXCursor_InclusionDirective = 503;
  static const CXCursor_FirstPreprocessing = CXCursor_PreprocessingDirective;
  static const CXCursor_LastPreprocessing = CXCursor_InclusionDirective;

  // Extra Declarations
  ///
  /// A module import declaration.

  static const CXCursor_ModuleImportDecl = 600;
  static const CXCursor_TypeAliasTemplateDecl = 601;

  ///
  /// A static_assert or _Static_assert node

  static const CXCursor_StaticAssert = 602;

  ///
  /// a friend declaration.

  static const CXCursor_FriendDecl = 603;
  static const CXCursor_FirstExtraDecl = CXCursor_ModuleImportDecl;
  static const CXCursor_LastExtraDecl = CXCursor_FriendDecl;

  ///
  /// A code completion overload candidate.

  static const CXCursor_OverloadCandidate = 700;
}

class CXTypeKind {
  ///
  /// Represents an invalid type (e.g., where no type is available).

  static const CXType_Invalid = 0;

  ///
  /// A type whose specific kind is not exposed via this
  /// interface.

  static const CXType_Unexposed = 1;

  // Builtin types
  static const CXType_Void = 2;
  static const CXType_Bool = 3;
  static const CXType_Char_U = 4;
  static const CXType_UChar = 5;
  static const CXType_Char16 = 6;
  static const CXType_Char32 = 7;
  static const CXType_UShort = 8;
  static const CXType_UInt = 9;
  static const CXType_ULong = 10;
  static const CXType_ULongLong = 11;
  static const CXType_UInt128 = 12;

  /// char
  static const CXType_Char_S = 13;
  static const CXType_SChar = 14;
  static const CXType_WChar = 15;
  static const CXType_Short = 16;
  static const CXType_Int = 17;
  static const CXType_Long = 18;
  static const CXType_LongLong = 19;
  static const CXType_Int128 = 20;
  static const CXType_Float = 21;
  static const CXType_Double = 22;
  static const CXType_LongDouble = 23;
  static const CXType_NullPtr = 24;
  static const CXType_Overload = 25;
  static const CXType_Dependent = 26;
  static const CXType_ObjCId = 27;
  static const CXType_ObjCClass = 28;
  static const CXType_ObjCSel = 29;
  static const CXType_Float128 = 30;
  static const CXType_Half = 31;
  static const CXType_Float16 = 32;
  static const CXType_ShortAccum = 33;
  static const CXType_Accum = 34;
  static const CXType_LongAccum = 35;
  static const CXType_UShortAccum = 36;
  static const CXType_UAccum = 37;
  static const CXType_ULongAccum = 38;
  static const CXType_FirstBuiltin = CXType_Void;
  static const CXType_LastBuiltin = CXType_ULongAccum;

  static const CXType_Complex = 100;
  static const CXType_Pointer = 101;
  static const CXType_BlockPointer = 102;
  static const CXType_LValueReference = 103;
  static const CXType_RValueReference = 104;
  static const CXType_Record = 105;
  static const CXType_Enum = 106;
  static const CXType_Typedef = 107;
  static const CXType_ObjCInterface = 108;
  static const CXType_ObjCObjectPointer = 109;
  static const CXType_FunctionNoProto = 110;
  static const CXType_FunctionProto = 111;
  static const CXType_ConstantArray = 112;
  static const CXType_Vector = 113;
  static const CXType_IncompleteArray = 114;
  static const CXType_VariableArray = 115;
  static const CXType_DependentSizedArray = 116;
  static const CXType_MemberPointer = 117;
  static const CXType_Auto = 118;

  ///
  /// Represents a type that was referred to using an elaborated type keyword.
  ///
  /// E.g., struct S, or via a qualified name, e.g., N::M::type, or both.

  static const CXType_Elaborated = 119;

  // OpenCL PipeType.
  static const CXType_Pipe = 120;

  // OpenCL builtin types.
  static const CXType_OCLImage1dRO = 121;
  static const CXType_OCLImage1dArrayRO = 122;
  static const CXType_OCLImage1dBufferRO = 123;
  static const CXType_OCLImage2dRO = 124;
  static const CXType_OCLImage2dArrayRO = 125;
  static const CXType_OCLImage2dDepthRO = 126;
  static const CXType_OCLImage2dArrayDepthRO = 127;
  static const CXType_OCLImage2dMSAARO = 128;
  static const CXType_OCLImage2dArrayMSAARO = 129;
  static const CXType_OCLImage2dMSAADepthRO = 130;
  static const CXType_OCLImage2dArrayMSAADepthRO = 131;
  static const CXType_OCLImage3dRO = 132;
  static const CXType_OCLImage1dWO = 133;
  static const CXType_OCLImage1dArrayWO = 134;
  static const CXType_OCLImage1dBufferWO = 135;
  static const CXType_OCLImage2dWO = 136;
  static const CXType_OCLImage2dArrayWO = 137;
  static const CXType_OCLImage2dDepthWO = 138;
  static const CXType_OCLImage2dArrayDepthWO = 139;
  static const CXType_OCLImage2dMSAAWO = 140;
  static const CXType_OCLImage2dArrayMSAAWO = 141;
  static const CXType_OCLImage2dMSAADepthWO = 142;
  static const CXType_OCLImage2dArrayMSAADepthWO = 143;
  static const CXType_OCLImage3dWO = 144;
  static const CXType_OCLImage1dRW = 145;
  static const CXType_OCLImage1dArrayRW = 146;
  static const CXType_OCLImage1dBufferRW = 147;
  static const CXType_OCLImage2dRW = 148;
  static const CXType_OCLImage2dArrayRW = 149;
  static const CXType_OCLImage2dDepthRW = 150;
  static const CXType_OCLImage2dArrayDepthRW = 151;
  static const CXType_OCLImage2dMSAARW = 152;
  static const CXType_OCLImage2dArrayMSAARW = 153;
  static const CXType_OCLImage2dMSAADepthRW = 154;
  static const CXType_OCLImage2dArrayMSAADepthRW = 155;
  static const CXType_OCLImage3dRW = 156;
  static const CXType_OCLSampler = 157;
  static const CXType_OCLEvent = 158;
  static const CXType_OCLQueue = 159;
  static const CXType_OCLReserveID = 160;

  static const CXType_ObjCObject = 161;
  static const CXType_ObjCTypeParam = 162;
  static const CXType_Attributed = 163;

  static const CXType_OCLIntelSubgroupAVCMcePayload = 164;
  static const CXType_OCLIntelSubgroupAVCImePayload = 165;
  static const CXType_OCLIntelSubgroupAVCRefPayload = 166;
  static const CXType_OCLIntelSubgroupAVCSicPayload = 167;
  static const CXType_OCLIntelSubgroupAVCMceResult = 168;
  static const CXType_OCLIntelSubgroupAVCImeResult = 169;
  static const CXType_OCLIntelSubgroupAVCRefResult = 170;
  static const CXType_OCLIntelSubgroupAVCSicResult = 171;
  static const CXType_OCLIntelSubgroupAVCImeResultSingleRefStreamout = 172;
  static const CXType_OCLIntelSubgroupAVCImeResultDualRefStreamout = 173;
  static const CXType_OCLIntelSubgroupAVCImeSingleRefStreamin = 174;

  static const CXType_OCLIntelSubgroupAVCImeDualRefStreamin = 175;

  static const CXType_ExtVector = 176;
}
