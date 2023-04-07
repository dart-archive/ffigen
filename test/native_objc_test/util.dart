// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

Future<void> generateBindingsForCoverage(String testName) async {
  // The ObjC test bindings are generated in setup.dart (see #362), which means
  // that the ObjC related bits of ffigen are missed by test coverage. So this
  // function just regenerates those bindings. It doesn't test anything except
  // that the generation succeeded, by asserting the file exists.
  final config = await testConfigFromPath(
      path.join('test', 'native_objc_test', '${testName}_config.yaml'));
  final library = await parse(config);
  final file = File(
    path.join('test', 'debug_generated', '${testName}_test.dart'),
  );
  await library.generateFile(file);
  assert(await file.exists());
  await file.delete();
}
