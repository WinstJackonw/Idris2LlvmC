cmake_minimum_required(VERSION 3.20)
project(idris2_llvm_shim LANGUAGES C CXX)

find_package(LLVM 22.1 REQUIRED CONFIG)

if(NOT LLVM_VERSION_MAJOR EQUAL 22 OR NOT LLVM_VERSION_MINOR EQUAL 1)
  message(FATAL_ERROR
    "llvm-c 0.1.0 requires LLVM 22.1.x; found ${LLVM_PACKAGE_VERSION}")
endif()

if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "llvm-c 0.1.0 supports only 64-bit LLVM builds")
endif()

message(STATUS "Building Idris LLVM shim against LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "LLVM_DIR=${LLVM_DIR}")

llvm_map_components_to_libnames(LLVM_COMPONENT_LIBS
  core
  analysis
  irreader
  bitreader
  bitwriter
  linker
  passes
  target
  targetparser
  support
  ${LLVM_TARGETS_TO_BUILD}
)

add_library(idris2_llvm SHARED src/idris2_llvm.cpp)
target_compile_features(idris2_llvm PRIVATE cxx_std_17)
target_include_directories(idris2_llvm
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
  PRIVATE ${LLVM_INCLUDE_DIRS}
)
target_compile_definitions(idris2_llvm PRIVATE ${LLVM_DEFINITIONS})
set_target_properties(idris2_llvm PROPERTIES
  CXX_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN YES
  OUTPUT_NAME idris2_llvm
  BUILD_RPATH "${LLVM_LIBRARY_DIRS}"
  INSTALL_RPATH "${LLVM_LIBRARY_DIRS}"
)
target_link_directories(idris2_llvm PRIVATE ${LLVM_LIBRARY_DIRS})
target_link_libraries(idris2_llvm PRIVATE ${LLVM_COMPONENT_LIBS} ${LLVM_SYSTEM_LIBS})

include(CTest)
if(BUILD_TESTING)
  add_executable(shim_smoke tests/shim_smoke.cpp)
  target_link_libraries(shim_smoke PRIVATE idris2_llvm)
  add_test(NAME shim_smoke COMMAND shim_smoke)
endif()

install(TARGETS idris2_llvm
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION lib
  ARCHIVE DESTINATION lib
)
install(FILES include/idris2_llvm.h DESTINATION include)
