vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/userver-framework/userver.git
    REF c9f77729c0edce7e423def2d4a4450aa7fc9d259
)

# These features need additional packaging decisions before they can be built
# without untracked downloads or an incorrect dependency substitution.
if("grpc" IN_LIST FEATURES)
    message(FATAL_ERROR
        "userver[grpc] is unresolved: userver v3.1 requires the Google common "
        "proto sources, for which this overlay does not yet provide a pinned "
        "vcpkg dependency. The port will not allow userver to fetch them from "
        "a moving upstream branch."
    )
endif()

if("scylla" IN_LIST FEATURES)
    message(FATAL_ERROR
        "userver[scylla] is unresolved: it requires scylladb/cpp-rs-driver. "
        "The existing scylla-cpp-driver overlay packages the older native C++ "
        "driver and must not be used as a substitute."
    )
endif()

if("postgresql" IN_LIST FEATURES AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(FATAL_ERROR
        "userver[postgresql] is unresolved for static-linkage triplets: with "
        "USERVER_FEATURE_PATCH_LIBPQ=OFF, userver v3.1 explicitly requires a "
        "shared libpq. Enabling the upstream libpq patch requires PostgreSQL "
        "server headers and libraries that the current overlay does not package."
    )
endif()

vcpkg_find_acquire_program(PYTHON3)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        postgresql USERVER_FEATURE_POSTGRESQL
        grpc       USERVER_FEATURE_GRPC
        scylla     USERVER_FEATURE_SCYLLADB
        kafka      USERVER_FEATURE_KAFKA
        utest      USERVER_FEATURE_UTEST
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(USERVER_USE_STATIC_LIBS ON)
else()
    set(USERVER_USE_STATIC_LIBS OFF)
endif()

set(ENV{LDFLAGS} "-L${CURRENT_INSTALLED_DIR}/lib $ENV{LDFLAGS}")
set(ENV{CPPFLAGS} "-I${CURRENT_INSTALLED_DIR}/include $ENV{CPPFLAGS}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_PROJECT_TOP_LEVEL_INCLUDES=${CMAKE_CURRENT_LIST_DIR}/boost-uuid-preload.cmake
        -DCMAKE_BUILD_RPATH=${CURRENT_INSTALLED_DIR}/lib
        -DUSERVER_INSTALL=ON
        -DUSERVER_CHECK_PACKAGE_VERSIONS=OFF
        -DUSERVER_DOWNLOAD_PACKAGES=OFF
        -DUSERVER_FORCE_DOWNLOAD_PACKAGES=OFF
        -DUSERVER_BUILD_TESTS=OFF
        -DUSERVER_BUILD_SAMPLES=OFF
        -DUSERVER_BUILD_ALL_COMPONENTS=OFF
        -DUSERVER_FEATURE_CORE=ON
        -DUSERVER_FEATURE_CHAOTIC=ON
        -DUSERVER_FEATURE_CHAOTIC_EXPERIMENTAL=OFF
        -DUSERVER_FEATURE_MONGODB=OFF
        -DUSERVER_FEATURE_REDIS=OFF
        -DUSERVER_FEATURE_CLICKHOUSE=OFF
        -DUSERVER_FEATURE_RABBITMQ=OFF
        -DUSERVER_FEATURE_MYSQL=OFF
        -DUSERVER_FEATURE_ROCKS=OFF
        -DUSERVER_FEATURE_YDB=OFF
        -DUSERVER_FEATURE_OTLP=OFF
        -DUSERVER_FEATURE_SQLITE=OFF
        -DUSERVER_FEATURE_ODBC=OFF
        -DUSERVER_FEATURE_EASY=OFF
        -DUSERVER_FEATURE_S3API=OFF
        -DUSERVER_FEATURE_MULTI_INDEX_LRU=OFF
        -DUSERVER_FEATURE_GRPC_REFLECTION=OFF
        -DUSERVER_FEATURE_GRPC_PROTOVALIDATE=OFF
        -DUSERVER_FEATURE_JEMALLOC=OFF
        -DUSERVER_FEATURE_PATCH_LIBPQ=OFF
        # Testsuite infrastructure is installed with core. Keep it disabled
        # while packaging so userver does not construct its own test venv.
        -DUSERVER_FEATURE_TESTSUITE=OFF
        -DUSERVER_CHAOTIC_FORMAT=OFF
        -DUSERVER_PYTHON_PATH=${PYTHON3}
        -DUSERVER_USE_STATIC_LIBS=${USERVER_USE_STATIC_LIBS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/userver)

foreach(USERVER_CHAOTIC_LAUNCHER IN ITEMS chaotic-gen chaotic-gen-dynamic-configs)
    if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/bin/${USERVER_CHAOTIC_LAUNCHER}")
        message(FATAL_ERROR "Missing installed userver launcher: ${USERVER_CHAOTIC_LAUNCHER}")
    endif()
endforeach()
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/ChaoticGen.cmake"
    "../../../bin"
    "../../bin"
)

# userver's exported targets reference these Boost component targets before
# its component configs load Boost themselves.
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/userverConfig.cmake"
    [[if(CMAKE_BUILD_TYPE MATCHES "^.*Rel.*$") # same as in UserverSetupEnvironment]]
    [[find_package(ICU REQUIRED COMPONENTS data)
find_package(unofficial-libev CONFIG REQUIRED)
find_package(Boost CONFIG REQUIRED COMPONENTS uuid coroutine2)

if(CMAKE_BUILD_TYPE MATCHES "^.*Rel.*$") # same as in UserverSetupEnvironment]]
)

# vcpkg_cmake_config_fixup relocates userver's configuration-specific exports
# from lib/cmake/userver/<config> to share/userver/<config>.  Its rewritten
# import prefix only climbs to share/, while imported libraries are rooted at
# the triplet prefix.  Correct the single relocatable prefix calculation rather
# than rewriting every imported target location.
set(USERVER_TARGET_EXPORTS
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/release/userver-targets.cmake"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/release/userver-targets_d.cmake"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/debug/userver-targets.cmake"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/debug/userver-targets_d.cmake"
)
foreach(USERVER_TARGET_EXPORT IN LISTS USERVER_TARGET_EXPORTS)
    if(EXISTS "${USERVER_TARGET_EXPORT}")
        vcpkg_replace_string(
            "${USERVER_TARGET_EXPORT}"
            [[get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
if(_IMPORT_PREFIX STREQUAL "/")]]
            [[get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
if(_IMPORT_PREFIX STREQUAL "/")]]
        )
    endif()
endforeach()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
