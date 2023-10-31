// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef _TEST_UTIL_H_
#define _TEST_UTIL_H_

typedef struct {
  void* isa;
  int flags;
  // There are other fields, but we just need the flags and isa.
} BlockRefCountExtractor;

static void* valid_block_isa = NULL;
uint64_t getBlockRetainCount(void* block) {
  BlockRefCountExtractor* b = (BlockRefCountExtractor*)block;
  // HACK: The only way I can find to reliably figure out that a block has been
  // deleted is to check the isa field (the lower bits of the flags field seem
  // to be randomized, not just set to 0). But we also don't know the value this
  // field has when it's constructed (copying the block changes it from
  // _NSConcreteGlobalBlock to an internal value). So we assume that the first
  // time this function is called, we have a valid block, and on subsequent
  // calls we check to see if the isa field changed.
  if (valid_block_isa == NULL) {
    valid_block_isa = b->isa;
  }
  if (b->isa != valid_block_isa) {
    return 0;
  }
  // The ref count is stored in the lower bits of the flags field, but skips the
  // 0x1 bit.
  return (b->flags & 0xFFFF) >> 1;
}

#endif  // _TEST_UTIL_H_
