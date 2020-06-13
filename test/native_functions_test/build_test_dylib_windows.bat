call clang -shared native_functions.c -o native_functions.dll -Wl,"/DEF:native_functions.def"
del native_functions.exp
del native_functions.lib
echo "Created native_functions.dll"