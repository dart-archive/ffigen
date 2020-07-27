// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library find_resource;

export 'find_resource/find_resource_fallback.dart'
    if (dart.library.cli) 'find_resource/find_resource_cli.dart';
