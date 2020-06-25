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
import 'package:meta/meta.dart';

const MACOS = 'macos';
const WINDOWS = 'windows';
const LINUX = 'linux';

/// Default platform options.
Map<String, Options> platformOptions = {
  LINUX: Options(
    outputfilename: 'libwrapped_clang.so',
    sharedFlag: '-shared',
    inputHeader: 'wrapper.c',
    fPIC: '-fpic',
    ldLibFlag: '-lclang',
    headerIncludes: [
      '-I/usr/lib/llvm-9/include/',
      '-I/usr/lib/llvm-10/include/',
    ],
  ),
  WINDOWS: Options(
    outputfilename: 'wrapped_clang.dll',
    sharedFlag: '-shared',
    inputHeader: 'wrapper.c',
    moduleDefPath: '-Wl,/DEF:wrapper.def',
    ldLibFlag: '-llibclang',
    headerIncludes: [
      r'-IC:\Progra~1\LLVM\include',
    ],
    libIncludes: [
      r'-LC:\Progra~1\LLVM\lib',
    ],
  ),
  MACOS: Options(
    outputfilename: 'libwrapped_clang.dylib',
    sharedFlag: '-shared',
    inputHeader: 'wrapper.c',
    fPIC: '-fpic',
    ldLibFlag: '-lclang',
    headerIncludes: [
      '-I/usr/local/opt/llvm/include/',
      '-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/',
    ],
    libIncludes: [
      '-L/usr/local/opt/llvm/lib/',
    ],
  ),
};

void main(List<String> arguments) {
  print('Building Dynamic Library for libclang wrapper... ');
  final options = getPlatformOptions();

  // Updates header/lib includes in platform options.
  changeIncludesUsingCmdArgs(arguments, options);

  // Run clang compiler to generate the dynamic library.
  final ProcessResult result = runClangProcess(options);
  printSuccess(result, options);
}

/// Calls the clang compiler.
ProcessResult runClangProcess(Options options) {
  final result = Process.runSync(
    'clang',
    [
      ...options.headerIncludes,
      ...options.libIncludes,
      options.ldLibFlag,
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

/// Use cmd args(if any) to change header/lib include paths.
void changeIncludesUsingCmdArgs(List<String> arguments, Options options) {
  final argResult = getArgResults(arguments);
  if (argResult.wasParsed('include-header')) {
    options.headerIncludes = (argResult['include-header'] as List<String>)
        .map((header) => '-I$header')
        .toList();
  }
  if (argResult.wasParsed('include-lib')) {
    options.libIncludes = (argResult['include-lib'] as List<String>)
        .map((lib) => '-L$lib')
        .toList();
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

  /// Path to header files.
  List<String> headerIncludes;

  /// Path to dynamic/static libraries
  List<String> libIncludes;

  /// Linker flag for linking to libclang.
  final String ldLibFlag;

  Options({
    @required this.outputfilename,
    @required this.sharedFlag,
    @required this.inputHeader,
    @required this.ldLibFlag,
    this.headerIncludes = const [],
    this.libIncludes = const [],
    this.fPIC = '',
    this.moduleDefPath = '',
  });
}
