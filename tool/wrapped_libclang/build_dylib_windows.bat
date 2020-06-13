call clang -IC:\Progra~1\LLVM\include -LC:\Progra~1\LLVM\lib -llibclang -shared wrapper.c -o wrapped_clang.dll -Wl,"/DEF:wrapper.def"
del wrapped_clang.exp
del wrapped_clang.lib
echo "Created wrapped_clang.dll"