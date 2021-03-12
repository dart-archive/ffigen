// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utils for finding header paths on system.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

final _logger = Logger('ffigen.config_provider.path_finder');

/// This will return include path from either LLVM, XCode or CommandLineTools.
List<String> getHeadersForMac() {
  /// Find headers from XCode or LLVM installed via brew.
  const brewLlvmPath = '/usr/local/opt/llvm/lib/clang';
  const xcodeClangPath =
      '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/';
  const searchPaths = [brewLlvmPath, xcodeClangPath];
  for (final searchPath in searchPaths) {
    if (!Directory(searchPath).existsSync()) continue;

    final result = Process.runSync('ls', [searchPath]);
    final stdout = result.stdout as String;
    if (stdout != '') {
      final versions = stdout.split('\n').where((s) => s != '');
      for (final version in versions) {
        final path = p.join(searchPath, version, 'include');
        if (Directory(path).existsSync()) {
          _logger.fine('Added stdlib path: $path to compiler-opts.');
          return ['-I' + path];
        }
      }
    }
  }

  /// If CommandLineTools are installed use those headers.
  const cmdLineToolHeaders =
      '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/Kernel.framework/Headers/';
  if (Directory(cmdLineToolHeaders).existsSync()) {
    _logger.fine('Added stdlib path: $cmdLineToolHeaders to compiler-opts.');
    return ['-I' + cmdLineToolHeaders];
  }

  // Warnings for missing headers are printed by libclang while parsing.
  _logger.fine('Couldn\'t find stdlib headers in default locations.');
  _logger.fine('Paths searched: ${[cmdLineToolHeaders, ...searchPaths]}');

  return [];
}
