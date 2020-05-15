# build script to generate Dynamic library for libclang wrapper and generate bindings
set -e

printf "Building Dynamic Library for libclang wrapper: "
clang -I/usr/lib/llvm-9/include/ -I/usr/lib/llvm-10/include/ -lclang -shared -fpic tool/wrapped_libclang/wrapper.c -o tool/wrapped_libclang/libwrapped_clang.so
printf "./tool/wrapped_libclang/libwrapped_clang.so\n"

printf "Generating LibClang Bindings..\n"
pub get
dart tool/libclang_binding_generator.dart
printf "Generated bindings: ./lib/src/clang_bindings.dart\n"