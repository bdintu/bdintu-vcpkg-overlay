find_package(Boost CONFIG REQUIRED COMPONENTS uuid)

find_package(unofficial-libev CONFIG REQUIRED)
get_target_property(
    _userver_libev_include_dirs
    unofficial::libev::libev
    INTERFACE_INCLUDE_DIRECTORIES
)
foreach(_userver_libev_include_dir IN LISTS _userver_libev_include_dirs)
    if(IS_DIRECTORY "${_userver_libev_include_dir}/libev")
        set_property(
            TARGET unofficial::libev::libev
            APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES
            "${_userver_libev_include_dir}/libev"
        )
    endif()
endforeach()

if(NOT TARGET libev::libev)
    add_library(libev::libev ALIAS unofficial::libev::libev)
endif()
