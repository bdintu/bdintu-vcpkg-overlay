include(CMakeFindDependencyMacro)

find_dependency(OpenSSL)
find_dependency(ZLIB)
find_dependency(libuv CONFIG)

get_filename_component(_SCYLLA_CPP_DRIVER_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)

find_library(_SCYLLA_CPP_DRIVER_LIBRARY
    NAMES scylla-cpp-driver scylla-cpp-driver_static
    PATHS "${_SCYLLA_CPP_DRIVER_PREFIX}/lib"
    NO_DEFAULT_PATH)

if(NOT _SCYLLA_CPP_DRIVER_LIBRARY)
    set(scylla-cpp-driver_FOUND FALSE)
    if(scylla-cpp-driver_FIND_REQUIRED)
        message(FATAL_ERROR "scylla-cpp-driver library was not found under ${_SCYLLA_CPP_DRIVER_PREFIX}/lib")
    endif()
    return()
endif()

if(NOT TARGET scylla-cpp-driver::scylla-cpp-driver)
    add_library(scylla-cpp-driver::scylla-cpp-driver UNKNOWN IMPORTED)
    set_target_properties(scylla-cpp-driver::scylla-cpp-driver PROPERTIES
        IMPORTED_LOCATION "${_SCYLLA_CPP_DRIVER_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${_SCYLLA_CPP_DRIVER_PREFIX}/include"
        INTERFACE_LINK_LIBRARIES "OpenSSL::SSL;OpenSSL::Crypto;ZLIB::ZLIB;$<IF:$<TARGET_EXISTS:libuv::uv_a>,libuv::uv_a,libuv::uv>")
endif()

set(scylla-cpp-driver_FOUND TRUE)
