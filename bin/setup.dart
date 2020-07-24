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
/// clang -I/usr/lib/llvm-9/include/ -I/usr/lib/llvm-10/include/ -lclang -shared -fpic path/to/wrapper.c -o path/to/libwrapped_clang.so
/// ```
/// MacOS:
/// ```
/// clang -I/usr/local/opt/llvm/include/ -L/usr/local/opt/llvm/lib/ -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/ -v -lclang -shared -fpic path/to/wrapper.c -o path/to/libwrapped_clang.dylib
/// ```
/// Windows:
/// ```
/// clang -IC:\Progra~1\LLVM\include -LC:\Progra~1\LLVM\lib -llibclang -shared path/to/wrapper.c -o path/to/wrapped_clang.dll -Wl,/DEF:path/to/wrapper.def
/// ```
/// =======================================================================
/// =======================================================================
/// =======================================================================

import 'dart:io';
import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:ffigen/src/find_resource.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:path/path.dart' as path;

const _macOS = 'macos';
const _windows = 'windows';
const _linux = 'linux';

/// Default platform options.
Map<String, _Options> _platformOptions = {
  _linux: _Options(
    sharedFlag: '-shared',
    inputHeader: _getWrapperPath('wrapper.c'),
    fPIC: '-fpic',
    ldLibFlag: '-lclang',
    headerIncludes: [
      '-I/usr/lib/llvm-9/include/',
      '-I/usr/lib/llvm-10/include/',
    ],
  ),
  _windows: _Options(
    sharedFlag: '-shared',
    inputHeader: _getWrapperPath('wrapper.c'),
    moduleDefPath: '-Wl,/DEF:${_getWrapperPath("wrapper.def")}',
    ldLibFlag: '-llibclang',
    headerIncludes: [
      r'-IC:\Progra~1\LLVM\include',
    ],
    libIncludes: [
      r'-LC:\Progra~1\LLVM\lib',
    ],
  ),
  _macOS: _Options(
    sharedFlag: '-shared',
    inputHeader: _getWrapperPath('wrapper.c'),
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

/// If main is called directly we always re-create the dynamic library.
void main(List<String> arguments) {
  // Parses the cmd args. This will print usage and exit if --help was passed.
  final argResults = _getArgResults(arguments);

  print('Building Dynamic Library for libclang wrapper...');
  final options = _getPlatformOptions();
  _deleteOldDylib();

  // Updates header/lib includes in platform options.
  _changeIncludesUsingCmdArgs(argResults, options);

  // Run clang compiler to generate the dynamic library.
  final processResult = _runClangProcess(options);
  _printDetails(processResult, options);
}

/// Returns true if auto creating dylib was successful.
///
/// This will fail if llvm is not in default directories or if .dart_tool
/// doesn't exist.
bool autoCreateDylib() {
  _deleteOldDylib();
  final options = _getPlatformOptions();
  final processResult = _runClangProcess(options);
  if ((processResult.stderr as String).isNotEmpty) {
    print(stderr);
  }
  return checkDylibExist();
}

bool checkDylibExist() {
  return File(path.join(
    _getDotDartToolPath(),
    strings.ffigenFolderName,
    strings.dylibFileName,
  )).existsSync();
}

/// Removes old dynamic libraries(if any) by deleting .dart_tool/ffigen.
///
/// Throws error if '.dart_tool' is not found.
void _deleteOldDylib() {
  // Find .dart_tool.
  final dtpath = _getDotDartToolPath();
  // Find .dart_tool/ffigen and delete recursively if it exists.
  final ffigenDir = Directory(path.join(dtpath, strings.ffigenFolderName));
  if (ffigenDir.existsSync()) ffigenDir.deleteSync(recursive: true);
}

/// Creates necesarry parent folders and return full path to dylib.
String _dylibPath() {
  // Find .dart_tool.
  final dtpath = _getDotDartToolPath();
  // Create .dart_tool/ffigen if it doesn't exists.
  final ffigenDir = Directory(path.join(dtpath, strings.ffigenFolderName));
  if (!ffigenDir.existsSync()) ffigenDir.createSync();

  // Return dylib path
  return path.join(ffigenDir.absolute.path, strings.dylibFileName);
}

/// Returns full path of the wrapper files.
///
/// Throws error if not found.
String _getWrapperPath(String wrapperName) {
  final file = File.fromUri(findWrapper(wrapperName));
  if (file.existsSync()) {
    return file.absolute.path;
  } else {
    throw Exception('Unable to find $wrapperName file.');
  }
}

/// Gets full path to .dart_tool.
///
/// Throws Exception if not found.
String _getDotDartToolPath() {
  final dtpath = findDotDartTool()?.toFilePath();
  if (dtpath == null) {
    throw Exception('.dart_tool not found.');
  }
  return dtpath;
}

/// Calls the clang compiler.
ProcessResult _runClangProcess(_Options options) {
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
      _dylibPath(),
      options.moduleDefPath,
      '-Wno-nullability-completeness',
    ],
  );
  return result;
}

/// Prints success message (or process error if any).
void _printDetails(ProcessResult result, _Options options) {
  print(result.stdout);
  if ((result.stderr as String).isNotEmpty) {
    print(result.stderr);
  } else {
    print('Created dynamic library.');
  }
}

ArgResults _getArgResults(List<String> args) {
  final parser = ArgParser(allowTrailingOptions: true);
  parser.addSeparator('Generates LLVM Wrapper used by this package:');
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
void _changeIncludesUsingCmdArgs(ArgResults argResult, _Options options) {
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
_Options _getPlatformOptions() {
  if (Platform.isMacOS) {
    return _platformOptions[_macOS];
  } else if (Platform.isWindows) {
    return _platformOptions[_windows];
  } else if (Platform.isLinux) {
    return _platformOptions[_linux];
  } else {
    throw Exception('Unknown Platform.');
  }
}

/// Hold options which would be passed to clang.
class _Options {
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

  _Options({
    @required this.sharedFlag,
    @required this.inputHeader,
    @required this.ldLibFlag,
    this.headerIncludes = const [],
    this.libIncludes = const [],
    this.fPIC = '',
    this.moduleDefPath = '',
  });
}
