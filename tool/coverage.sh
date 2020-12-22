#!/bin/bash

# Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Gather coverage.
pub global activate remove_from_coverage
pub global activate coverage
# Generate coverage report.
dart --no-sound-null-safety --pause-isolates-on-exit --disable-service-auth-codes --enable-vm-service=3000 test/test_coverage.dart &
dart pub global run coverage:collect_coverage --wait-paused --uri=http://127.0.0.1:3000/ -o coverage.json --resume-isolates
dart pub global run coverage:format_coverage --lcov -i coverage.json -o lcov.info

# Remove extra files from coverage report.
pub global run remove_from_coverage -f lcov.info -r ".pub-cache"
