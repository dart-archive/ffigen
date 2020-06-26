# Libclang example

Demonstrates generating bindings for [Libclang](https://clang.llvm.org/doxygen/group__CINDEX.html).
This example actually uses a C file used in this package itself, ([wrapper.c](../../tool/wrapped_libclang/wrapper.c)), which adds a few more wrapper functions atop Libclang.

## Generating bindings
At the root of this example (`example/libclang-example`), run -
```
pub run ffigen
```
This will generate bindings in a file: [generated_bindings.dart](./generated_bindings.dart).
