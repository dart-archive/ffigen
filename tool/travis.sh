#!/bin/bash

# Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Gather coverage.
pub global activate remove_from_coverage
pub global activate dart_coveralls
# Generate coverage report.
pub global run dart_coveralls calc test/test_coverage.dart > lcov.info
# Remove extra files from coverage report.
pub global run remove_from_coverage -f lcov.info -r ".pub-cache"
