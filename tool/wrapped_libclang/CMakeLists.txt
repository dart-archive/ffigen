cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(wrapped_libclang VERSION 1.0.0 LANGUAGES C)

add_library(wrapped_libclang SHARED wrapper.c)
add_executable(wrapped_clang_test wrapper.c)

set_target_properties(wrapped_libclang PROPERTIES
    PUBLIC_HEADER wrapper.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "wrapped_clang"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)
