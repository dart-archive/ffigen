import 'dart:io';

import 'package:cli_util/cli_util.dart';
import 'package:path/path.dart' as p;

Future<ProcessResult> runFfigenForConfig(
    String sdkPath, String configPath) async {
  return Process.run(
    p.join(sdkPath, 'bin', 'dart'),
    [
      'run',
      'ffigen',
      '--config=$configPath',
    ],
    runInShell: Platform.isWindows,
  );
}

void main() async {
  final sdkPath = getSdkPath();
  final configPaths = [
    'ffigen_configs/base.yaml',
    'ffigen_configs/a.yaml',
    'ffigen_configs/a_shared_base.yaml'
  ];
  for (final configPath in configPaths) {
    final res = await runFfigenForConfig(sdkPath, configPath);
    print(res.stdout.toString());
    if (res.exitCode != 0) {
      throw Exception("Some error occurred: ${res.stderr.toString()}");
    }
  }
}
