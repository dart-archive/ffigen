// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert' show jsonDecode;
import 'dart:io' show File, Directory;

import 'package:ffigen/src/strings.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

final _logger = Logger('ffigen.find_resource');

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
  var root = Directory.current.uri;
  // Traverse up until we see a `.dart_tool/package_config.json` file.
  do {
    if (File.fromUri(root.resolve('.dart_tool/package_config.json'))
        .existsSync()) {
      return root.resolve('.dart_tool/');
    }
  } while (root != (root = root.resolve('..')));
  return null;
}

Uri findWrapper(String wrapperName) {
  var root = Directory.current.uri;
  // Traverse up until we see a `.dart_tool/package_config.json` file.
  do {
    final file = File.fromUri(root.resolve('.dart_tool/package_config.json'));
    if (file.existsSync()) {
      /// Read the package_config.json file to extract path of wrapper.
      try {
        final packageMap =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        if (packageMap['configVersion'] == 2) {
          var ffigenRootUriString = ((packageMap['packages'] as List<dynamic>)
                  .cast<Map<String, dynamic>>()
                  .firstWhere(
                      (element) => element['name'] == 'ffigen')['rootUri']
              as String);
          ffigenRootUriString = ffigenRootUriString.endsWith('/')
              ? ffigenRootUriString
              : ffigenRootUriString + '/';

          /// [ffigenRootUri] can be relative to .dart_tool if its from
          /// filesystem so we need to resolve it from .dart_tool first.
          return file.parent.uri
              .resolve(ffigenRootUriString)
              .resolve('lib/src/clang_library/$wrapperName');
        }
      } catch (e, s) {
        print(s);
        throw Exception('Cannot resolve package:ffigen\'s rootUri.');
      }
    }
  } while (root != (root = root.resolve('..')));
  return null;
}

Uri _findPubspecLock() {
  var root = Directory.current.uri;
  // Traverse up until we see a `.dart_tool/package_config.json` file.
  do {
    final file = File.fromUri(root.resolve('.dart_tool/package_config.json'));
    if (file.existsSync()) {
      return root.resolve('pubspec.lock');
    }
  } while (root != (root = root.resolve('..')));
  return null;
}

String _ffigenVersion;

/// Gets ffigen version from pubspec.lock file.
String get ffigenVersion {
  if (_ffigenVersion == null) {
    try {
      final yaml = loadYaml(File.fromUri(_findPubspecLock()).readAsStringSync())
          as YamlMap;
      final rawVersion = yaml['packages']['ffigen']['version'] as String;
      // Sanitize name to be used as a file name.
      _ffigenVersion =
          'v_${rawVersion.replaceAll('.', '_').replaceAll('+', '_')}';
    } catch (e) {
      // For a  user projects, we should generally never reach here.
      _logger.info(
          'Unable to extract ffigen version from pubspec.lock, Using ${fallbackDylibVersion} as wrapper version.');
      // Use fallback instead to not break the tool.
      _ffigenVersion = fallbackDylibVersion;
    }
  }
  return _ffigenVersion;
}
