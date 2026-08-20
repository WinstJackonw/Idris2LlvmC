cmake_minimum_required(VERSION 3.20)
project(idris2_llvm_shim LANGUAGES C)

find_package(LLVM 22.1 REQUIRED CONFIG)

if(NOT LLVM_VERSION_MAJOR EQUAL 22 OR NOT LLVM_VERSION_MINOR EQUAL 1)
  message(FATAL_ERROR
    "llvm-c 0.1.0 requires LLVM 22.1.x; found ${LLVM_PACKAGE_VERSION}")
endif()

if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "llvm-c 0.1.0 supports only 64-bit LLVM builds")
endif()

message(STATUS "Building minimal Idris LLVM shim against LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "LLVM_DIR=${LLVM_DIR}")

if(NOT TARGET LLVM)
  message(FATAL_ERROR
    "llvm-c requires LLVM's monolithic shared libLLVM target")
endif()

find_library(LLVM_LTO_DYLIB NAMES LTO
  HINTS ${LLVM_LIBRARY_DIRS}
  NO_DEFAULT_PATH
  REQUIRED)
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/lto-dylib-path" "${LLVM_LTO_DYLIB}")

add_library(idris2_llvm SHARED src/idris2_llvm.c)
target_compile_features(idris2_llvm PRIVATE c_std_11)
target_include_directories(idris2_llvm
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
  PRIVATE ${LLVM_INCLUDE_DIRS}
)
target_compile_definitions(idris2_llvm PRIVATE ${LLVM_DEFINITIONS})
set_target_properties(idris2_llvm PROPERTIES
  C_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN YES
  OUTPUT_NAME idris2_llvm
  BUILD_RPATH "${LLVM_LIBRARY_DIRS}"
  INSTALL_RPATH "${LLVM_LIBRARY_DIRS}"
)
target_link_directories(idris2_llvm PRIVATE ${LLVM_LIBRARY_DIRS})
target_link_libraries(idris2_llvm PRIVATE LLVM)

# The Idris FFI loads the exact extensionless library name.  Expose the
# resolved monolithic library path to the build/install scripts so they can
# create a lightweight local symlink instead of copying libLLVM.
file(GENERATE
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/llvm-dylib-path"
  CONTENT "$<TARGET_FILE:LLVM>")

include(CTest)
if(BUILD_TESTING)
  add_executable(shim_smoke tests/shim_smoke.c)
  target_link_libraries(shim_smoke PRIVATE idris2_llvm)
  add_test(NAME shim_smoke COMMAND shim_smoke)
endif()

install(TARGETS idris2_llvm
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION lib
  ARCHIVE DESTINATION lib
)
install(FILES include/idris2_llvm.h DESTINATION include)
