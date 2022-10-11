// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Forward declaration to SeparatelyDefinedStruct, with definition in
// separate_definition_base.h
struct SeparatelyDefinedStruct;

void func(struct SeparatelyDefinedStruct s);

void func2(struct SeparatelyDefinedStruct *s);
