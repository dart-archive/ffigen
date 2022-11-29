// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'package:ffigen/src/header_parser.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('objective_c_example_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });

    test('objective_c', () {
      final config = testConfig('''
${strings.name}: AVFAudio
${strings.description}: Bindings for AVFAudio.
${strings.language}: objc
${strings.output}: 'avf_audio_bindings.dart'
${strings.excludeAllByDefault}: true
${strings.objcInterfaces}:
  ${strings.include}:
    - 'AVAudioPlayer'
${strings.headers}:
  ${strings.entryPoints}:
    - '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/AVFAudio.framework/Headers/AVAudioPlayer.h'
${strings.preamble}: |
  // ignore_for_file: camel_case_types, non_constant_identifier_names, unused_element, unused_field, return_of_invalid_type, void_checks, annotate_overrides, no_leading_underscores_for_local_identifiers, library_private_types_in_public_api
''');
      final output = parse(config).generate();

      // Verify that the output contains all the methods and classes that the
      // example app uses.
      expect(output, contains('class AVFAudio{'));
      expect(output, contains('class NSString extends NSObject {'));
      expect(output, contains('class NSURL extends NSObject {'));
      expect(
          output,
          contains(
              'static NSURL fileURLWithPath_(AVFAudio _lib, NSString? path) {'));
      expect(output, contains('class AVAudioPlayer extends NSObject {'));
      expect(
          output,
          contains('AVAudioPlayer initWithContentsOfURL_error_('
              'NSURL? url, ffi.Pointer<ffi.Pointer<ObjCObject>> outError) {'));
      expect(output, contains('double get duration {'));
      expect(output, contains('bool play() {'));
    });
  });
}
