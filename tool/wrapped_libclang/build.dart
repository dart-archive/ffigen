// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// =======================================================================
/// =============== Build script to generate dyamic library ===============
/// =======================================================================
/// This Script effectively calls the following (but user can provide
/// command line args which will replace the defaults shown below)-
///
/// Linux:
/// ```
/// clang -I/usr/lib/llvm-9/include/ -I/usr/lib/llvm-10/include/ -lclang -shared -fpic wrapper.c -o libwrapped_clang.so
/// ```
/// MacOS:
/// ```
/// clang -I/usr/local/opt/llvm/include/ -L/usr/local/opt/llvm/lib/ -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/ -v -lclang -shared -fpic wrapper.c -o libwrapped_clang.dylib
/// ```
/// Windows:
/// ```
/// clang -IC:\Progra~1\LLVM\include -LC:\Progra~1\LLVM\lib -llibclang -shared wrapper.c -o wrapped_clang.dll -Wl,/DEF:wrapper.def
/// del wrapped_clang.exp
/// del wrapped_clang.lib
/// ```
/// =======================================================================
/// =======================================================================
/// =======================================================================

import 'dart:io';
import 'package:args/args.dart';

// Default values are for linux.
// Name of dynamic library to generate.
String outputfilename = 'libwrapped_clang.so';

// linker flag to link with libclang dynamic library.
String ldLibFlag = '-lclang';

// Tells compiler to generate a shared library
String sharedFlag = '-shared';

// Flag for generating Position Independant Code (Not used on windows)
String fPIC = '-fpic';

// Input file.
String inputHeader = 'wrapper.c';

// Path to header files.
List<String> headerIncludes = [
  '-I/usr/lib/llvm-9/include/',
  '-I/usr/lib/llvm-10/include/'
];

// Path to dynamic/static libraries
List<String> libIncludes = [];

// Path to `.def` file containing symbols to export, windows use only.
String moduleDefPath = '';

void main(List<String> arguments) {
  print('Building Dynamic Library for libclang wrapper... ');
  changeDefaultsBasedOnPlatform();
  changeIncludesUsingCmdArgs(arguments);

  // Run clang compiler to generate the dynamic library.
  final ProcessResult result = runClangProcess();
  printSuccess(result);
}

/// Calls the clang compiler.
ProcessResult runClangProcess() {
  final result = Process.runSync(
    'clang',
    [
      ...headerIncludes,
      ...libIncludes,
      ldLibFlag,
      sharedFlag,
      fPIC,
      inputHeader,
      '-o',
      outputfilename,
      moduleDefPath,
    ],
  );
  return result;
}

/// Prints success message (or process error if any).
void printSuccess(ProcessResult result) {
  print(result.stdout);
  if ((result.stderr as String).isEmpty) {
    print('Generated file: $outputfilename');
  } else {
    print(result.stderr);
  }
}

/// Use cmd args(if any) to change default paths.
void changeIncludesUsingCmdArgs(List<String> arguments) {
  final argResult = getArgResults(arguments);
  if (argResult.wasParsed('include-header')) {
    headerIncludes = (argResult['include-header'] as List<String>)
        .map((header) => '-I$header')
        .toList();
  }
  if (argResult.wasParsed('include-lib')) {
    libIncludes = (argResult['include-lib'] as List<String>)
        .map((lib) => '-L$lib')
        .toList();
  }
}

/// Changing defaults for Mac and Windows.
void changeDefaultsBasedOnPlatform() {
  if (Platform.isMacOS) {
    outputfilename = 'libwrapped_clang.dylib';
    headerIncludes = [
      '-I/usr/local/opt/llvm/include/',
      '-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/'
    ];
    libIncludes = ['-L/usr/local/opt/llvm/lib/'];
  } else if (Platform.isWindows) {
    outputfilename = 'wrapped_clang.dll';
    headerIncludes = [r'-IC:\Progra~1\LLVM\include'];
    libIncludes = [r'-LC:\Progra~1\LLVM\lib'];
    ldLibFlag = '-llibclang';
    moduleDefPath = '-Wl,/DEF:wrapper.def';
    fPIC = '';
  }
}

ArgResults getArgResults(List<String> args) {
  final parser = ArgParser(allowTrailingOptions: true);
  parser.addSeparator(
      'Build Script to generate dynamic library used by this package:');
  parser.addMultiOption('include-header',
      abbr: 'I', help: 'Path to header include directories');
  parser.addMultiOption('include-lib',
      abbr: 'L', help: 'Path to library include directories');
  parser.addFlag(
    'help',
    abbr: 'h',
    help: 'prints this usage',
    negatable: false,
  );

  ArgResults results;
  try {
    results = parser.parse(args);

    if (results.wasParsed('help')) {
      print(parser.usage);
      exit(0);
    }
  } catch (e) {
    print(e);
    print(parser.usage);
    exit(1);
  }

  return results;
}
