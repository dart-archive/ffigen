// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Swift support is only available on mac.
@TestOn('mac-os')

import 'dart:async';
import 'dart:io';

import 'package:ffigen/src/header_parser.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
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
            'swift_api.h',
            '-emit-library',
            '-o',
            'libswiftapi.dylib',
          ],
          workingDirectory: p.join(Directory.current.path, 'example/swift'));
      unawaited(stdout.addStream(process.stdout));
      unawaited(stderr.addStream(process.stderr));
      final result = await process.exitCode;
      expect(result, 0);

      final config = testConfig('''
${strings.name}: SwiftLibrary
${strings.description}: Bindings for swift_api.
${strings.language}: objc
${strings.output}: 'swift_api_bindings.dart'
${strings.excludeAllByDefault}: true
${strings.objcInterfaces}:
  ${strings.include}:
    - 'SwiftClass'
  ${strings.objcModule}:
    'SwiftClass': 'swift_module'
${strings.headers}:
  ${strings.entryPoints}:
    - 'example/swift/swift_api.h'
${strings.preamble}: |
  // ignore_for_file: camel_case_types, non_constant_identifier_names
  // ignore_for_file: unused_element, unused_field, return_of_invalid_type
  // ignore_for_file: void_checks, annotate_overrides
  // ignore_for_file: no_leading_underscores_for_local_identifiers
  // ignore_for_file: library_private_types_in_public_api
''');
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
