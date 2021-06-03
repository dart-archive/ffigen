// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/header_parser.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../test_utils.dart';

void main() {
  group('cjson_example_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });
    test('c_json', () {
      final config = Config.fromYaml(loadYaml('''
${strings.output}: 'cjson_generated_bindings.dart'
${strings.name}: 'CJson'
${strings.description}: 'Holds bindings to cJSON.'
${strings.headers}:
  ${strings.entryPoints}:
    - 'third_party/cjson_library/cJSON.h'
  ${strings.includeDirectives}:
    - '**cJSON.h'
${strings.comments}: false
${strings.typedefmap}:
  'size_t': 'IntPtr'
${strings.preamble}: |
  // Copyright (c) 2009-2017 Dave Gamble and cJSON contributors
  //
  // Permission is hereby granted, free of charge, to any person obtaining a copy
  // of this software and associated documentation files (the "Software"), to deal
  // in the Software without restriction, including without limitation the rights
  // to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  // copies of the Software, and to permit persons to whom the Software is
  // furnished to do so, subject to the following conditions:
  //
  // The above copyright notice and this permission notice shall be included in
  // all copies or substantial portions of the Software.
  //
  // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  // IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  // FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  // AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  // LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  // OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  // THE SOFTWARE.
''') as YamlMap);
      final library = parse(config);

      matchLibraryWithExpected(
        library,
        ['test', 'debug_generated', 'example_c_json.dart'],
        ['example', 'c_json', config.output],
      );
    });
  });
}
