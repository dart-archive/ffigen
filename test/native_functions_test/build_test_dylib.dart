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

import 'package:meta/meta.dart';

const MACOS = 'macos';
const WINDOWS = 'windows';
const LINUX = 'linux';

Map<String, Options> platformOptions = {
  LINUX: Options(
    outputfilename: 'native_functions.so',
    sharedFlag: '-shared',
    inputHeader: 'native_functions.c',
    fPIC: '-fpic',
  ),
  WINDOWS: Options(
    outputfilename: 'native_functions.dll',
    sharedFlag: '-shared',
    inputHeader: 'native_functions.c',
    moduleDefPath: '-Wl,/DEF:native_functions.def',
  ),
  MACOS: Options(
    outputfilename: 'native_functions.dylib',
    sharedFlag: '-shared',
    inputHeader: 'native_functions.c',
    fPIC: '-fpic',
  ),
};

void main(List<String> arguments) {
  print('Building Dynamic Library for Native Tests... ');
  final options = getPlatformOptions();

  // Run clang compiler to generate the dynamic library.
  final ProcessResult result = runClangProcess(options);
  printSuccess(result, options);
}

/// Calls the clang compiler.
ProcessResult runClangProcess(Options options) {
  final result = Process.runSync(
    'clang',
    [
      options.sharedFlag,
      options.fPIC,
      options.inputHeader,
      '-o',
      options.outputfilename,
      options.moduleDefPath,
    ],
  );
  return result;
}

/// Prints success message (or process error if any).
void printSuccess(ProcessResult result, Options options) {
  print(result.stdout);
  if ((result.stderr as String).isEmpty) {
    print('Generated file: ${options.outputfilename}');
  } else {
    print(result.stderr);
  }
}

/// Get options based on current platform.
Options getPlatformOptions() {
  if (Platform.isMacOS) {
    return platformOptions[MACOS];
  } else if (Platform.isWindows) {
    return platformOptions[WINDOWS];
  } else if (Platform.isLinux) {
    return platformOptions[LINUX];
  } else {
    throw Exception('Unknown Platform.');
  }
}

/// Hold options which would be passed to clang.
class Options {
  /// Name of dynamic library to generate.
  final String outputfilename;

  /// Tells compiler to generate a shared library.
  final String sharedFlag;

  /// Flag for generating Position Independant Code (Not used on windows).
  final String fPIC;

  /// Input file.
  final String inputHeader;

  /// Path to `.def` file containing symbols to export, windows use only.
  final String moduleDefPath;

  Options({
    @required this.outputfilename,
    @required this.sharedFlag,
    @required this.inputHeader,
    this.fPIC = '',
    this.moduleDefPath = '',
  });
}
