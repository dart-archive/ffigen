// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

Future<void> _buildLib(String input, String output) async {
  final args = [
    '-shared',
    '-fpic',
    '-x',
    'objective-c',
    input,
    '-framework',
    'Foundation',
    '-o',
    output,
  ];
  final process = await Process.start('clang', args);
  unawaited(stdout.addStream(process.stdout));
  unawaited(stderr.addStream(process.stderr));
  final result = await process.exitCode;
  if (result != 0) {
    throw ProcessException('clang', args, 'Build failed', result);
  }
  print('Generated file: $output');
}

Future<void> main(List<String> arguments) async {
  if (!Platform.isMacOS) {
    throw OSError('Objective C tests are only supported on MacOS');
  }
  print('Building Dynamic Library for Objective C Native Tests...');
  await _buildLib('native_objc_test.m', 'native_objc_test.dylib');
  await _buildLib('method_test.m', 'method_test.dylib');
  await _buildLib('property_test.m', 'property_test.dylib');
  await _buildLib('string_test.m', 'string_test.dylib');
}
