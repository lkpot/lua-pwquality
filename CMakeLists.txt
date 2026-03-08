
cmake_minimum_required(VERSION 3.18.0)

project(pwquality
    VERSION 1.0.0
    LANGUAGES C
    HOMEPAGE_URL https://github.com/lkpot/lua-pwquality
    DESCRIPTION "Password quality checking library for Lua"
)

set(CMAKE_BUILD_TYPE Release)

include(FindLua)
include(GNUInstallDirs)

find_package(PkgConfig REQUIRED)
pkg_check_modules(PWQUALITY REQUIRED IMPORTED_TARGET pwquality)

add_library(${CMAKE_PROJECT_NAME} MODULE lua_pwquality.c)
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${LUA_INCLUDE_DIR})
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE ${LUA_LIBRARIES} PkgConfig::PWQUALITY)
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES PREFIX "")

install(TARGETS ${CMAKE_PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_LIBDIR}/lua/${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR})
