set -e

echo "Building Dynamic Library for libclang wrapper... "
clang -I/usr/lib/llvm-9/include/ -I/usr/lib/llvm-10/include/ -lclang -shared -fpic wrapper.c -o libwrapped_clang.so
echo "Generated file: libwrapped_clang.so"