// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A bindings generator for dart.
///
/// See complete usage at - https://pub.dev/packages/ffigen.
library ffigen;

export 'src/code_generator.dart' show Library;
export 'src/config_provider.dart' show Config, ConfigError;
export 'src/header_parser.dart' show parse;
