// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:cli' as cli;
import 'dart:io' show File;
import 'dart:isolate' show Isolate;
import 'finddotdarttool_fallback.dart' as fallback;

/// Find the `.dart_tool/` folder, returns `null` if unable to find it.
Uri findDotDartTool() {
  // Find [Isolate.packageConfig] and check if contains:
  //  * `package_config.json`, or,
  //  * `.dart_tool/package_config.json`.
  // If either is the case we know the path to `.dart_tool/`.
  final packageConfig = cli.waitFor(Isolate.packageConfig);
  if (packageConfig != null &&
      File.fromUri(packageConfig.resolve('package_config.json')).existsSync()) {
    return packageConfig.resolve('./');
  }
  if (packageConfig != null &&
      File.fromUri(packageConfig.resolve('.dart_tool/package_config.json'))
          .existsSync()) {
    return packageConfig.resolve('.dart_tool/');
  }
  // If [Isolate.packageConfig] isn't helpful we fallback to looking at the
  // current script location and traverse up from there.
  return fallback.findDotDartTool();
}
