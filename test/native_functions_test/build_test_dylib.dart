// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// =======================================================================
/// ==== Script to generate dynamic library for native_function_tests =====
/// =======================================================================
/// This Script effectively calls the following (but user can provide
/// command line args which will replace the defaults shown below)-
///
/// Linux:
/// ```
/// clang -shared -fpic native_functions.c -o native_functions.so
/// ```
/// MacOS:
/// ```
/// clang -shared -fpic native_functions.c -o native_functions.dylib
/// ```
/// Windows:
/// ```
/// call clang -shared native_functions.c -o native_functions.dll -Wl,"/DEF:native_functions.def"
/// del native_functions.exp
/// del native_functions.lib
/// ```
/// =======================================================================
/// =======================================================================
/// =======================================================================

import 'dart:io';

// Default values are for linux.
// Name of dynamic library to generate.
String outputfilename = 'native_functions.so';

// Tells compiler to generate a shared library.
String sharedFlag = '-shared';

// Flag for generating Position Independant Code (Not used on windows).
String fPIC = '-fpic';

// Input file.
String inputHeader = 'native_functions.c';

// Path to `.def` file containing symbols to export, windows use only.
String moduleDefPath = '';

void main(List<String> arguments) {
  print('Building Dynamic Library for Native Tests... ');
  changeDefaultsBasedOnPlatform();

  // Run clang compiler to generate the dynamic library.
  final ProcessResult result = runClangProcess();
  printSuccess(result);
}

/// Calls the clang compiler.
ProcessResult runClangProcess() {
  final result = Process.runSync(
    'clang',
    [
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

/// Changing defaults for Mac and Windows.
void changeDefaultsBasedOnPlatform() {
  if (Platform.isMacOS) {
    outputfilename = 'native_functions.dylib';
  } else if (Platform.isWindows) {
    outputfilename = 'native_functions.dll';
    moduleDefPath = '-Wl,/DEF:native_functions.def';
    fPIC = '';
  }
}
