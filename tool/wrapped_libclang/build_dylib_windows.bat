call clang -IC:\Proga~1\LLVM\include -L:\Progra~1\LLVM\lib -llibclang -shared wrapper.c -o wrapped_clang.dll -Wl,"/DEF:wrapper.def"
rm wrapped_clang.exp
rm wrapped_clang.lib
echo "Created wrapped_clang.dll"