# build script to generate Dynamic library for libclang wrapper and generate bindings
set -e

printf "Building Dynamic Library for libclang wrapper: "
clang -lclang -shared -fpic tool/wrapped_libclang/wrapper.c -o tool/wrapped_libclang/libwrapped_clang.so
printf "./tool/wrapped_libclang/libwrapped_clang.so\n"

printf "Generating LibClang Bindings..\n"
dart tool/libclang_binding_generator.dart
printf "Generated bindings: ./lib/src/clang_bindings.dart\n"