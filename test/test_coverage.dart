// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'code_generator_test.dart' as code_generator_test;
import 'collision_tests/decl_decl_collision_test.dart'
    as collision_tests_decl_decl_collision_test;
import 'collision_tests/reserved_keyword_collision_test.dart'
    as collision_tests_reserved_keyword_collision_test;
import 'example_tests/cjson_example_test.dart'
    as example_tests_cjson_example_test;
import 'example_tests/libclang_example_test.dart'
    as example_tests_libclang_example_test;
import 'example_tests/simple_example_test.dart'
    as example_tests_simple_example_test;
import 'header_parser_tests/function_n_struct_test.dart'
    as header_parser_tests_function_n_struct_test;
import 'header_parser_tests/functions_test.dart'
    as header_parser_tests_functions_test;
import 'header_parser_tests/macros_test.dart'
    as header_parser_tests_macros_test;
import 'header_parser_tests/nested_parsing_test.dart'
    as header_parser_tests_nested_parsing_test;
import 'header_parser_tests/typedef_test.dart'
    as header_parser_tests_typedef_test;
import 'header_parser_tests/unnamed_enums_test.dart'
    as header_parser_tests_unnamed_enums_test;
import 'large_integration_tests/large_test.dart'
    as large_integration_tests_large_test;
import 'native_test/native_test.dart' as native_test_native_test;
import 'rename_tests/rename_test.dart' as rename_tests_rename_test;

void main() {
  large_integration_tests_large_test.main();
  example_tests_cjson_example_test.main();
  example_tests_simple_example_test.main();
  example_tests_libclang_example_test.main();
  collision_tests_decl_decl_collision_test.main();
  collision_tests_reserved_keyword_collision_test.main();
  header_parser_tests_functions_test.main();
  header_parser_tests_macros_test.main();
  header_parser_tests_function_n_struct_test.main();
  header_parser_tests_nested_parsing_test.main();
  header_parser_tests_typedef_test.main();
  header_parser_tests_unnamed_enums_test.main();
  native_test_native_test.main();
  rename_tests_rename_test.main();
  code_generator_test.main();
}
