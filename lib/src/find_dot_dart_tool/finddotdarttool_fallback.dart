// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform, File;

/// Find the `.dart_tool/` folder, returns `null` if unable to find it.
Uri findDotDartTool() {
  // HACK: Because 'dart:isolate' is unavailable in Flutter we have no means
  //       by which we can find the location of the package_config.json file.
  //       Which we need, because the binary library created by:
  //         flutter pub run ffigen:setup
  //       is located relative to this path. As a workaround we use
  //       `Platform.script` and traverse level-up until we find a
  //       `.dart_tool/package_config.json` file.
  // Find script directory
  var root = Platform.script.resolve('./');
  // Traverse up until we see a `.dart_tool/package_config.json` file.
  do {
    if (File.fromUri(root.resolve('.dart_tool/package_config.json'))
        .existsSync()) {
      return root.resolve('.dart_tool/');
    }
  } while (root != (root = root.resolve('..')));
  return null;
}
