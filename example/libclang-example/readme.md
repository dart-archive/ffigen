# Libclang example

Demonstrates generating bindings for [Libclang](https://clang.llvm.org/doxygen/group__CINDEX.html).
The C header source files for libclang are in [third_party/libclang](/third_party/libclang).

## Generating bindings
At the root of this example (`example/libclang-example`), run -
```
pub run ffigen
```
This will generate bindings in a file: [generated_bindings.dart](./generated_bindings.dart).
