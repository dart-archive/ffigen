cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(wrapped_libclang LANGUAGES C)

find_package(Clang REQUIRED)

# Add path to LLVM modules
set(CMAKE_MODULE_PATH
  ${CMAKE_MODULE_PATH}
  "${LLVM_CMAKE_DIR}"
  )

include(AddLLVM)

include_directories(${LLVM_INCLUDE_DIRS})
include_directories(${CLANG_INCLUDE_DIRS})

message(${LLVM_DEFINITIONS})

add_definitions(${LLVM_DEFINITIONS})
add_definitions(${CLANG_DEFINITIONS})

separate_arguments(LLVM_DEFINITIONS)
separate_arguments(CLANG_DEFINITIONS)
add_llvm_library(wrapped_libclang SHARED wrapper.c wrapper.def)
target_compile_definitions(wrapped_libclang PUBLIC ${LLVM_DEFINITIONS})
target_compile_definitions(wrapped_libclang PUBLIC ${CLANG_DEFINITIONS})
# target_link_libraries(wrapped_libclang PUBLIC Clang::Clang)
target_link_libraries(wrapped_libclang PRIVATE clangIndex)


set_target_properties(wrapped_libclang PROPERTIES
    PUBLIC_HEADER wrapper.c
    OUTPUT_NAME "wrapped_clang"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)