// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  Uri? tempDirUri;
  final projectName = 'test_project';

  setUp(() async {
    tempDirUri = (await Directory.current.createTemp('.temp_test_')).uri;
  });

  tearDown(() async {
    final dir = Directory(tempDirUri!.toFilePath());
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  test('Run Flutter', () async {
    final projectDirUri = tempDirUri!.resolve('$projectName/');
    final libDirUri = projectDirUri.resolve('lib/');
    final bindingsGeneratedUri =
        libDirUri.resolve('${projectName}_bindings_generated.dart');
    final bindingsGeneratedCopyUri =
        libDirUri.resolve('${projectName}_bindings_generated_copy.dart');

    await Task.serial([
      RunProcess(
        executable: 'flutter',
        arguments: [
          'create',
          '--template=plugin_ffi',
          projectName,
        ],
        workingDirectory: tempDirUri,
      ),
      Copy(
        source: bindingsGeneratedUri,
        target: bindingsGeneratedCopyUri,
      ),
      RunProcess(
        executable: 'flutter',
        arguments: [
          'pub',
          'run',
          'ffigen',
          '--config',
          'ffigen.yaml',
        ],
        workingDirectory: projectDirUri,
      ),
    ]).run();

    final originalBindings = await readFileAsString(bindingsGeneratedCopyUri);
    final regeneratedBindings = await readFileAsString(bindingsGeneratedUri);

    expect(originalBindings, regeneratedBindings);
  });
}

Future<String> readFileAsString(Uri uri) async {
  final contents = await File(uri.toFilePath()).readAsString();
  return contents.replaceAll('\r', '');
}

abstract class Task {
  Future<void> run();

  factory Task.serial(Iterable<Task> tasks) => _SerialTask(tasks);
}

class _SerialTask implements Task {
  final Iterable<Task> tasks;

  _SerialTask(this.tasks);

  @override
  Future<void> run() async {
    for (final task in tasks) {
      await task.run();
    }
  }
}

class RunProcess implements Task {
  final List<String> arguments;
  final String executable;
  final Uri? workingDirectory;
  Map<String, String>? environment;
  final bool throwOnFailure;

  RunProcess({
    required this.arguments,
    required this.executable,
    this.workingDirectory,
    this.environment,
    this.throwOnFailure = true,
  });

  /// Excluding [workingDirectory].
  String get commandString => [
        if (workingDirectory != null) '(cd ${workingDirectory!.path};',
        ...?environment?.entries.map((entry) => '${entry.key}=${entry.value}'),
        executable,
        ...arguments.map((a) => a.contains(' ') ? "'$a'" : a),
        if (workingDirectory != null) ')',
      ].join(' ');

  @override
  Future<void> run() async {
    final workingDirectoryString = workingDirectory?.toFilePath();

    print('Running `$commandString`.');
    final process = await Process.start(executable, arguments,
            runInShell: true,
            includeParentEnvironment: true,
            workingDirectory: workingDirectoryString,
            environment: environment)
        .then((process) {
      process.stdout.transform(utf8.decoder).forEach((s) => print('  $s'));
      process.stderr.transform(utf8.decoder).forEach((s) => print('  $s'));
      return process;
    });
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      final message =
          'Command `$commandString` failed with exit code $exitCode.';
      print(message);
      if (throwOnFailure) {
        throw Exception(message);
      }
    }
    print('Command `$commandString` done.');
  }
}

class Copy implements Task {
  final Uri source;
  final Uri target;

  Copy({
    required this.source,
    required this.target,
  });

  @override
  Future<void> run() async {
    final file = File.fromUri(source);
    if (!await file.exists()) {
      final message =
          "File not in expected location: '${source.toFilePath()}'.";
      print(message);
      throw Exception(message);
    }
    print('Copying ${source.toFilePath()} to ${target.toFilePath()}.');
    await file.copy(target.toFilePath());
  }
}
