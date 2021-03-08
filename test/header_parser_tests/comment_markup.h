// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This is a single line test comment.
void com1();

/// This is a multi-line
/// test comment.
void com2();

/** This is a multi-line
 * doxygen style
 * test comment.
 */
void com3();

// Test comment for struct.
struct com4{
    /// Muli-line test comment for struct field
    // With multiple line and both // and ///.
    int a;

    /* Single line field comment. */
    float b;
};
