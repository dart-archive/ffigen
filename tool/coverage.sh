#!/bin/bash

# Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Gather coverage.
dart pub global activate coverage
# Generate coverage report.
dart run --pause-isolates-on-exit --disable-service-auth-codes --enable-vm-service=3000 test &
dart pub global run coverage:collect_coverage --wait-paused --uri=http://127.0.0.1:3000/ -o coverage.json --resume-isolates --scope-output=ffigen
dart pub global run coverage:format_coverage --packages=.dart_tool/package_config.json --lcov -i coverage.json -o lcov.info
