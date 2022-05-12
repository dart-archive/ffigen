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

Future<void> _generateBindings(String config) async {
  final args = [
    'run',
    'ffigen',
    '--config',
    'test/native_objc_test/$config',
  ];
  final process =
      await Process.start(Platform.executable, args, workingDirectory: '../..');
  unawaited(stdout.addStream(process.stdout));
  unawaited(stderr.addStream(process.stderr));
  final result = await process.exitCode;
  if (result != 0) {
    throw ProcessException('dart', args, 'Generating bindings', result);
  }
  print('Generated bindings for: $config');
}

Future<void> main(List<String> arguments) async {
  if (!Platform.isMacOS) {
    throw OSError('Objective C tests are only supported on MacOS');
  }

  print('Building Dynamic Library for Objective C Native Tests...');
  await _buildLib('native_objc_test.m', 'native_objc_test.dylib');
  await _buildLib('cast_test.m', 'cast_test.dylib');
  await _buildLib('category_test.m', 'category_test.dylib');
  await _buildLib('method_test.m', 'method_test.dylib');
  await _buildLib('nullable_test.m', 'nullable_test.dylib');
  await _buildLib('property_test.m', 'property_test.dylib');
  await _buildLib('forward_decl_test.m', 'forward_decl_test.dylib');
  await _buildLib('string_test.m', 'string_test.dylib');
  await _buildLib('block_test.m', 'block_test.dylib');
  await _buildLib('rename_test.m', 'rename_test.dylib');

  print('Generating Bindings for Objective C Native Tests...');
  await _generateBindings('native_objc_config.yaml');
  await _generateBindings('cast_config.yaml');
  await _generateBindings('category_config.yaml');
  await _generateBindings('method_config.yaml');
  await _generateBindings('nullable_config.yaml');
  await _generateBindings('property_config.yaml');
  await _generateBindings('forward_decl_config.yaml');
  await _generateBindings('string_config.yaml');
  await _generateBindings('block_config.yaml');
  await _generateBindings('rename_config.yaml');
}
