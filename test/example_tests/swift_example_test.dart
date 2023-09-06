// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Swift support is only available on mac.
@TestOn('mac-os')

import 'dart:async';
import 'dart:io';

import 'package:ffigen/src/header_parser.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('swift_example_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });

    test('swift', () async {
      // Run the swiftc command from the example README, to generate the header.
      final process = await Process.start(
          'swiftc',
          [
            '-c',
            'swift_api.swift',
            '-module-name',
            'swift_module',
            '-emit-objc-header-path',
            'third_party/swift_api.h',
            '-emit-library',
            '-o',
            'libswiftapi.dylib',
          ],
          workingDirectory: path.join(Directory.current.path, 'example/swift'));
      unawaited(stdout.addStream(process.stdout));
      unawaited(stderr.addStream(process.stderr));
      final result = await process.exitCode;
      expect(result, 0);

      final config = testConfigFromPath(path.join(
        'example',
        'swift',
        'config.yaml',
      ));
      final output = parse(config).generate();

      // Verify that the output contains all the methods and classes that the
      // example app uses.
      expect(output, contains('class SwiftLibrary{'));
      expect(output, contains('class NSString extends NSObject {'));
      expect(output, contains('class SwiftClass extends NSObject {'));
      expect(output, contains('static SwiftClass new1(SwiftLibrary _lib) {'));
      expect(output, contains('NSString sayHello() {'));
      expect(output, contains('int get someField {'));
      expect(output, contains('set someField(int value) {'));

      // Verify that SwiftClass is loaded using the swift_module prefix.
      expect(
          output,
          contains(RegExp(r'late final _class_SwiftClass.* = '
              r'_getClass.*\("swift_module\.SwiftClass"\)')));
    });
  });
}
