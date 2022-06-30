// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Runs all the test setup scripts. Usage:
// dart run test/setup.dart

import 'dart:async';
import 'dart:io';

Future<void> _run(String subdir, String script) async {
  final dir = Platform.script.resolve('$subdir/');
  print('\nRunning $script in ${dir.toFilePath()}');
  final args = ['run', dir.resolve(script).toFilePath()];
  final process = await Process.start(
    Platform.executable,
    args,
    workingDirectory: dir.toFilePath(),
  );
  unawaited(stdout.addStream(process.stdout));
  unawaited(stderr.addStream(process.stderr));
  final result = await process.exitCode;
  if (result != 0) {
    throw ProcessException(Platform.executable, args, '$script failed', result);
  }
}

Future<void> main() async {
  await _run('native_test', 'build_test_dylib.dart');
  if (Platform.isMacOS) {
    await _run('native_objc_test', 'setup.dart');
  }
  print('\nSuccess :)\n');
}
